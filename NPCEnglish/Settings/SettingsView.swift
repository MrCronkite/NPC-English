//
//  SettingsView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage("streakRemindersEnabled")
    private var streakRemindersEnabled: Bool = false

    @AppStorage("streakReminderHour")
    private var reminderHour: Int = 20

    @AppStorage("streakReminderMinute")
    private var reminderMinute: Int = 0

    @AppStorage("accentColor")
    private var accentColorRaw: String = AccentColorOption.blue.rawValue

    private var selectedAccentColor: AccentColorOption {
        AccentColorOption(rawValue: accentColorRaw) ?? .blue
    }

    @AppStorage("translationDirection")
    private var directionRaw: String = TranslationDirection.englishToRussian.rawValue

    let notificationManager: NotificationScheduling

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

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = components.hour ?? 20
                reminderMinute = components.minute ?? 0

                // Если напоминания уже включены — перепланируем на новое время сразу
                if streakRemindersEnabled {
                    notificationManager.scheduleDailyStreakReminder(hour: reminderHour, minute: reminderMinute)
                }
            }
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
                Toggle("Напоминание о занятии", isOn: Binding(
                    get: { streakRemindersEnabled },
                    set: { newValue in
                        if newValue {
                            notificationManager.requestAuthorization { granted in
                                if granted {
                                    streakRemindersEnabled = true
                                    notificationManager.scheduleDailyStreakReminder(hour: reminderHour, minute: reminderMinute)
                                } else {
                                    streakRemindersEnabled = false
                                }
                            }
                        } else {
                            streakRemindersEnabled = false
                            notificationManager.cancelTodayStreakReminder()
                        }
                    }
                ))

                if streakRemindersEnabled {
                    DatePicker("Время", selection: reminderTime, displayedComponents: .hourAndMinute)
                }
            } header: {
                Text("Напоминания")
            } footer: {
                Text("Ежедневное напоминание, если сегодня ты ещё не проходил квиз.")
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
                HStack(spacing: 16) {
                    ForEach(AccentColorOption.allCases) { option in
                        accentColorSwatch(option)
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
            } header: {
                Text("Акцентный цвет")
            } footer: {
                Text("Цвет кнопок, прогресс-бара и выделений во всём приложении.")
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

extension SettingsView {
    private func accentColorSwatch(_ option: AccentColorOption) -> some View {
        let isSelected = selectedAccentColor == option

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                accentColorRaw = option.rawValue
            }
        } label: {
            ZStack {
                Circle()
                    .fill(option.color)
                    .frame(width: 40, height: 40)

                if isSelected {
                    Circle()
                        .stroke(option.color, lineWidth: 2)
                        .frame(width: 52, height: 52)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 52, height: 52)
            .scaleEffect(isSelected ? 1.0 : 0.92)
        }
        .buttonStyle(.plain)
    }
}
