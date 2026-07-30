//
//  AppStatsEntity.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.07.2026.
//

import Foundation
import CoreData

@objc(AppStatsEntity)
final class AppStatsEntity: NSManagedObject {
    @NSManaged var currentStreak: Int32
    @NSManaged var longestStreak: Int32
    @NSManaged var lastCompletedDay: Date?
    @NSManaged var totalQuestionsAnswered: Int32
    @NSManaged var totalCorrectAnswers: Int32
}

extension AppStatsEntity {
    static func entityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "AppStatsEntity"
        entity.managedObjectClassName = NSStringFromClass(AppStatsEntity.self)

        let currentStreak = NSAttributeDescription()
        currentStreak.name = "currentStreak"
        currentStreak.attributeType = .integer32AttributeType
        currentStreak.defaultValue = 0

        let longestStreak = NSAttributeDescription()
        longestStreak.name = "longestStreak"
        longestStreak.attributeType = .integer32AttributeType
        longestStreak.defaultValue = 0

        let lastCompletedDay = NSAttributeDescription()
        lastCompletedDay.name = "lastCompletedDay"
        lastCompletedDay.attributeType = .dateAttributeType
        lastCompletedDay.isOptional = true

        let totalQuestionsAnswered = NSAttributeDescription()
        totalQuestionsAnswered.name = "totalQuestionsAnswered"
        totalQuestionsAnswered.attributeType = .integer32AttributeType
        totalQuestionsAnswered.defaultValue = 0

        let totalCorrectAnswers = NSAttributeDescription()
        totalCorrectAnswers.name = "totalCorrectAnswers"
        totalCorrectAnswers.attributeType = .integer32AttributeType
        totalCorrectAnswers.defaultValue = 0

        entity.properties = [currentStreak, longestStreak, lastCompletedDay, totalQuestionsAnswered, totalCorrectAnswers]
        return entity
    }
}


