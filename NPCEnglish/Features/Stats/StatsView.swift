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
    @Environment(\.dismiss) private var dismiss

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
            VStack(spacing: 20) {
                header

                HStack(spacing: 16) {
                    statCard(icon: "flame.fill", iconBackground: .orange, value: "\(statsManager.currentStreak)", valueColor: .orange, label: "Текущий стрик")
                    statCard(icon: "trophy.fill", iconBackground: .yellow, value: "\(statsManager.longestStreak)", valueColor: .yellow, label: "Лучший стрик")
                }
                .padding(.horizontal)

                accuracyCard
                    .padding(.horizontal)

                activityChartCard
                    .padding(.horizontal)
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }

            Text("Статистика")
                .font(.largeTitle.bold())

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Streak cards

    private func statCard(icon: String, iconBackground: Color, value: String, valueColor: Color, label: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBackground.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundStyle(iconBackground)
            }

            Text(value)
                .font(.system(size: 40, weight: .heavy))
                .foregroundStyle(valueColor)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Accuracy card

    private var accuracyCard: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(accuracyPercent)%")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(.green)

                Text("Точность")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Activity chart card

    private var activityChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Активность за 14 дней")
                    .font(.headline)

                Spacer()

                Image(systemName: "info.circle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Chart(dailyStats) { stat in
                BarMark(
                    x: .value("День", stat.date, unit: .day),
                    y: .value("Вопросов", stat.questionsAnswered)
                )
                .foregroundStyle(Color.accentColor)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(Color(.systemGray4))
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 220)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

