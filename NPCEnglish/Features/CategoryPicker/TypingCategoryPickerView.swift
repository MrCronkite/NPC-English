//
//  TypingCategoryPickerView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 12.08.2026.
//

import SwiftUI

struct TypingCategoryPickerView: View {
    let wordSet: WordSet
    let favoritesManager: FavoritesManaging
    let statsManager: StatsManaging
    let progressTracker: WordProgressTracking

    private var allWords: [Word] {
        WordsLoader.loadWords(for: wordSet)
    }

    private var availableCategories: [WordCategory] {
        let presentRaw = Set(allWords.compactMap(\.category))
        return WordCategory.allCases.filter { presentRaw.contains($0.rawValue) }
    }

    var body: some View {
        List(availableCategories) { category in
            NavigationLink {
                TypingQuizView(
                    wordSet: wordSet,
                    category: category,
                    favoritesManager: favoritesManager,
                    statsManager: statsManager,
                    progressTracker: progressTracker
                )
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: category.systemImage)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text(category.title)
                        .font(.headline)
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("\(wordSet.title) · Напиши перевод")
    }
}
