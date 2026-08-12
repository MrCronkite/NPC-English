//
//  StreakNotificationManager.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 07.08.2026.
//

import Foundation
import UserNotifications

protocol NotificationScheduling {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func scheduleDailyStreakReminder(hour: Int, minute: Int)
    func cancelTodayStreakReminder()
}

final class StreakNotificationManager: NotificationScheduling {
    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifier = "streak_reminder"

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleDailyStreakReminder(hour: Int, minute: Int) {
        // Отменяем предыдущее запланированное уведомление перед тем как ставить новое —
        // иначе при смене времени в настройках старое и новое будут висеть одновременно.
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "English Words"
        content.body = "Не теряй стрик — осталось позаниматься сегодня!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)

        center.add(request)
    }

    func cancelTodayStreakReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        scheduleReminderStartingTomorrow()
    }

    private func scheduleReminderStartingTomorrow() {
        let hour = UserDefaults.standard.object(forKey: "streakReminderHour") as? Int ?? 20
        let minute = UserDefaults.standard.object(forKey: "streakReminderMinute") as? Int ?? 0

        let content = UNMutableNotificationContent()
        content.title = "English Words"
        content.body = "Не теряй стрик — осталось позаниматься сегодня!"
        content.sound = .default

        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else { return }
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)

        center.add(request)
    }
}

/// Для превью и тестов
final class MockNotificationManager: NotificationScheduling {
    private(set) var isScheduled = false
    private(set) var cancelCallCount = 0
    private(set) var scheduleCallCount = 0
    private(set) var lastScheduledHour: Int?
    private(set) var lastScheduledMinute: Int?

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func scheduleDailyStreakReminder(hour: Int, minute: Int) {
        isScheduled = true
        scheduleCallCount += 1
        lastScheduledHour = hour
        lastScheduledMinute = minute
    }

    func cancelTodayStreakReminder() {
        isScheduled = false
        cancelCallCount += 1
    }
}
