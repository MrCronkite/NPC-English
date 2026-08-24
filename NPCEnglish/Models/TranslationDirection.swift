//
//  TranslationDirection.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import Foundation

enum TranslationDirection: String, CaseIterable, Identifiable {
    case englishToRussian
    case russianToEnglish

    var id: String { rawValue }

    var title: String {
        switch self {
        case .englishToRussian: return "Английский → Русский"
        case .russianToEnglish: return "Русский → Английский"
        }
    }
}
