//
//  SettingsView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("translationDirection") private var directionRaw: String = TranslationDirection.englishToRussian.rawValue

    private var direction: Binding<TranslationDirection> {
        Binding(
            get: { TranslationDirection(rawValue: directionRaw) ?? .englishToRussian },
            set: { directionRaw = $0.rawValue }
        )
    }

    var body: some View {
        Form {
            Section {
                Picker("Направление перевода", selection: direction) {
                    ForEach(TranslationDirection.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.inline)
            } header: {
                Text("Перевод")
            } footer: {
                Text("Определяет, что показывается как вопрос: слово на английском или перевод на русском.")
            }
        }
        .navigationTitle("Настройки")
    }
}
