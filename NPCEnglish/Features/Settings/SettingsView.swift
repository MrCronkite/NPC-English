//
//  SettingsView.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("translationDirection") private var directionRaw: String = TranslationDirection.englishToRussian.rawValue
    @AppStorage("sessionLength") private var sessionLength: Int = 10
    @AppStorage("appTheme") private var themeRaw: String = AppTheme.system.rawValue
    @AppStorage("accentColor") private var accentColorRaw: String = AccentColorOption.blue.rawValue
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("streakRemindersEnabled") private var streakRemindersEnabled: Bool = false
    @AppStorage("streakReminderHour") private var reminderHour: Int = 20
    @AppStorage("streakReminderMinute") private var reminderMinute: Int = 0

    let notificationManager: NotificationScheduling
    @Environment(\.dismiss) private var dismiss

    private var selectedAccentColor: AccentColorOption {
        AccentColorOption(rawValue: accentColorRaw) ?? .blue
    }

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

                if streakRemindersEnabled {
                    notificationManager.scheduleDailyStreakReminder(hour: reminderHour, minute: reminderMinute)
                }
            }
        )
    }

    private let sessionLengthOptions = [10, 20, 30, 50]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header

                card(title: "Перевод", footer: "Определяет, что показывается как вопрос: слово на английском или перевод на русском.") {
                    Picker("Направление перевода", selection: direction) {
                        ForEach(TranslationDirection.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                card(title: "Длина сессии", footer: "Сколько слов будет в одной сессии квиза, прежде чем показать результат.") {
                    Picker("Количество слов", selection: $sessionLength) {
                        ForEach(sessionLengthOptions, id: \.self) { count in
                            Text("\(count) слов").tag(count)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                card(title: "Оформление", footer: "Тема и акцентный цвет применяются сразу во всём приложении.") {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Тема", selection: theme) {
                            ForEach(AppTheme.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)

                        Divider()

                        Text("Акцентный цвет")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        accentColorGrid
                    }
                }

                card(title: "Напоминания", footer: "Ежедневное напоминание, если сегодня ты ещё не проходил квиз.") {
                    VStack(spacing: 16) {
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
                            Divider()
                            DatePicker("Время", selection: reminderTime, displayedComponents: .hourAndMinute)
                        }
                    }
                }

                card(title: "Обратная связь", footer: "Звук и вибрация при ответе на вопрос.") {
                    VStack(spacing: 16) {
                        Toggle("Звук", isOn: $soundEnabled)
                        Divider()
                        Toggle("Вибрация", isOn: $hapticsEnabled)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Header

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

            Text("Настройки")
                .font(.largeTitle.bold())

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }

    // MARK: - Card wrapper

    private func card(title: String, footer: String? = nil, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)

            content()

            if let footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    // MARK: - Accent color grid

    private var accentColorGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(AccentColorOption.allCases) { option in
                accentColorSwatch(option)
            }
        }
    }

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
                    .frame(width: 38, height: 38)

                if isSelected {
                    Circle()
                        .stroke(option.color, lineWidth: 2)
                        .frame(width: 48, height: 48)

                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 48, height: 48)
            .scaleEffect(isSelected ? 1.0 : 0.9)
        }
        .buttonStyle(.plain)
    }
}
