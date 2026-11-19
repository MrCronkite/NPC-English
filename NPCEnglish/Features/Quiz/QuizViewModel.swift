//
//  QuizViewModel.swift
//  CombineApp
//
//  Created by Влад Шимченко on 27.07.2026.
//


import SwiftUI
import Combine

struct QuizWord: Identifiable, Equatable {
    struct ID: Hashable {
        let wordSet: WordSet
        let wordID: Int
    }

    let word: Word
    let wordSet: WordSet
    var id: ID { ID(wordSet: wordSet, wordID: word.id) }
    var english: String { word.english }
    var translation: String { word.translation }
}

@MainActor
final class QuizViewModel: ObservableObject {
    let wordSet: WordSet
    private let category: WordCategory?
    private let favoritesManager: FavoritesManaging
    private let statsManager: StatsManaging
    private let speechManager: SpeechSynthesizing
    private let progressTracker: WordProgressTracking
    private let achievementsManager: AchievementsManaging

    @AppStorage("translationDirection")
    private var directionRaw: String = TranslationDirection.englishToRussian.rawValue

    @AppStorage("sessionLength")
    private var sessionLength: Int = 10

    @Published private(set) var allWords: [QuizWord] = []
    @Published private(set) var currentWord: QuizWord?
    @Published private(set) var options: [QuizWord] = []
    @Published private(set) var isSessionFinished = false
    @Published private(set) var isCurrentFavorite = false
    @Published private(set) var isCurrentWordReview = false

    @Published var newlyUnlockedAchievement: Achievement?

    @Published var selectedOption: QuizWord?
    @Published var isAnswered = false

    @Published var score = 0
    @Published var total = 0

    private(set) var plannedQuestions: Int = 0

    private var progressSnapshots: [QuizWord.ID: WordProgressSnapshot] = [:]

    private var direction: TranslationDirection {
        TranslationDirection(rawValue: directionRaw) ?? .englishToRussian
    }

    init(
        wordSet: WordSet,
        category: WordCategory? = nil,
        favoritesManager: FavoritesManaging,
        statsManager: StatsManaging,
        speechManager: SpeechSynthesizing,
        progressTracker: WordProgressTracking,
        achievementsManager: AchievementsManaging
    ) {
        self.wordSet = wordSet
        self.category = category
        self.favoritesManager = favoritesManager
        self.statsManager = statsManager
        self.speechManager = speechManager
        self.progressTracker = progressTracker
        self.achievementsManager = achievementsManager

        let words = WordsLoader.loadWords(for: wordSet)
        if let category {
            self.allWords = words.filter { $0.category == category.rawValue }.map { QuizWord(word: $0, wordSet: wordSet) }
        } else {
            self.allWords = words.map { QuizWord(word: $0, wordSet: wordSet) }
        }

        let snapshot = progressTracker.snapshot(for: wordSet, category: category)
        for entry in allWords { progressSnapshots[entry.id] = snapshot[entry.word.id] }
        self.plannedQuestions = sessionLength
        nextQuestion()
    }

    init(
        favoritesManager: FavoritesManaging,
        statsManager: StatsManaging,
        speechManager: SpeechSynthesizing,
        progressTracker: WordProgressTracking,
        achievementsManager: AchievementsManaging
    ) {
        self.wordSet = .favorites
        self.favoritesManager = favoritesManager
        self.statsManager = statsManager
        self.speechManager = speechManager
        self.progressTracker = progressTracker
        self.achievementsManager = achievementsManager
        self.category = nil

        for set in WordSet.regularSets {
            let ids = Set(favoritesManager.favoriteWordIDs(in: set))
            let words = WordsLoader.loadWords(for: set).filter { ids.contains($0.id) }
            let entries = words.map { QuizWord(word: $0, wordSet: set) }
            allWords.append(contentsOf: entries)
            let categories = Set(entries.map { $0.word.category.flatMap(WordCategory.init(rawValue:)) })
            for category in categories {
                let snapshot = progressTracker.snapshot(for: set, category: category)
                for entry in entries where entry.word.category.flatMap(WordCategory.init(rawValue:)) == category {
                    progressSnapshots[entry.id] = snapshot[entry.word.id]
                }
            }
        }

        self.plannedQuestions = sessionLength
        nextQuestion()
    }

    var questionText: String {
        guard let word = currentWord else { return "" }
        return direction == .englishToRussian
        ? word.english
        : word.translation
    }

    var isQuestionInEnglish: Bool {
        direction == .englishToRussian
    }

    func optionText(for word: QuizWord) -> String {
        direction == .englishToRussian
        ? word.translation
        : word.english
    }

    var isCorrect: Bool {
        guard let selected = selectedOption, let current = currentWord else { return false }
        return selected.id == current.id
    }

    func nextQuestion() {
        guard allWords.count >= 4 else {
            currentWord = nil
            options = []
            return
        }

        if total >= plannedQuestions {
            if !isSessionFinished {
                statsManager.recordSessionCompleted(score: score, total: total)

                if score == total && total > 0 {
                    progressTracker.recordPerfectSession(mode: .multipleChoice)
                }

                let unlocked = achievementsManager.checkAndUnlockAchievements(
                    progressTracker: progressTracker,
                    statsManager: statsManager
                )

                if let first = unlocked.first {
                    newlyUnlockedAchievement = first
                }
            }
            isSessionFinished = true
            return
        }

        selectedOption = nil
        isAnswered = false

        let weighted: [(QuizWord, SpacedRepetitionSelector.WeightedWord)] = allWords.map { entry in
            var snapshot: [Int: WordProgressSnapshot] = [:]
            snapshot[entry.word.id] = progressSnapshots[entry.id]
            let weightedWord = SpacedRepetitionSelector.weightedWords(from: [entry.word], snapshot: snapshot)[0]
            return (entry, weightedWord)
        }
        guard let pickedIndex = SpacedRepetitionSelector.pickRandomIndex(weights: weighted.map { $0.1.weight }) else {
            currentWord = nil
            options = []
            return
        }

        let (word, weightedWord) = weighted[pickedIndex]
        currentWord = word
        isCurrentWordReview = weightedWord.isReviewWord

        var wrongOptions = allWords.filter { $0.id != word.id }
        wrongOptions.shuffle()
        let wrongThree = Array(wrongOptions.prefix(3))

        options = (wrongThree + [word]).shuffled()
        refreshFavoriteStatus()
    }

    func select(_ option: QuizWord) {
        guard !isAnswered, let word = currentWord else { return }
        selectedOption = option
        isAnswered = true
        total += 1

        let correct = option.id == word.id
        progressTracker.recordAnswer(wordID: word.word.id, in: word.wordSet, category: wordSet == .favorites ? word.word.category.flatMap(WordCategory.init(rawValue:)) : category, mode: .multipleChoice, isCorrect: correct)

        if correct {
            score += 1
            FeedbackManager.playCorrect()
        } else {
            FeedbackManager.playIncorrect()
        }

        let unlocked = achievementsManager.checkAndUnlockAchievements(
            progressTracker: progressTracker,
            statsManager: statsManager
        )
        
        if let first = unlocked.first {
            newlyUnlockedAchievement = first
        }
    }

    func restartSession() {
        score = 0
        total = 0
        isSessionFinished = false
        nextQuestion()
    }

    func toggleFavorite() {
        guard let word = currentWord else { return }
        favoritesManager.toggleFavorite(wordID: word.word.id, in: word.wordSet)
        refreshFavoriteStatus()
    }

    func speakCurrentWord() {
        guard let word = currentWord else { return }
        speechManager.speak(word.english)
    }

    private func refreshFavoriteStatus() {
        guard let word = currentWord else {
            isCurrentFavorite = false
            return
        }
        isCurrentFavorite = favoritesManager.isFavorite(wordID: word.word.id, in: word.wordSet)
    }
}
