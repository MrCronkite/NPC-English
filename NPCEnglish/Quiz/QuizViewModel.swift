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

    @AppStorage("translationDirection")
    private var directionRaw: String = TranslationDirection.englishToRussian.rawValue

    @AppStorage("sessionLength")
    private var sessionLength: Int = 10

    @Published private(set) var allWords: [Word] = []
    @Published private(set) var currentWord: Word?
    @Published private(set) var options: [Word] = []
    @Published private(set) var isSessionFinished = false

    @Published var selectedOption: Word?
    @Published var isAnswered = false

    @Published var score = 0
    @Published var total = 0

    private(set) var plannedQuestions: Int = 0

    private var direction: TranslationDirection {
        TranslationDirection(rawValue: directionRaw) ?? .englishToRussian
    }

    init(wordSet: WordSet) {
        self.wordSet = wordSet
        self.allWords = WordsLoader.loadWords(for: wordSet)
        self.plannedQuestions = sessionLength
        nextQuestion()
    }

    var isLimited: Bool { plannedQuestions > 0 }

    var questionText: String {
        guard let word = currentWord else { return "" }
        
        return direction == .englishToRussian
        ? word.english
        : word.translation
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
                isSessionFinished = true
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

        func restartSession() {
            score = 0
            total = 0
            isSessionFinished = false
            nextQuestion()
        }
}
