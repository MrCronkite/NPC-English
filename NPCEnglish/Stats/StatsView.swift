//
//  StatsView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.07.2026.
//

import SwiftUI
import Charts

struct StatsView: View {
    let statsManager: StatsManaging

    private var dailyStats: [DailyStat] {
        statsManager.dailyStats(lastDays: 14)
    }

    private var accuracyPercent: Int {
        let stats = statsManager.totalStats
        guard stats.answered > 0 else { return 0 }
        return Int((Double(stats.correct) / Double(stats.answered)) * 100)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    statCard(icon: "flame.fill", color: .orange, value: "\(statsManager.currentStreak)", label: "Текущий стрик")
                    statCard(icon: "trophy.fill", color: .yellow, value: "\(statsManager.longestStreak)", label: "Лучший стрик")
                }

                statCard(
                    icon: "checkmark.seal.fill",
                    color: .green,
                    value: "\(accuracyPercent)%",
                    label: "Точность · \(statsManager.totalStats.correct) из \(statsManager.totalStats.answered) вопросов",
                    fullWidth: true
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Активность за 14 дней")
                        .font(.headline)

                    Chart(dailyStats) { stat in
                        BarMark(
                            x: .value("День", stat.date, unit: .day),
                            y: .value("Вопросов", stat.questionsAnswered)
                        )
                        .foregroundStyle(Color.accentColor)
                    }
                    .frame(height: 180)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle("Статистика")
    }

    private func statCard(icon: String, color: Color, value: String, label: String, fullWidth: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

