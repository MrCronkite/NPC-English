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
    func scheduleDailyStreakReminder()
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

    func scheduleDailyStreakReminder() {
        let content = UNMutableNotificationContent()
        content.title = "English Words"
        content.body = "Не теряй стрик — осталось позаниматься сегодня!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    /// Отменяет уведомление на сегодня — вызывается после того как сессия пройдена до конца.
    /// UNCalendarNotificationTrigger с repeats: true не даёт отменить только "сегодняшнее" срабатывание
    /// напрямую, поэтому отменяем весь daily-запрос и ставим заново на завтра.
    func cancelTodayStreakReminder() {
        center.removePendingNotificationRequests(
            withIdentifiers: [reminderIdentifier]
        )
        scheduleReminderStartingTomorrow()
    }

    private func scheduleReminderStartingTomorrow() {
        let content = UNMutableNotificationContent()
        content.title = "English Words"
        content.body = "Не теряй стрик — осталось позаниматься сегодня!"
        content.sound = .default

        guard let tomorrow = Calendar.current.date(
            byAdding: .day,
            value: 1, to: Date()
        ) else { return }

        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: tomorrow
        )
        dateComponents.hour = 20
        dateComponents.minute = 0

        // Разовое срабатывание завтра в 20:00, а не repeats: true —
        // после показа этот конкретный триггер выполнит себя один раз и завершится.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }
}

/// Для превью и тестов
final class MockNotificationManager: NotificationScheduling {
    private(set) var isScheduled = false
    private(set) var cancelCallCount = 0
    private(set) var scheduleCallCount = 0

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func scheduleDailyStreakReminder() {
        isScheduled = true
        scheduleCallCount += 1
    }

    func cancelTodayStreakReminder() {
        isScheduled = false
        cancelCallCount += 1
    }
}
