//
//  StartView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            List(WordSet.allCases) { wordSet in
                NavigationLink(value: wordSet) {
                    wordSetRow(wordSet)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Учим английский")
            .navigationDestination(for: WordSet.self) { wordSet in
                QuizView(wordSet: wordSet)
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


