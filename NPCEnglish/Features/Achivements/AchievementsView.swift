//
//  AchievementsView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.08.2026.
//

import SwiftUI

import SwiftUI

struct AchievementsView: View {
    let achievementsManager: AchievementsManaging
    let progressTracker: WordProgressTracking

    @Environment(\.colorScheme) private var colorScheme

    private var quizAchievements: [Achievement] {
        AchievementCatalog.all.filter { $0.mode == .multipleChoice }
    }

    private var typingAchievements: [Achievement] {
        AchievementCatalog.all.filter { $0.mode == .typing }
    }

    private var backgroundImage: some View {
        Image(colorScheme == .dark ? "achievements_background_dark" : "achievements_background_light")
            .resizable()
            .scaledToFill()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            backgroundImage
                .ignoresSafeArea()

            ZStack(alignment: .top) {

                header

            ScrollView {
                    VStack(spacing: 24) {
                        section(title: "Квиз", achievements: quizAchievements)
                        section(title: "Напиши перевод", achievements: typingAchievements)
                    }
                    .padding(.vertical, 74)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 16) {
            Image("achievements_trophy_hero")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .offset(x: 50, y: -40)
        }
    }

    // MARK: - Section

    private func section(title: String, achievements: [Achievement]) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            VStack(spacing: 16) {
                ForEach(achievements) { achievement in
                    achievementRow(achievement)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Row

    private func achievementRow(_ achievement: Achievement) -> some View {
        let isUnlocked = achievementsManager.isUnlocked(achievement.id)
        let progress = min(achievement.currentProgress(progressTracker), achievement.targetProgress)

        return HStack(spacing: 16) {
            Image(isUnlocked ? achievement.iconName : "achievement_locked")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 8) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if isUnlocked {
                    if let date = achievementsManager.unlockedDate(for: achievement.id) {
                        Text("Получено \(formattedDate(date))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ProgressView(value: Double(progress), total: Double(achievement.targetProgress))
                        .tint(Color.accentColor)

                    Text("\(progress)/\(achievement.targetProgress)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.accentColor.opacity(isUnlocked ? 0.52 : 0.10))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.accentColor.opacity(isUnlocked ? 0.7 : 0.2), lineWidth: 1.5)
        )
    }
}

#Preview {
    AchievementsView(
        achievementsManager: MockAchievementsManager(),
        progressTracker: MockProgressManager()
    )
}
