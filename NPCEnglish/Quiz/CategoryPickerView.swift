//
//  CategoryPickerView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 03.08.2026.
//

import SwiftUI

struct CategoryPickerView: View {
    let wordSet: WordSet
    let favoritesManager: FavoritesManaging
    let statsManager: StatsManaging
    let speechManager: SpeechSynthesizing

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
                QuizView(
                    wordSet: wordSet,
                    category: category,
                    favoritesManager: favoritesManager,
                    statsManager: statsManager,
                    speechManager: speechManager
                )
            } label: {
                categoryRow(category)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(wordSet.title)
    }

    private func categoryRow(_ category: WordCategory) -> some View {
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
