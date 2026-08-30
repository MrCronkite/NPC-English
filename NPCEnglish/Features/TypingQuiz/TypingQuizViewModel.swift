//
//  TypingQuizViewModel.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 12.08.2026.
//

import SwiftUI
import Combine

@MainActor
final class TypingQuizViewModel: ObservableObject {
    let wordSet: WordSet
    private let category: WordCategory?
    private let favoritesManager: FavoritesManaging
    private let statsManager: StatsManaging
    private let progressTracker: WordProgressTracking
    private let achievementsManager: AchievementsManaging


    @AppStorage("translationDirection")
    private var directionRaw: String = TranslationDirection.englishToRussian.rawValue

    @AppStorage("sessionLength")
    private var sessionLength: Int = 10

    @Published private(set) var isCurrentFavorite = false
    @Published private(set) var allWords: [Word] = []
    @Published private(set) var currentWord: Word?
    @Published private(set) var isSessionFinished = false
    @Published private(set) var isCurrentWordReview = false

    @Published var userInput: String = ""
    @Published private(set) var isAnswered = false
    @Published private(set) var wasCorrect = false

    @Published var newlyUnlockedAchievement: Achievement?

    @Published var score = 0
    @Published var total = 0

    private(set) var plannedQuestions: Int = 0

    private var progressSnapshot: [Int: WordProgressSnapshot] = [:]

    private var direction: TranslationDirection {
        TranslationDirection(rawValue: directionRaw) ?? .englishToRussian
    }

    init(
        wordSet: WordSet,
        category: WordCategory? = nil,
        favoritesManager: FavoritesManaging,
        statsManager: StatsManaging,
        progressTracker: WordProgressTracking,
        achievementsManager: AchievementsManaging
    ) {
        self.wordSet = wordSet
        self.favoritesManager = favoritesManager
        self.statsManager = statsManager
        self.progressTracker = progressTracker
        self.achievementsManager = achievementsManager
        self.category = category

        let words = WordsLoader.loadWords(for: wordSet)
        self.allWords = category.map { cat in words.filter { $0.category == cat.rawValue } } ?? words

        self.progressSnapshot = progressTracker.snapshot(for: wordSet, category: category)
        self.plannedQuestions = sessionLength
        nextQuestion()
    }

    var questionText: String {
        guard let word = currentWord else { return "" }
        return direction == .englishToRussian ? word.english : word.translation
    }

    /// Правильный ответ целиком, для показа при ошибке или через "Не знаю"
    var correctAnswerText: String {
        guard let word = currentWord else { return "" }
        return direction == .englishToRussian ? word.translation : word.english
    }

    func nextQuestion() {
        guard !allWords.isEmpty else {
            currentWord = nil
            return
        }

        if total >= plannedQuestions {
            if !isSessionFinished {
                statsManager.recordSessionCompleted(score: score, total: total)
            }
            isSessionFinished = true
            return
        }

        userInput = ""
        isAnswered = false
        wasCorrect = false

        let weighted = SpacedRepetitionSelector.weightedWords(from: allWords, snapshot: progressSnapshot)
        let picked = SpacedRepetitionSelector.pickRandom(from: weighted)
        currentWord = picked?.word
        isCurrentWordReview = picked?.isReviewWord ?? false
    }
    
    func submitAnswer() {
        guard !isAnswered, let word = currentWord else { return }
        
        let expected = direction == .englishToRussian ? word.translation : word.english
        let correct = AnswerChecker.isCorrect(input: userInput, expected: expected)
        
        isAnswered = true
        wasCorrect = correct
        total += 1
        
        progressTracker.recordAnswer(
            wordID: word.id,
            in: wordSet,
            category: category,
            mode: .typing,
            isCorrect: correct
        )

        if correct {
            score += 1
            FeedbackManager.playCorrect()
        } else {
            FeedbackManager.playIncorrect()
        }
    }
    
    func revealAnswer() {
        guard !isAnswered, let word = currentWord else { return }
        isAnswered = true
        wasCorrect = false
        total += 1
        progressTracker
            .recordAnswer(wordID: word.id, in: wordSet, category: category, mode: .typing, isCorrect: wasCorrect)
        FeedbackManager.playIncorrect()
    }
    
    func restartSession() {
        score = 0
        total = 0
        isSessionFinished = false
        nextQuestion()
    }

    func toggleFavorite() {
        guard let word = currentWord else { return }
        favoritesManager.toggleFavorite(wordID: word.id, in: wordSet)
        refreshFavoriteStatus()
    }

    private func refreshFavoriteStatus() {
        guard let word = currentWord else {
            isCurrentFavorite = false
            return
        }
        isCurrentFavorite = favoritesManager.isFavorite(wordID: word.id, in: wordSet)
    }
}
