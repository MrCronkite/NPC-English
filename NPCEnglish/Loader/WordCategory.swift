//
//  WordCategory.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 03.08.2026.
//

import Foundation

enum WordCategory: String, CaseIterable, Identifiable, Hashable {
    case work
    case travel
    case health
    case technology

    var id: String { rawValue }

    var title: String {
        switch self {
        case .work: return "Работа и карьера"
        case .travel: return "Путешествия"
        case .health: return "Здоровье"
        case .technology: return "Технологии"
        }
    }

    var systemImage: String {
        switch self {
        case .work: return "briefcase.fill"
        case .travel: return "airplane"
        case .health: return "cross.case.fill"
        case .technology: return "laptopcomputer"
        }
    }
}
