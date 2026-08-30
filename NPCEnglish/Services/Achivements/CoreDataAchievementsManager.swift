//
//  CoreDataAchievementsManager.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.08.2026.
//

import Foundation
import CoreData

protocol AchievementsManaging {
    /// Проверяет весь каталог достижений против текущего прогресса, разблокирует новые.
    /// Возвращает список только что разблокированных достижений (для показа алерта).
    @discardableResult
    func checkAndUnlockAchievements(progressTracker: WordProgressTracking) -> [Achievement]

    func isUnlocked(_ achievementID: String) -> Bool
    func unlockedDate(for achievementID: String) -> Date?
}

final class CoreDataAchievementsManager: AchievementsManaging {
    private let repository: GenericCoreDataRepository<UnlockedAchievementEntity>

    init(context: NSManagedObjectContext) {
        self.repository = GenericCoreDataRepository(context: context, entityName: "UnlockedAchievementEntity")
    }

    func checkAndUnlockAchievements(progressTracker: WordProgressTracking) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        for achievement in AchievementCatalog.all where !isUnlocked(achievement.id) {
            let progress = achievement.currentProgress(progressTracker)
            if progress >= achievement.targetProgress {
                unlock(achievement.id)
                newlyUnlocked.append(achievement)
            }
        }

        return newlyUnlocked
    }

    func isUnlocked(_ achievementID: String) -> Bool {
        let predicate = NSPredicate(format: "achievementID == %@", achievementID)
        return !repository.fetch(predicate: predicate, sortDescriptors: []).isEmpty
    }

    func unlockedDate(for achievementID: String) -> Date? {
        let predicate = NSPredicate(format: "achievementID == %@", achievementID)
        return repository.fetch(predicate: predicate, sortDescriptors: []).first?.unlockedDate
    }

    private func unlock(_ achievementID: String) {
        let entity = repository.insert()
        entity.achievementID = achievementID
        entity.unlockedDate = Date()

        do {
            try repository.save()
        } catch {
            print("⚠️ Не удалось сохранить разблокированное достижение: \(error)")
        }
    }
}

/// Для превью и тестов
final class MockAchievementsManager: AchievementsManaging {
    private var unlocked: [String: Date] = [:]

    func checkAndUnlockAchievements(progressTracker: WordProgressTracking) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        for achievement in AchievementCatalog.all where unlocked[achievement.id] == nil {
            let progress = achievement.currentProgress(progressTracker)
            if progress >= achievement.targetProgress {
                unlocked[achievement.id] = Date()
                newlyUnlocked.append(achievement)
            }
        }
        return newlyUnlocked
    }

    func isUnlocked(_ achievementID: String) -> Bool {
        unlocked[achievementID] != nil
    }

    func unlockedDate(for achievementID: String) -> Date? {
        unlocked[achievementID]
    }
}
