//
//  WordProgressTracking.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 18.08.2026.
//

import Foundation

protocol WordProgressTracking {
    func snapshot(for wordSet: WordSet, category: WordCategory?) -> [Int: WordProgressSnapshot]
    func recordAnswer(wordID: Int, in wordSet: WordSet, category: WordCategory?, mode: QuizMode, isCorrect: Bool)
    func totalLearnedWordsCount(mode: QuizMode) -> Int
    func isWordSetFullyLearned(_ words: [Word], wordSet: WordSet, category: WordCategory?, mode: QuizMode) -> Bool

    /// Отмечает, что сессия была пройдена со 100% точностью в данном режиме — вызывается
    /// один раз при завершении идеальной сессии.
    func recordPerfectSession(mode: QuizMode)

    /// Была ли хотя бы одна идеальная сессия когда-либо в данном режиме.
    func hasPerfectSession(mode: QuizMode) -> Bool
}

struct WordProgressSnapshot {
    let timesCorrect: Int
    let timesIncorrect: Int
    let lastReviewed: Date?
}

final class MockProgressManager: WordProgressTracking {
    private var records: [String: WordProgressSnapshot] = [:]
    private(set) var recordAnswerCallCount = 0
    private var perfectSessions: Set<QuizMode> = []

    // Для totalLearnedWordsCount / isWordSetFullyLearned
    private var learnedWordIDs: [QuizMode: Set<String>] = [.multipleChoice: [], .typing: []]

    func snapshot(for wordSet: WordSet, category: WordCategory?) -> [Int: WordProgressSnapshot] {
        var result: [Int: WordProgressSnapshot] = [:]
        let prefix = key(wordSet: wordSet, category: category, wordID: nil)
        for (key, value) in records where key.hasPrefix(prefix) {
            if let idString = key.split(separator: ":").last, let id = Int(idString) {
                result[id] = value
            }
        }
        return result
    }

    func recordAnswer(wordID: Int, in wordSet: WordSet, category: WordCategory?, mode: QuizMode, isCorrect: Bool) {
        recordAnswerCallCount += 1
        let k = key(wordSet: wordSet, category: category, wordID: wordID)
        let existing = records[k] ?? WordProgressSnapshot(timesCorrect: 0, timesIncorrect: 0, lastReviewed: nil)
        records[k] = WordProgressSnapshot(
            timesCorrect: existing.timesCorrect + (isCorrect ? 1 : 0),
            timesIncorrect: existing.timesIncorrect + (isCorrect ? 0 : 1),
            lastReviewed: Date()
        )

        if isCorrect {
            learnedWordIDs[mode, default: []].insert(k)
        }
    }

    func totalLearnedWordsCount(mode: QuizMode) -> Int {
        (learnedWordIDs[mode] ?? []).count
    }

    func isWordSetFullyLearned(_ words: [Word], wordSet: WordSet, category: WordCategory?, mode: QuizMode) -> Bool {
        guard !words.isEmpty else { return false }
        let learned = learnedWordIDs[mode] ?? []
        return words.allSatisfy { word in
            learned.contains(key(wordSet: wordSet, category: category, wordID: word.id))
        }
    }

    /// Тестовый хелпер — задать снэпшот напрямую, без прохождения через recordAnswer
    func seed(wordID: Int, in wordSet: WordSet, category: WordCategory? = nil, snapshot: WordProgressSnapshot) {
        records[key(wordSet: wordSet, category: category, wordID: wordID)] = snapshot
    }

    /// Тестовый хелпер — напрямую пометить слово выученным в конкретном режиме,
    /// без создания полного WordProgressSnapshot
    func markLearned(wordID: Int, in wordSet: WordSet, category: WordCategory? = nil, mode: QuizMode) {
        learnedWordIDs[mode, default: []].insert(key(wordSet: wordSet, category: category, wordID: wordID))
    }

    private func key(wordSet: WordSet, category: WordCategory?, wordID: Int?) -> String {
        let base = category.map { "\(wordSet.rawValue)_\($0.rawValue)" } ?? wordSet.rawValue
        guard let wordID else { return "\(base):" }
        return "\(base):\(wordID)"
    }
    
    func recordPerfectSession(mode: QuizMode) {
        perfectSessions.insert(mode)
    }
    
    func hasPerfectSession(mode: QuizMode) -> Bool {
        perfectSessions.contains(mode)
    }
}
