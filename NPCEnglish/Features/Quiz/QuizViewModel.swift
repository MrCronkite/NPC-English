//
//  QuizViewModel.swift
//  CombineApp
//
//  Created by Влад Шимченко on 27.07.2026.
//


import SwiftUI
import Combine

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

    @Published private(set) var allWords: [Word] = []
    @Published private(set) var currentWord: Word?
    @Published private(set) var options: [Word] = []
    @Published private(set) var isSessionFinished = false
    @Published private(set) var isCurrentFavorite = false
    @Published private(set) var isCurrentWordReview = false

    @Published var newlyUnlockedAchievement: Achievement?

    @Published var selectedOption: Word?
    @Published var isAnswered = false

    @Published var score = 0
    @Published var total = 0

    private(set) var plannedQuestions: Int = 0

    private var wordSources: [Int: WordSet] = [:]
    private var currentWordSource: WordSet?
    private var progressSnapshot: [Int: WordProgressSnapshot] = [:]

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
            self.allWords = words.filter { $0.category == category.rawValue }
        } else {
            self.allWords = words
        }

        self.progressSnapshot = progressTracker.snapshot(for: wordSet, category: category)
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

        var collected: [Word] = []
        var sources: [Int: WordSet] = [:]

        for set in WordSet.regularSets {
            let ids = Set(favoritesManager.favoriteWordIDs(in: set))
            guard !ids.isEmpty else { continue }
            let words = WordsLoader.loadWords(for: set)
            for word in words where ids.contains(word.id) {
                collected.append(word)
                sources[word.id] = set
            }
        }

        self.allWords = collected
        self.wordSources = sources

        // В режиме избранного слова из разных наборов — снэпшот собираем по всем сразу,
        // индексируем по word.id (тут пересечения id между наборами не страшны,
        // потому что мы не мешаем данные из разных wordSet в одном ключе словаря снаружи —
        // здесь просто читаем прогресс каждого источника отдельно и сводим в одну карту).
        var mergedSnapshot: [Int: WordProgressSnapshot] = [:]
        for set in WordSet.regularSets {
            let setSnapshot = progressTracker.snapshot(for: set, category: nil)
            for word in collected where sources[word.id] == set {
                mergedSnapshot[word.id] = setSnapshot[word.id]
            }
        }
        self.progressSnapshot = mergedSnapshot

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

    func optionText(for word: Word) -> String {
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

        let weighted = SpacedRepetitionSelector.weightedWords(from: allWords, snapshot: progressSnapshot)
        guard let picked = SpacedRepetitionSelector.pickRandom(from: weighted) else {
            currentWord = nil
            options = []
            return
        }

        let word = picked.word
        currentWord = word
        isCurrentWordReview = picked.isReviewWord
        currentWordSource = wordSet == .favorites ? wordSources[word.id] : wordSet

        var wrongOptions = allWords.filter { $0.id != word.id }
        wrongOptions.shuffle()
        let wrongThree = Array(wrongOptions.prefix(3))

        options = (wrongThree + [word]).shuffled()
        refreshFavoriteStatus()
    }

    func select(_ option: Word) {
        guard !isAnswered, let word = currentWord, let source = currentWordSource else { return }
        selectedOption = option
        isAnswered = true
        total += 1

        let correct = option.id == word.id
        progressTracker.recordAnswer(wordID: word.id, in: source, category: category, mode: .multipleChoice, isCorrect: correct)

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
        guard let word = currentWord, let source = currentWordSource else { return }
        favoritesManager.toggleFavorite(wordID: word.id, in: source)
        refreshFavoriteStatus()
    }

    func speakCurrentWord() {
        guard let word = currentWord else { return }
        speechManager.speak(word.english)
    }

    private func refreshFavoriteStatus() {
        guard let word = currentWord, let source = currentWordSource else {
            isCurrentFavorite = false
            return
        }
        isCurrentFavorite = favoritesManager.isFavorite(wordID: word.id, in: source)
    }
}
