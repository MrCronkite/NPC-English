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

    init(
        modelName: String = "EnglishWordsModel",
        inMemory: Bool = false
    ) {
        let model = CoreDataStack.makeModel()
        
        persistentContainer = NSPersistentContainer(
            name: modelName,
            managedObjectModel: model
        )

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            persistentContainer.persistentStoreDescriptions = [description]
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Не удалось загрузить CoreData store: \(error)")
            }
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
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
