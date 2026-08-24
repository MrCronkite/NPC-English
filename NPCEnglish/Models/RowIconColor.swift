//
//  RowIconColor.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 21.08.2026.
//

import SwiftUI

enum RowIconColor {
    case green, blue, purple, teal, tealBlue, lavender, orange, red

    var color: Color {
        switch self {
        case .green: return Color(red: 0.30, green: 0.78, blue: 0.42)
        case .blue: return Color(red: 0.20, green: 0.55, blue: 0.95)
        case .purple: return Color(red: 0.55, green: 0.40, blue: 0.95)
        case .teal: return Color(red: 0.35, green: 0.82, blue: 0.68)
        case .tealBlue: return Color(red: 0.45, green: 0.68, blue: 0.98)
        case .lavender: return Color(red: 0.72, green: 0.60, blue: 0.98)
        case .orange: return Color(red: 1.0, green: 0.68, blue: 0.15)
        case .red: return Color(red: 0.95, green: 0.35, blue: 0.40)
        }
    }
}
