//
//  QuizViewModel.swift
//  CombineApp
//
//  Created by Влад Шимченко on 27.07.2026.
//


import Foundation
import Combine

@MainActor
final class QuizViewModel: ObservableObject {
    @Published private(set) var allWords: [Word] = []
    @Published private(set) var currentWord: Word?
    @Published private(set) var options: [Word] = []

    @Published var selectedOption: Word?
    @Published var isAnswered = false

    @Published var correctAnswers = 0
    @Published var wrongAnswers = 0

    init(words: [Word] = WordsLoader.loadWords()) {
        self.allWords = words
        nextQuestion()
    }

    var totalQuestions: Int {
        correctAnswers + wrongAnswers
    }

    var accuracy: Int {
        guard totalQuestions > 0 else { return 0 }
        return correctAnswers * 100 / totalQuestions
    }

    var isCorrect: Bool {
        guard let selected = selectedOption,
              let current = currentWord else {
            return false
        }

        return selected.id == current.id
    }

    func nextQuestion() {
        guard allWords.count >= 4 else {
            currentWord = nil
            options = []
            return
        }

        selectedOption = nil
        isAnswered = false

        let word = allWords.randomElement()!
        currentWord = word

        let wrongOptions = allWords
            .filter { $0.id != word.id }
            .shuffled()
            .prefix(3)

        options = (Array(wrongOptions) + [word]).shuffled()
    }

    func select(_ option: Word) {
        guard !isAnswered else { return }

        selectedOption = option
        isAnswered = true

        if option.id == currentWord?.id {
            correctAnswers += 1
        } else {
            wrongAnswers += 1
        }
    }
}
