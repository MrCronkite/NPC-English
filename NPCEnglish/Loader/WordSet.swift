//
//  WordSet.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import Foundation


enum WordSet: String, CaseIterable, Identifiable, Hashable {
    case a1Words = "words_a1"
    case phrasalVerbs = "phrasal_verbs"
    case favorites = "favorites"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .a1Words: return "Слова уровня A1"
        case .phrasalVerbs: return "Фразовые глаголы"
        case .favorites: return "Избранное"
        }
    }

    var subtitle: String {
        switch self {
        case .a1Words: return "1000 базовых слов для начинающих"
        case .phrasalVerbs: return "363 самых частых phrasal verbs"
        case .favorites: return "Слова, которые ты сохранил"
        }
    }

    var systemImage: String {
        switch self {
        case .a1Words: return "textformat.abc"
        case .phrasalVerbs: return "arrow.triangle.branch"
        case .favorites: return "heart.fill"
        }
    }

    var fileName: String { rawValue }

    /// Обычные наборы слов, которые грузятся из JSON. Избранное — отдельная логика, сюда не входит.
    static var regularSets: [WordSet] { [.a1Words, .phrasalVerbs] }
}

