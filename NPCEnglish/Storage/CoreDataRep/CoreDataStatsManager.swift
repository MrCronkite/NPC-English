//
//  CoreDataStatsManager.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.07.2026.
//

import Foundation
import CoreData
import WidgetKit

protocol StatsManaging {
    var currentStreak: Int { get }
    var longestStreak: Int { get }
    var totalStats: (answered: Int, correct: Int) { get }

    /// Вызывается один раз при завершении сессии до конца
    func recordSessionCompleted(score: Int, total: Int)

    /// Статистика по последним N дням (включая сегодня), отсортирована по дате по возрастанию
    func dailyStats(lastDays: Int) -> [DailyStat]
}


final class CoreDataStatsManager: StatsManaging {
    private let appStatsRepository: GenericCoreDataRepository<AppStatsEntity>
    private let dailyStatsRepository: GenericCoreDataRepository<DailyStatEntity>
    private let notificationManager: NotificationScheduling
    private let calendar = Calendar.current

    init(
        context: NSManagedObjectContext,
        notificationManager: NotificationScheduling
    ) {
        appStatsRepository = GenericCoreDataRepository(
            context: context,
            entityName: "AppStatsEntity"
        )

        dailyStatsRepository = GenericCoreDataRepository(
            context: context,
            entityName: "DailyStatEntity"
        )

        self.notificationManager = notificationManager
    }

    var currentStreak: Int { Int(fetchOrCreateAppStats().currentStreak) }
    var longestStreak: Int { Int(fetchOrCreateAppStats().longestStreak) }

    var totalStats: (answered: Int, correct: Int) {
        let stats = fetchOrCreateAppStats()
        return (Int(stats.totalQuestionsAnswered), Int(stats.totalCorrectAnswers))
    }

    func recordSessionCompleted(score: Int, total: Int) {
        let today = calendar.startOfDay(for: Date())
        
        updateDailyStat(day: today, questionsAnswered: total, correctAnswers: score)
        updateStreakAndTotals(day: today, questionsAnswered: total, correctAnswers: score)
        
        do {
            try appStatsRepository.save()
            WidgetCenter.shared.reloadTimelines(ofKind: "StreakWidget")
            notificationManager.cancelTodayStreakReminder()
        } catch {
            print("⚠️ Не удалось сохранить статистику: \(error)")
        }
    }

    func dailyStats(lastDays: Int) -> [DailyStat] {
        guard let fromDate = calendar.date(byAdding: .day, value: -(lastDays - 1), to: calendar.startOfDay(for: Date())) else {
            return []
        }
        let predicate = NSPredicate(format: "date >= %@", fromDate as NSDate)
        let sort = NSSortDescriptor(key: "date", ascending: true)
        let entities = dailyStatsRepository.fetch(predicate: predicate, sortDescriptors: [sort])

        return entities.map {
            DailyStat(date: $0.date, questionsAnswered: Int($0.questionsAnswered), correctAnswers: Int($0.correctAnswers))
        }
    }

    // MARK: - Private

    private func fetchOrCreateAppStats() -> AppStatsEntity {
        if let existing = appStatsRepository.fetch(predicate: nil, sortDescriptors: []).first {
            return existing
        }
        let entity = appStatsRepository.insert()
        entity.currentStreak = 0
        entity.longestStreak = 0
        entity.lastCompletedDay = nil
        entity.totalQuestionsAnswered = 0
        entity.totalCorrectAnswers = 0
        return entity
    }

    private func updateDailyStat(day: Date, questionsAnswered: Int, correctAnswers: Int) {
        let predicate = NSPredicate(format: "date == %@", day as NSDate)
        let entity = dailyStatsRepository.fetch(predicate: predicate, sortDescriptors: []).first ?? {
            let new = dailyStatsRepository.insert()
            new.date = day
            new.questionsAnswered = 0
            new.correctAnswers = 0
            new.sessionsCompleted = 0
            return new
        }()

        entity.questionsAnswered += Int32(questionsAnswered)
        entity.correctAnswers += Int32(correctAnswers)
        entity.sessionsCompleted += 1
    }

    private func updateStreakAndTotals(day: Date, questionsAnswered: Int, correctAnswers: Int) {
        let stats = fetchOrCreateAppStats()

        stats.totalQuestionsAnswered += Int32(questionsAnswered)
        stats.totalCorrectAnswers += Int32(correctAnswers)

        if let lastDay = stats.lastCompletedDay {
            if calendar.isDate(lastDay, inSameDayAs: day) {
                // Уже засчитан день — стрик не трогаем, только тоталы (уже обновили выше)
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: day),
                      calendar.isDate(lastDay, inSameDayAs: yesterday) {
                stats.currentStreak += 1
            } else {
                stats.currentStreak = 1
            }
        } else {
            stats.currentStreak = 1
        }

        stats.longestStreak = max(stats.longestStreak, stats.currentStreak)
        stats.lastCompletedDay = day
    }
}

/// Для превью и тестов
final class MockStatsManager: StatsManaging {
    var currentStreak: Int = 3
    var longestStreak: Int = 7
    var totalStats: (answered: Int, correct: Int) = (120, 96)

    func recordSessionCompleted(score: Int, total: Int) {}

    func dailyStats(lastDays: Int) -> [DailyStat] {
        (0..<lastDays).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            return DailyStat(date: date, questionsAnswered: Int.random(in: 0...15), correctAnswers: Int.random(in: 0...12))
        }.reversed()
    }
}
