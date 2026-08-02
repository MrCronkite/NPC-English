//
//  CoreDataStack.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 29.07.2026.
//

import Foundation
import CoreData

final class CoreDataStack {
    let persistentContainer: NSPersistentContainer

    private static let sharedModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        model.entities = [
            WordProgressEntity.entityDescription(),
            AppStatsEntity.entityDescription(),
            DailyStatEntity.entityDescription()
        ]
        return model
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private static let appGroupID = "group.com.main.npcenglish"

    init(
        modelName: String = "EnglishWordsModel",
        inMemory: Bool = false
    ) {
        persistentContainer = NSPersistentContainer(
            name: modelName,
            managedObjectModel: Self.sharedModel
        )

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            persistentContainer.persistentStoreDescriptions = [description]
        } else if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID) {
            let storeURL = groupURL.appendingPathComponent("\(modelName).sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            persistentContainer.persistentStoreDescriptions = [description]
        } else {
            print("⚠️ Не удалось получить App Group container — проверь идентификатор группы в Xcode")
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Не удалось загрузить CoreData store: \(error)")
            }
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [
            WordProgressEntity.entityDescription(),
            AppStatsEntity.entityDescription(),
            DailyStatEntity.entityDescription()
        ]
        return model
    }
}
