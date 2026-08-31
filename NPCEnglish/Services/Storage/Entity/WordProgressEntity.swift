//
//  WordProgressEntity.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 29.07.2026.
//

import Foundation
import CoreData

@objc(WordProgressEntity)
final class WordProgressEntity: NSManagedObject {
    @NSManaged var wordSetRaw: String
    @NSManaged var wordID: Int32
    @NSManaged var isFavorite: Bool
    @NSManaged var timesCorrect: Int32
    @NSManaged var timesIncorrect: Int32
    @NSManaged var lastReviewed: Date?
    @NSManaged var dateAdded: Date
    @NSManaged var modeRaw: String
}

extension WordProgressEntity {
    static func entityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "WordProgressEntity"
        entity.managedObjectClassName = NSStringFromClass(WordProgressEntity.self)

        let wordSetRaw = NSAttributeDescription()
        wordSetRaw.name = "wordSetRaw"
        wordSetRaw.attributeType = .stringAttributeType
        wordSetRaw.isOptional = false

        let wordID = NSAttributeDescription()
        wordID.name = "wordID"
        wordID.attributeType = .integer32AttributeType
        wordID.isOptional = false

        let isFavorite = NSAttributeDescription()
        isFavorite.name = "isFavorite"
        isFavorite.attributeType = .booleanAttributeType
        isFavorite.isOptional = false
        isFavorite.defaultValue = false

        let timesCorrect = NSAttributeDescription()
        timesCorrect.name = "timesCorrect"
        timesCorrect.attributeType = .integer32AttributeType
        timesCorrect.isOptional = false
        timesCorrect.defaultValue = 0

        let timesIncorrect = NSAttributeDescription()
        timesIncorrect.name = "timesIncorrect"
        timesIncorrect.attributeType = .integer32AttributeType
        timesIncorrect.isOptional = false
        timesIncorrect.defaultValue = 0

        let lastReviewed = NSAttributeDescription()
        lastReviewed.name = "lastReviewed"
        lastReviewed.attributeType = .dateAttributeType
        lastReviewed.isOptional = true

        let dateAdded = NSAttributeDescription()
        dateAdded.name = "dateAdded"
        dateAdded.attributeType = .dateAttributeType
        dateAdded.isOptional = false

        let modeRaw = NSAttributeDescription()
        modeRaw.name = "modeRaw"
        modeRaw.attributeType = .stringAttributeType
        modeRaw.isOptional = false
        modeRaw.defaultValue = QuizMode.multipleChoice.rawValue

        entity.properties = [wordSetRaw, wordID, isFavorite, timesCorrect, timesIncorrect, lastReviewed, dateAdded, modeRaw]
        entity.uniquenessConstraints = [["wordSetRaw", "wordID", "modeRaw"]]

        return entity
    }
}
