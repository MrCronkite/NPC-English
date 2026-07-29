//
//  StartView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import SwiftUI

struct StartView: View {
    let favoritesManager: FavoritesManaging

    var body: some View {
        NavigationStack {
            List {
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
                    QuizView(favoritesManager: favoritesManager)
                } else {
                    QuizView(wordSet: wordSet, favoritesManager: favoritesManager)
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
