//
//  CoreDataProgressManager.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 18.08.2026.
//

import Foundation
import CoreData

final class CoreDataProgressManager: WordProgressTracking {
    private let repository: GenericCoreDataRepository<WordProgressEntity>

    init(context: NSManagedObjectContext) {
        self.repository = GenericCoreDataRepository(context: context, entityName: "WordProgressEntity")
    }

    func snapshot(for wordSet: WordSet, category: WordCategory?) -> [Int: WordProgressSnapshot] {
        let key = storageKey(wordSet: wordSet, category: category)
        let predicate = NSPredicate(format: "wordSetRaw == %@", key)
        let entities = repository.fetch(predicate: predicate, sortDescriptors: [])

        // Для spaced repetition агрегируем прогресс по обоим режимам вместе —
        // если слово выучено в квизе, это тоже снижает его вес и в режиме печати.
        var aggregated: [Int: (correct: Int, incorrect: Int, lastReviewed: Date?)] = [:]
        for entity in entities {
            let wordID = Int(entity.wordID)
            var current = aggregated[wordID] ?? (0, 0, nil)
            current.correct += Int(entity.timesCorrect)
            current.incorrect += Int(entity.timesIncorrect)
            if let reviewed = entity.lastReviewed {
                current.lastReviewed = max(current.lastReviewed ?? .distantPast, reviewed)
            }
            aggregated[wordID] = current
        }

        return aggregated.mapValues { WordProgressSnapshot(timesCorrect: $0.correct, timesIncorrect: $0.incorrect, lastReviewed: $0.lastReviewed) }
    }

    func recordAnswer(wordID: Int, in wordSet: WordSet, category: WordCategory?, mode: QuizMode, isCorrect: Bool) {
        let entity = findOrCreateEntity(wordID: wordID, wordSet: wordSet, category: category, mode: mode)

        if isCorrect {
            entity.timesCorrect += 1
        } else {
            entity.timesIncorrect += 1
        }
        entity.lastReviewed = Date()

        do {
            try repository.save()
        } catch {
            print("⚠️ Не удалось сохранить прогресс слова: \(error)")
        }
    }

    func totalLearnedWordsCount(mode: QuizMode) -> Int {
        let predicate = NSPredicate(format: "modeRaw == %@ AND timesCorrect >= 1", mode.rawValue)
        return repository.fetch(predicate: predicate, sortDescriptors: []).count
    }

    func isWordSetFullyLearned(_ words: [Word], wordSet: WordSet, category: WordCategory?, mode: QuizMode) -> Bool {
        guard !words.isEmpty else { return false }

        let key = storageKey(wordSet: wordSet, category: category)
        let predicate = NSPredicate(format: "wordSetRaw == %@ AND modeRaw == %@ AND timesCorrect >= 1", key, mode.rawValue)
        let learnedIDs = Set(repository.fetch(predicate: predicate, sortDescriptors: []).map { Int($0.wordID) })

        return words.allSatisfy { learnedIDs.contains($0.id) }
    }

    private func findOrCreateEntity(wordID: Int, wordSet: WordSet, category: WordCategory?, mode: QuizMode) -> WordProgressEntity {
        let key = storageKey(wordSet: wordSet, category: category)
        let predicate = NSPredicate(format: "wordSetRaw == %@ AND wordID == %d AND modeRaw == %@", key, wordID, mode.rawValue)

        if let existing = repository.fetch(predicate: predicate, sortDescriptors: []).first {
            return existing
        }

        let entity = repository.insert()
        entity.wordSetRaw = key
        entity.wordID = Int32(wordID)
        entity.modeRaw = mode.rawValue
        entity.isFavorite = false
        entity.timesCorrect = 0
        entity.timesIncorrect = 0
        entity.dateAdded = Date()
        return entity
    }

    private func storageKey(wordSet: WordSet, category: WordCategory?) -> String {
        if let category {
            return "\(wordSet.rawValue)_\(category.rawValue)"
        }
        return wordSet.rawValue
    }
    
    func recordPerfectSession(mode: QuizMode) {
        UserDefaults.standard.set(true, forKey: perfectSessionKey(for: mode))
    }
    
    func hasPerfectSession(mode: QuizMode) -> Bool {
        UserDefaults.standard.bool(forKey: perfectSessionKey(for: mode))
    }
    
    private func perfectSessionKey(for mode: QuizMode) -> String {
        "hasPerfectSession_\(mode.rawValue)"
    }
}
