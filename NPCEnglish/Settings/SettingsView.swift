//
//  SettingsView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("translationDirection")
    private var directionRaw: String = TranslationDirection.englishToRussian.rawValue

    @AppStorage("sessionLength")
    private var sessionLength: Int = 10

    @AppStorage("appTheme")
    private var themeRaw: String = AppTheme.system.rawValue

    @AppStorage("soundEnabled")
    private var soundEnabled: Bool = true

    @AppStorage("hapticsEnabled")
    private var hapticsEnabled: Bool = true

    private var direction: Binding<TranslationDirection> {
        Binding(
            get: { TranslationDirection(rawValue: directionRaw) ?? .englishToRussian },
            set: { directionRaw = $0.rawValue }
        )
    }

    private var theme: Binding<AppTheme> {
        Binding(
            get: { AppTheme(rawValue: themeRaw) ?? .system },
            set: { themeRaw = $0.rawValue }
        )
    }

    private let sessionLengthOptions = [10, 20, 30, 50, 0]

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
            }

            Section {
                Picker("Количество слов", selection: $sessionLength) {
                    ForEach(sessionLengthOptions, id: \.self) { count in
                        Text(count == 0 ? "Без ограничений" : "\(count) слов").tag(count)
                    }
                }
                .pickerStyle(.inline)
            } header: {
                Text("Длина сессии")
            }

            Section {
                Picker("Тема", selection: theme) {
                    ForEach(AppTheme.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.inline)
            } header: {
                Text("Оформление")
            }

            Section {
                Toggle("Звук", isOn: $soundEnabled)
                Toggle("Вибрация", isOn: $hapticsEnabled)
            } header: {
                Text("Обратная связь")
            } footer: {
                Text("Звук и вибрация при ответе на вопрос.")
            }
        }
        .navigationTitle("Настройки")
    }
}
