//
//  CoreDataRepository.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 29.07.2026.
//

import Foundation
import CoreData


protocol CoreDataRepository {
    associatedtype Entity: NSManagedObject

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) -> [Entity]
    func insert() -> Entity
    func delete(_ object: Entity)
    func save() throws
}

final class GenericCoreDataRepository<Entity: NSManagedObject>: CoreDataRepository {
    private let context: NSManagedObjectContext
    private let entityName: String

    init(context: NSManagedObjectContext, entityName: String) {
        self.context = context
        self.entityName = entityName
    }

    func fetch(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = []
    ) -> [Entity] {
        let request = NSFetchRequest<Entity>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return (try? context.fetch(request)) ?? []
    }

    func insert() -> Entity {
        Entity(context: context)
    }

    func delete(_ object: Entity) {
        context.delete(object)
    }

    func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
