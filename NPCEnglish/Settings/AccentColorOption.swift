//
//  AccentColorOption.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 08.08.2026.
//

import SwiftUI

enum AccentColorOption: String, CaseIterable, Identifiable {
    case blue
    case purple
    case orange
    case green
    case pink

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: return Color(red: 0.0, green: 0.48, blue: 1.0)
        case .purple: return Color(red: 0.58, green: 0.35, blue: 0.95)
        case .orange: return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .green: return Color(red: 0.2, green: 0.78, blue: 0.35)
        case .pink: return Color(red: 1.0, green: 0.18, blue: 0.45)
        }
    }

    var title: String {
        switch self {
        case .blue: return "Синий"
        case .purple: return "Фиолетовый"
        case .orange: return "Оранжевый"
        case .green: return "Зелёный"
        case .pink: return "Розовый"
        }
    }
}
