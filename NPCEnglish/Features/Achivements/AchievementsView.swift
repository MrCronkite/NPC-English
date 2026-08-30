//
//  AchievementsView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.08.2026.
//

import SwiftUI

struct AchievementsView: View {
    let achievementsManager: AchievementsManaging
    let progressTracker: WordProgressTracking

    @Environment(\.dismiss) private var dismiss

    private var quizAchievements: [Achievement] {
        AchievementCatalog.all.filter { $0.mode == .multipleChoice }
    }

    private var typingAchievements: [Achievement] {
        AchievementCatalog.all.filter { $0.mode == .typing }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header

                section(title: "Квиз", achievements: quizAchievements)
                section(title: "Напиши перевод", achievements: typingAchievements)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

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

            Text("Достижения")
                .font(.largeTitle.bold())

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private func section(title: String, achievements: [Achievement]) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)

            VStack(spacing: 12) {
                ForEach(achievements) { achievement in
                    achievementRow(achievement)
                }
            }
        }
        .padding(.horizontal)
    }

    private func achievementRow(_ achievement: Achievement) -> some View {
        let isUnlocked = achievementsManager.isUnlocked(achievement.id)
        let progress = min(achievement.currentProgress(progressTracker), achievement.targetProgress)

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.15) : Color(.systemGray5))
                    .frame(width: 52, height: 52)

                // Placeholder — замени системную иконку на кастомную из achievement.iconName,
                // когда будут готовы твои иконки
                Image(systemName: isUnlocked ? "star.fill" : "lock.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(isUnlocked ? .yellow : .secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)

                if isUnlocked {
                    if let date = achievementsManager.unlockedDate(for: achievement.id) {
                        Text("Получено \(date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ProgressView(value: Double(progress), total: Double(achievement.targetProgress))
                        .tint(Color.accentColor)

                    Text("\(progress)/\(achievement.targetProgress)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
