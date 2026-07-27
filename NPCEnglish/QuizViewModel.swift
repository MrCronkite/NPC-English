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

    @Published var score = 0
    @Published var total = 0

    init(words: [Word] = WordsLoader.loadWords()) {
        self.allWords = words
        nextQuestion()
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

        selectedOption = nil
        isAnswered = false

        let word = allWords.randomElement()!
        currentWord = word

        var wrongOptions = allWords.filter { $0.id != word.id }
        wrongOptions.shuffle()
        let wrongThree = Array(wrongOptions.prefix(3))

        options = (wrongThree + [word]).shuffled()
    }

    func select(_ option: Word) {
        guard !isAnswered else { return }
        selectedOption = option
        isAnswered = true
        total += 1
        if option.id == currentWord?.id {
            score += 1
        }
    }
}
