//
//  TypingQuizViewModel.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 12.08.2026.
//

import SwiftUI

@MainActor
final class TypingQuizViewModel: ObservableObject {
    let wordSet: WordSet
    private let favoritesManager: FavoritesManaging
    private let statsManager: StatsManaging

    @AppStorage("translationDirection")
    private var directionRaw: String = TranslationDirection.englishToRussian.rawValue

    @AppStorage("sessionLength")
    private var sessionLength: Int = 10

    @Published private(set) var allWords: [Word] = []
    @Published private(set) var currentWord: Word?
    @Published private(set) var isSessionFinished = false

    @Published var userInput: String = ""
    @Published private(set) var isAnswered = false
    @Published private(set) var wasCorrect = false

    @Published var score = 0
    @Published var total = 0

    private(set) var plannedQuestions: Int = 0

    private var direction: TranslationDirection {
        TranslationDirection(rawValue: directionRaw) ?? .englishToRussian
    }

    init(wordSet: WordSet, category: WordCategory? = nil, favoritesManager: FavoritesManaging, statsManager: StatsManaging) {
        self.wordSet = wordSet
        self.favoritesManager = favoritesManager
        self.statsManager = statsManager

        let words = WordsLoader.loadWords(for: wordSet)
        self.allWords = category.map { cat in words.filter { $0.category == cat.rawValue } } ?? words

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
            isSessionFinished = true
            return
        }

        userInput = ""
        isAnswered = false
        wasCorrect = false
        currentWord = allWords.randomElement()
    }

    func submitAnswer() {
        guard !isAnswered, let word = currentWord else { return }

        let expected = direction == .englishToRussian ? word.translation : word.english
        let correct = AnswerChecker.isCorrect(input: userInput, expected: expected)

        isAnswered = true
        wasCorrect = correct
        total += 1

        if correct {
            score += 1
            FeedbackManager.playCorrect()
        } else {
            FeedbackManager.playIncorrect()
        }
    }

    /// "Не знаю" — сразу показывает ответ, засчитывается как неверный
    func revealAnswer() {
        guard !isAnswered, currentWord != nil else { return }
        isAnswered = true
        wasCorrect = false
        total += 1
        FeedbackManager.playIncorrect()
    }

    func restartSession() {
        score = 0
        total = 0
        isSessionFinished = false
        nextQuestion()
    }
}
