//
//  NPCEnglishWidget.swift
//  NPCEnglishWidget
//
//  Created by Влад Шимченко on 02.08.2026.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct StreakEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
}

// MARK: - Timeline Provider

struct StreakProvider: TimelineProvider {
    private let statsManager: StatsManaging = {
        let stack = CoreDataStack()
        return CoreDataStatsManager(context: stack.viewContext)
    }()

    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), currentStreak: 5)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: Date(), currentStreak: statsManager.currentStreak))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = StreakEntry(date: Date(), currentStreak: statsManager.currentStreak)
        // Виджет сам себя не обновляет по расписанию — актуальные данные подтягиваются
        // через WidgetCenter.reloadTimelines() из приложения. .never значит "жди явного reload".
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - View

struct StreakWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            Text("\(entry.currentStreak)")
                .font(.system(size: 34, weight: .bold, design: .rounded))

            Text(entry.currentStreak == 1 ? "день подряд" : "дней подряд")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "englishwords://quiz"))
    }
}

// MARK: - Widget

struct NPCEnglishWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Стрик")
        .description("Сколько дней подряд ты занимаешься.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    NPCEnglishWidget()
} timeline: {
    StreakEntry(date: .now, currentStreak: 5)
    StreakEntry(date: .now, currentStreak: 12)
}
