//
//  UnlockedAchievementEntity.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.08.2026.
//

import Foundation
import CoreData

@objc(UnlockedAchievementEntity)
final class UnlockedAchievementEntity: NSManagedObject {
    @NSManaged var achievementID: String
    @NSManaged var unlockedDate: Date
}

extension UnlockedAchievementEntity {
    static func entityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "UnlockedAchievementEntity"
        entity.managedObjectClassName = NSStringFromClass(UnlockedAchievementEntity.self)

        let achievementID = NSAttributeDescription()
        achievementID.name = "achievementID"
        achievementID.attributeType = .stringAttributeType
        achievementID.isOptional = false

        let unlockedDate = NSAttributeDescription()
        unlockedDate.name = "unlockedDate"
        unlockedDate.attributeType = .dateAttributeType
        unlockedDate.isOptional = false

        entity.properties = [achievementID, unlockedDate]
        entity.uniquenessConstraints = [["achievementID"]]

        return entity
    }
}
