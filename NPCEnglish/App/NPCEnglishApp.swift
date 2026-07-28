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

    private var theme: AppTheme {
        AppTheme(rawValue: themeRaw) ?? .system
    }

    init() {
        UserDefaults.standard.register(defaults: [
            "soundEnabled": true,
            "hapticsEnabled": true
        ])
    }

    var body: some Scene {
        WindowGroup {
            StartView()
                .preferredColorScheme(theme.colorScheme)
        }
    }
}
