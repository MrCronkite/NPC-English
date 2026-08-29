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

    @Environment(\.dismiss) private var dismiss

    private var allWords: [Word] {
        WordsLoader.loadWords(for: wordSet)
    }

    private var availableCategories: [WordCategory] {
        let presentRaw = Set(allWords.compactMap(\.category))
        return WordCategory.allCases.filter { presentRaw.contains($0.rawValue) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header

                VStack(spacing: 12) {
                    ForEach(availableCategories) { category in
                        NavigationLink {
                            TypingQuizView(wordSet: wordSet, category: category, favoritesManager: favoritesManager, statsManager: statsManager, progressTracker: progressTracker)
                        } label: {
                            categoryRow(category)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
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

            Text(wordSet.title)
                .font(.largeTitle.bold())

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private func categoryRow(_ category: WordCategory) -> some View {
        HStack(spacing: 16) {
            Image(systemName: category.systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(category.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
