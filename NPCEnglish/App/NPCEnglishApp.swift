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

    private var theme: AppTheme {
        AppTheme(rawValue: themeRaw) ?? .system
    }

    init() {
        UserDefaults.standard.register(defaults: [
            "soundEnabled": true,
            "hapticsEnabled": true
        ])

        let stack = CoreDataStack()
        self.coreDataStack = stack
        self.favoritesManager = CoreDataFavoritesManager(context: stack.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            StartView(
                favoritesManager: favoritesManager
            )
            .preferredColorScheme(theme.colorScheme)
        }
    }
}
