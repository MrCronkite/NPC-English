//
//  WordProgressTracking.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 18.08.2026.
//

import Foundation

protocol WordProgressTracking {
    /// Снэпшот прогресса по всем словам конкретного набора — читается один раз в начале сессии
    func snapshot(for wordSet: WordSet) -> [Int: WordProgressSnapshot]

    /// Записывает результат ответа. Создаёт запись прогресса, если её ещё не было
    /// (раньше запись создавалась только при добавлении в избранное — теперь и здесь).
    func recordAnswer(wordID: Int, in wordSet: WordSet, isCorrect: Bool)
}

struct WordProgressSnapshot {
    let timesCorrect: Int
    let timesIncorrect: Int
    let lastReviewed: Date?
}
