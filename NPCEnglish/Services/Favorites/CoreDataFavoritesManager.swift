//
//  CoreDataFavoritesManager.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 29.07.2026.
//

import Foundation
import CoreData


protocol FavoritesManaging {
    func isFavorite(wordID: Int, in wordSet: WordSet) -> Bool
    func toggleFavorite(wordID: Int, in wordSet: WordSet)
    func favoriteWordIDs(in wordSet: WordSet) -> [Int]
}


final class CoreDataFavoritesManager: FavoritesManaging {
    private let repository: GenericCoreDataRepository<WordProgressEntity>

    init(context: NSManagedObjectContext) {
        self.repository = GenericCoreDataRepository(
            context: context,
            entityName: "WordProgressEntity"
        )
    }

    func isFavorite(wordID: Int, in wordSet: WordSet) -> Bool {
        findEntity(wordID: wordID, in: wordSet)?.isFavorite ?? false
    }

    func toggleFavorite(wordID: Int, in wordSet: WordSet) {
        if let entity = findEntity(wordID: wordID, in: wordSet) {
            entity.isFavorite.toggle()
        } else {
            let entity = repository.insert()
            entity.wordSetRaw = wordSet.rawValue
            entity.wordID = Int32(wordID)
            entity.isFavorite = true
            entity.timesCorrect = 0
            entity.timesIncorrect = 0
            entity.dateAdded = Date()
        }

        do {
            try repository.save()
        } catch {
            print("⚠️ Не удалось сохранить избранное: \(error)")
        }
    }

    func favoriteWordIDs(in wordSet: WordSet) -> [Int] {
        let predicate = NSPredicate(format: "wordSetRaw == %@ AND isFavorite == YES", wordSet.rawValue)
        return repository.fetch(predicate: predicate, sortDescriptors: []).map { Int($0.wordID) }
    }

    private func findEntity(wordID: Int, in wordSet: WordSet) -> WordProgressEntity? {
        let predicate = NSPredicate(format: "wordSetRaw == %@ AND wordID == %d", wordSet.rawValue, wordID)
        return repository.fetch(predicate: predicate, sortDescriptors: []).first
    }
}

/// Для SwiftUI Preview и юнит-тестов — без реальной CoreData
final class MockFavoritesManager: FavoritesManaging {
    private var favorites: Set<String> = []

    private func key(_ wordID: Int, _ wordSet: WordSet) -> String { "\(wordSet.rawValue):\(wordID)" }

    func isFavorite(wordID: Int, in wordSet: WordSet) -> Bool {
        favorites.contains(key(wordID, wordSet))
    }

    func toggleFavorite(wordID: Int, in wordSet: WordSet) {
        let k = key(wordID, wordSet)
        if favorites.contains(k) { favorites.remove(k) } else { favorites.insert(k) }
    }

    func favoriteWordIDs(in wordSet: WordSet) -> [Int] {
        favorites.compactMap { k in
            let parts = k.split(separator: ":")
            guard parts.count == 2, parts[0] == wordSet.rawValue, let id = Int(parts[1]) else { return nil }
            return id
        }
    }
}
