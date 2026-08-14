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
    case food
    case money
    case personality
    case relationships
    case directions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .work: return "Работа и карьера"
        case .travel: return "Путешествия"
        case .health: return "Здоровье"
        case .technology: return "Технологии"
        case .food: return "Еда и готовка"
        case .money: return "Деньги"
        case .personality: return "Характер"
        case .relationships: return "Отношения"
        case .directions: return "Направления и город"
        }
    }

    var systemImage: String {
        switch self {
        case .work: return "briefcase.fill"
        case .travel: return "airplane"
        case .health: return "cross.case.fill"
        case .technology: return "laptopcomputer"
        case .food: return "fork.knife"
        case .money: return "banknote.fill"
        case .personality: return "person.fill.questionmark"
        case .relationships: return "heart.fill"
        case .directions: return "signpost.right.fill"
        }
    }
}
