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

    @State private var refreshTrigger = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        StatsView(statsManager: statsManager)
                    } label: {
                        MiniStatsWidgetView(statsManager: statsManager)
                    }
                }

                Section("Наборы слов") {
                    ForEach(WordSet.regularSets) { wordSet in
                        NavigationLink(value: wordSet) {
                            wordSetRow(wordSet)
                        }
                    }
                }

                Section("Повторение") {
                    NavigationLink(value: WordSet.favorites) {
                        wordSetRow(.favorites)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Учим английский")
            .navigationDestination(for: WordSet.self) { wordSet in
                if wordSet == .favorites {
                    QuizView(favoritesManager: favoritesManager, statsManager: statsManager)
                } else {
                    QuizView(wordSet: wordSet, favoritesManager: favoritesManager, statsManager: statsManager)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }

    private var miniWeekBars: some View {
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

    private func wordSetRow(_ wordSet: WordSet) -> some View {
        HStack(spacing: 16) {
            Image(systemName: wordSet.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(wordSet.title)
                    .font(.headline)
                Text(wordSet.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    StartView(
        favoritesManager: MockFavoritesManager(),
        statsManager: MockStatsManager()
    )
}
