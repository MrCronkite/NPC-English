//
//  StartView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import SwiftUI
import CoreData

struct StartView: View {
    let favoritesManager: FavoritesManaging
    let statsManager: StatsManaging
    let speechManager: SpeechSynthesizing
    let notificationManager: NotificationScheduling
    let progressTracker: WordProgressTracking

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    streakCard

                    sectionGroup(title: "Наборы слов", mode: .multipleChoice)
                    sectionGroup(title: "Режим: напиши перевод", mode: .typing)

                    sectionGroup(
                        title: "Избранное",
                        rows: [
                            (wordSet: WordSet.favorites, icon: "star.fill", iconColor: RowIconColor.orange,
                             title: "Мои избранные слова", subtitle: "Повторить сохранённые слова")
                        ],
                        mode: .multipleChoice
                    )

                    VStack(spacing: 0) {
                        NavigationLink {
                            SupportView()
                        } label: {
                            rowContent(
                                icon: "heart.fill",
                                iconColor: .red,
                                title: "Поддержать проект",
                                subtitle: "Приложение бесплатное — но спасибо не помешает"
                            )
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Учим английский")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: WordSetSelection.self) { selection in
                destinationView(for: selection)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(notificationManager: notificationManager)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    // MARK: - Streak card

    private var streakCard: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .padding(12)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(statsManager.currentStreak)")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                    Text("дней подряд")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                }

                Text("Так держать!")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("На этой неделе")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)

                weekBars
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private var weekBars: some View {
        let days = statsManager.dailyStats(lastDays: 7)
        let maxValue = max(days.map(\.questionsAnswered).max() ?? 1, 1)
        let labels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

        return HStack(alignment: .bottom, spacing: 10) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, stat in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(stat.questionsAnswered > 0 ? Color.orange : Color(.systemGray4))
                        .frame(width: 8, height: max(6, CGFloat(stat.questionsAnswered) / CGFloat(maxValue) * 44))

                    Text(index < labels.count ? labels[index] : "")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 64, alignment: .bottom)
    }

    // MARK: - Section group (обычные наборы слов)

    private func sectionGroup(title: String, mode: QuizMode) -> some View {
        let rows: [(wordSet: WordSet, icon: String, iconColor: RowIconColor, title: String, subtitle: String)] =
            WordSet.regularSets.map { wordSet in
                (wordSet, iconName(for: wordSet, mode: mode), rowIconColor(for: wordSet, mode: mode), wordSet.title, wordSet.subtitle)
            }

        return sectionGroup(title: title, rows: rows, mode: mode)
    }

    // MARK: - Section group (обобщённая версия, для избранного и обычных наборов)

    private func sectionGroup(
        title: String,
        rows: [(wordSet: WordSet, icon: String, iconColor: RowIconColor, title: String, subtitle: String)],
        mode: QuizMode
    ) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    NavigationLink(value: WordSetSelection(wordSet: row.wordSet, mode: mode)) {
                        rowContent(icon: row.icon, iconColor: row.iconColor, title: row.title, subtitle: row.subtitle)
                    }

                    if index < rows.count - 1 {
                        Divider().padding(.leading, 88)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .padding(.horizontal)
    }

    // MARK: - Row

    private func rowContent(icon: String, iconColor: RowIconColor, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(iconColor.color)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(16)
        .frame(minHeight: 80)
    }

    private func iconName(for wordSet: WordSet, mode: QuizMode) -> String {
        if mode == .typing { return "pencil" }
        switch wordSet {
        case .a1Words: return "book.fill"
        case .a2Words: return "square.grid.2x2.fill"
        case .phrasalVerbs: return "arrow.left.arrow.right"
        case .favorites: return "star.fill"
        }
    }

    private func rowIconColor(for wordSet: WordSet, mode: QuizMode) -> RowIconColor {
        if mode == .typing {
            switch wordSet {
            case .a1Words: return .teal
            case .a2Words: return .tealBlue
            case .phrasalVerbs: return .lavender
            default: return .blue
            }
        }
        switch wordSet {
        case .a1Words: return .green
        case .a2Words: return .blue
        case .phrasalVerbs: return .purple
        case .favorites: return .orange
        }
    }

    // MARK: - Navigation

    @ViewBuilder
    private func destinationView(for selection: WordSetSelection) -> some View {
        switch (selection.wordSet, selection.mode) {
        case (.favorites, _):
            QuizView(favoritesManager: favoritesManager, statsManager: statsManager, speechManager: speechManager, progressTracker: progressTracker)
        case (let wordSet, .multipleChoice) where wordSet.hasCategories:
            CategoryPickerView(wordSet: wordSet, favoritesManager: favoritesManager, statsManager: statsManager, speechManager: speechManager, progressTracker: progressTracker)
        case (let wordSet, .multipleChoice):
            QuizView(wordSet: wordSet, favoritesManager: favoritesManager, statsManager: statsManager, speechManager: speechManager, progressTracker: progressTracker)
        case (let wordSet, .typing) where wordSet.hasCategories:
            TypingCategoryPickerView(wordSet: wordSet, favoritesManager: favoritesManager, statsManager: statsManager, progressTracker: progressTracker)
        case (let wordSet, .typing):
            TypingQuizView(wordSet: wordSet, favoritesManager: favoritesManager, statsManager: statsManager, progressTracker: progressTracker)
        }
    }
}
