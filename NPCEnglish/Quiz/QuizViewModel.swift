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
    private let favoritesManager: FavoritesManaging
    private let statsManager: StatsManaging
    private let speechManager: SpeechSynthesizing

    @AppStorage("translationDirection")
    private var directionRaw: String = TranslationDirection.englishToRussian.rawValue

    @AppStorage("sessionLength")
    private var sessionLength: Int = 10

    @Published private(set) var allWords: [Word] = []
    @Published private(set) var currentWord: Word?
    @Published private(set) var options: [Word] = []
    @Published private(set) var isSessionFinished = false
    @Published private(set) var isCurrentFavorite = false

    @Published var selectedOption: Word?
    @Published var isAnswered = false

    @Published var score = 0
    @Published var total = 0

    private(set) var plannedQuestions: Int = 0

    private var wordSources: [Int: WordSet] = [:]
    private var currentWordSource: WordSet?

    private var direction: TranslationDirection {
        TranslationDirection(rawValue: directionRaw) ?? .englishToRussian
    }

    init(
        wordSet: WordSet,
        category: WordCategory? = nil,
        favoritesManager: FavoritesManaging,
        statsManager: StatsManaging,
        speechManager: SpeechSynthesizing
    ) {
        self.wordSet = wordSet
        self.favoritesManager = favoritesManager
        self.statsManager = statsManager
        self.speechManager = speechManager

        let words = WordsLoader.loadWords(for: wordSet)
        if let category {
            self.allWords = words.filter { $0.category == category.rawValue }
        } else {
            self.allWords = words
        }
        
        self.plannedQuestions = sessionLength
        nextQuestion()
    }

    init(
        favoritesManager: FavoritesManaging,
        statsManager: StatsManaging,
        speechManager: SpeechSynthesizing
    ) {
        self.wordSet = .favorites
        self.favoritesManager = favoritesManager
        self.statsManager = statsManager
        self.speechManager = speechManager

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
        self.plannedQuestions = sessionLength
        nextQuestion()
    }

    // isLimited больше не нужен как условие (сессия всегда ограничена),
    // но оставляю для безопасности и для UI прогресс-бара
    var isLimited: Bool { plannedQuestions > 0 }

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

        if isLimited && total >= plannedQuestions {
            if !isSessionFinished {
                statsManager.recordSessionCompleted(score: score, total: total)
            }
            isSessionFinished = true
            return
        }

        selectedOption = nil
        isAnswered = false

        let word = allWords.randomElement()!
        currentWord = word
        currentWordSource = wordSet == .favorites ? wordSources[word.id] : wordSet

        var wrongOptions = allWords.filter { $0.id != word.id }
        wrongOptions.shuffle()
        let wrongThree = Array(wrongOptions.prefix(3))

        options = (wrongThree + [word]).shuffled()
        refreshFavoriteStatus()
    }

    func select(_ option: Word) {
        guard !isAnswered else { return }
        selectedOption = option
        isAnswered = true
        total += 1

        if option.id == currentWord?.id {
            score += 1
            FeedbackManager.playCorrect()
        } else {
            FeedbackManager.playIncorrect()
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
