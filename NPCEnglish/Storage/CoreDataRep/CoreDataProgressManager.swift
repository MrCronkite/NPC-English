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

    func snapshot(for wordSet: WordSet) -> [Int: WordProgressSnapshot] {
        let predicate = NSPredicate(format: "wordSetRaw == %@", wordSet.rawValue)
        let entities = repository.fetch(predicate: predicate, sortDescriptors: [])

        var result: [Int: WordProgressSnapshot] = [:]
        for entity in entities {
            result[Int(entity.wordID)] = WordProgressSnapshot(
                timesCorrect: Int(entity.timesCorrect),
                timesIncorrect: Int(entity.timesIncorrect),
                lastReviewed: entity.lastReviewed
            )
        }
        return result
    }

    func recordAnswer(wordID: Int, in wordSet: WordSet, isCorrect: Bool) {
        let entity = findOrCreateEntity(wordID: wordID, in: wordSet)

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

    private func findOrCreateEntity(wordID: Int, in wordSet: WordSet) -> WordProgressEntity {
        let predicate = NSPredicate(format: "wordSetRaw == %@ AND wordID == %d", wordSet.rawValue, wordID)

        if let existing = repository.fetch(predicate: predicate, sortDescriptors: []).first {
            return existing
        }

        let entity = repository.insert()
        entity.wordSetRaw = wordSet.rawValue
        entity.wordID = Int32(wordID)
        entity.isFavorite = false
        entity.timesCorrect = 0
        entity.timesIncorrect = 0
        entity.dateAdded = Date()
        return entity
    }
}

/// Для превью и тестов
final class MockProgressManager: WordProgressTracking {
    private var records: [String: WordProgressSnapshot] = [:]
    private(set) var recordAnswerCallCount = 0

    func snapshot(for wordSet: WordSet) -> [Int: WordProgressSnapshot] {
        var result: [Int: WordProgressSnapshot] = [:]
        for (key, value) in records where key.hasPrefix("\(wordSet.rawValue):") {
            if let idString = key.split(separator: ":").last, let id = Int(idString) {
                result[id] = value
            }
        }
        return result
    }

    func recordAnswer(wordID: Int, in wordSet: WordSet, isCorrect: Bool) {
        recordAnswerCallCount += 1
        let key = "\(wordSet.rawValue):\(wordID)"
        let existing = records[key] ?? WordProgressSnapshot(timesCorrect: 0, timesIncorrect: 0, lastReviewed: nil)
        records[key] = WordProgressSnapshot(
            timesCorrect: existing.timesCorrect + (isCorrect ? 1 : 0),
            timesIncorrect: existing.timesIncorrect + (isCorrect ? 0 : 1),
            lastReviewed: Date()
        )
    }

    /// Тестовый хелпер — задать снэпшот напрямую, без прохождения через recordAnswer
    func seed(wordID: Int, in wordSet: WordSet, snapshot: WordProgressSnapshot) {
        records["\(wordSet.rawValue):\(wordID)"] = snapshot
    }
}
