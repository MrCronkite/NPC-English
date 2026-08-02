//
//  MiniStatsWidgetView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 02.08.2026.
//

import SwiftUI
import CoreData

struct MiniStatsWidgetView: View {
    let statsManager: StatsManaging
    @State private var refreshTrigger = 0

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 2) {
                Label("\(statsManager.currentStreak) дней подряд", systemImage: "flame.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                Text("Лучший результат: \(statsManager.longestStreak)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            weekBars
        }
        .padding(.vertical, 4)
        .id(refreshTrigger)
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            refreshTrigger += 1
        }
    }

    private var weekBars: some View {
        let last7Days = statsManager.dailyStats(lastDays: 7)
        let maxValue = max(last7Days.map(\.questionsAnswered).max() ?? 1, 1)

        return HStack(alignment: .bottom, spacing: 4) {
            ForEach(last7Days) { stat in
                RoundedRectangle(cornerRadius: 2)
                    .fill(stat.questionsAnswered > 0 ? Color.accentColor : Color(.systemGray5))
                    .frame(width: 6, height: max(4, CGFloat(stat.questionsAnswered) / CGFloat(maxValue) * 32))
            }
        }
        .frame(height: 32)
    }
}
