//
//  DailyStatEntity.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.07.2026.
//

import Foundation
import CoreData


@objc(DailyStatEntity)
final class DailyStatEntity: NSManagedObject {
    @NSManaged var date: Date
    @NSManaged var questionsAnswered: Int32
    @NSManaged var correctAnswers: Int32
    @NSManaged var sessionsCompleted: Int32
}

extension DailyStatEntity {
    static func entityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "DailyStatEntity"
        entity.managedObjectClassName = NSStringFromClass(DailyStatEntity.self)

        let date = NSAttributeDescription()
        date.name = "date"
        date.attributeType = .dateAttributeType
        date.isOptional = false

        let questionsAnswered = NSAttributeDescription()
        questionsAnswered.name = "questionsAnswered"
        questionsAnswered.attributeType = .integer32AttributeType
        questionsAnswered.defaultValue = 0

        let correctAnswers = NSAttributeDescription()
        correctAnswers.name = "correctAnswers"
        correctAnswers.attributeType = .integer32AttributeType
        correctAnswers.defaultValue = 0

        let sessionsCompleted = NSAttributeDescription()
        sessionsCompleted.name = "sessionsCompleted"
        sessionsCompleted.attributeType = .integer32AttributeType
        sessionsCompleted.defaultValue = 0

        entity.properties = [date, questionsAnswered, correctAnswers, sessionsCompleted]
        entity.uniquenessConstraints = [["date"]]
        return entity
    }
}
