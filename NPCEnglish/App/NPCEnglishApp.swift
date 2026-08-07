//
//  NPCEnglishApp.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 27.07.2026.
//

import SwiftUI

@main
struct NPCEnglishApp: App {

    @AppStorage("appTheme")
    private var themeRaw: String = AppTheme.system.rawValue

    private let coreDataStack: CoreDataStack
    private let favoritesManager: FavoritesManaging
    private let statsManager: StatsManaging
    private let speechManager: SpeechSynthesizing
    private let notificationManager: NotificationScheduling

    private var theme: AppTheme {
        AppTheme(rawValue: themeRaw) ?? .system
    }

    @State private var deepLinkedWordSet: WordSet?

    init() {
        UserDefaults.standard.register(defaults: [
            "soundEnabled": true,
            "hapticsEnabled": true
        ])

        let stack = CoreDataStack()
        self.coreDataStack = stack
        self.favoritesManager = CoreDataFavoritesManager(context: stack.viewContext)
        self.notificationManager = StreakNotificationManager()
        self.statsManager = CoreDataStatsManager(
            context: stack.viewContext,
            notificationManager: notificationManager
        )
        self.speechManager = SpeechManager()
    }

    var body: some Scene {
        WindowGroup {
            StartView(
                favoritesManager: favoritesManager,
                statsManager: statsManager,
                speechManager: speechManager,
                notificationManager: notificationManager
            )
            .preferredColorScheme(theme.colorScheme)
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
            // englishwords://quiz — открываем набор A1 по умолчанию.
            guard url.host == "quiz" else { return }
            deepLinkedWordSet = .a1Words
        }
}
