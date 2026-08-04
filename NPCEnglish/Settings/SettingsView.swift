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

    @AppStorage("speechAccent") private var speechAccent: String = "en-US"

    private let accentOptions: [(code: String, title: String)] = [
        ("en-US", "Американский"),
        ("en-GB", "Британский")
    ]

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

    private let sessionLengthOptions = [10, 20, 30, 50]

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
                        Text("\(count) слов").tag(count)
                    }
                }
                .pickerStyle(.inline)
            } header: {
                Text("Длина сессии")
            } footer: {
                Text("Сколько слов будет в одной сессии квиза, прежде чем показать результат.")
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
                Picker("Акцент озвучки", selection: $speechAccent) {
                    ForEach(accentOptions, id: \.code) { option in
                        Text(option.title).tag(option.code)
                    }
                }
                .pickerStyle(.inline)
            } header: {
                Text("Произношение")
            } footer: {
                Text("Используется при озвучке английских слов. Работает офлайн; для более качественного голоса можно скачать Enhanced-голос в настройках iOS (Спец. возможности → Контент речи → Голоса).")
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
