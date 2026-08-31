//
//  SpacedRepetitionSelector.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 18.08.2026.
//

import Foundation

enum SpacedRepetitionSelector {

    struct WeightedWord {
        let word: Word
        let weight: Double
        let isReviewWord: Bool
    }

    /// Порог веса, начиная с которого слово считается "повторением" для UI-индикатора,
    /// а не обычным новым/хорошо изученным словом.
    private static let reviewThreshold = 1.5
    private static let baseWeight = 1.0

    /// Считает вес каждого слова: больше ошибок → выше вес, давно не показывалось → выше вес,
    /// много правильных ответов → вес немного снижается (слово подзабывается алгоритмом).
    static func weightedWords(from words: [Word], snapshot: [Int: WordProgressSnapshot], referenceDate: Date = Date()) -> [WeightedWord] {
        words.map { word in
            let progress = snapshot[word.id]
            let weight = computeWeight(progress: progress, referenceDate: referenceDate)
            return WeightedWord(word: word, weight: weight, isReviewWord: weight > reviewThreshold)
        }
    }

    /// Взвешенно-случайный выбор одного слова. randomValue — число в [0, 1), по умолчанию
    /// настоящий случайный источник; параметр существует, чтобы тесты могли задать
    /// детерминированное значение и проверить конкретный исход.
    static func pickRandom(from weightedWords: [WeightedWord], randomValue: Double = Double.random(in: 0..<1)) -> WeightedWord? {
        guard !weightedWords.isEmpty else { return nil }

        let totalWeight = weightedWords.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return weightedWords.randomElement() }

        var target = randomValue * totalWeight
        for weighted in weightedWords {
            if target < weighted.weight {
                return weighted
            }
            target -= weighted.weight
        }
        return weightedWords.last
    }

    private static func computeWeight(progress: WordProgressSnapshot?, referenceDate: Date) -> Double {
        guard let progress else { return baseWeight }

        var weight = baseWeight
        weight += Double(progress.timesIncorrect) * 2.0
        weight -= min(Double(progress.timesCorrect) * 0.3, 2.0)

        if let lastReviewed = progress.lastReviewed {
            let days = Calendar.current.dateComponents([.day], from: lastReviewed, to: referenceDate).day ?? 0
            weight += min(Double(days) * 0.5, 5.0)
        }

        return max(weight, 0.2)
    }
}
