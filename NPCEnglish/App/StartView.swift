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

                wordSetSection(title: "Наборы слов", mode: .multipleChoice)
                wordSetSection(title: "Режим: напиши перевод", mode: .typing)

                Section("Повторение") {
                    NavigationLink(value: WordSetSelection(wordSet: .favorites, mode: .multipleChoice)) {
                        wordSetRow(.favorites)
                    }
                }

                Section {
                    NavigationLink {
                        SupportView()
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Поддержать проект")
                                    .font(.headline)
                                Text("Приложение бесплатное — но спасибо не помешает")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Учим английский")
            .navigationDestination(for: WordSetSelection.self) { selection in
                destinationView(for: selection)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(notificationManager: notificationManager)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private func wordSetSection(title: String, mode: QuizMode) -> some View {
        Section(title) {
            ForEach(WordSet.regularSets) { wordSet in
                NavigationLink(value: WordSetSelection(wordSet: wordSet, mode: mode)) {
                    wordSetRow(wordSet)
                }
            }
        }
    }

    // MARK: - Navigation

    @ViewBuilder
    private func destinationView(for selection: WordSetSelection) -> some View {
        switch (selection.wordSet, selection.mode) {
        case (.favorites, _):
            QuizView(
                favoritesManager: favoritesManager,
                statsManager: statsManager,
                speechManager: speechManager
            )

        case (let wordSet, .multipleChoice) where wordSet.hasCategories:
            CategoryPickerView(
                wordSet: wordSet,
                favoritesManager: favoritesManager,
                statsManager: statsManager,
                speechManager: speechManager
            )

        case (let wordSet, .multipleChoice):
            QuizView(
                wordSet: wordSet,
                favoritesManager: favoritesManager,
                statsManager: statsManager,
                speechManager: speechManager
            )

        case (let wordSet, .typing) where wordSet.hasCategories:
            TypingCategoryPickerView(
                wordSet: wordSet,
                favoritesManager: favoritesManager,
                statsManager: statsManager
            )

        case (let wordSet, .typing):
            TypingQuizView(
                wordSet: wordSet,
                favoritesManager: favoritesManager,
                statsManager: statsManager
            )
        }
    }

    // MARK: - Row

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
