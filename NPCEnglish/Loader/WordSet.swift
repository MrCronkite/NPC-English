//
//  WordSet.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 28.07.2026.
//

import Foundation


enum WordSet: String, CaseIterable, Identifiable {
    case a1Words = "words_a1"
    case phrasalVerbs = "phrasal_verbs"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .a1Words:
            return "Слова уровня A1"
        case .phrasalVerbs:
            return "Фразовые глаголы"
        }
    }

    var subtitle: String {
        switch self {
        case .a1Words:
            return "1000 базовых слов для начинающих"
        case .phrasalVerbs:
            return "363 самых частых phrasal verbs"
        }
    }

    var systemImage: String {
        switch self {
        case .a1Words:
            return "textformat.abc"
        case .phrasalVerbs:
            return "arrow.triangle.branch"
        }
    }

    var fileName: String { rawValue }
}

extension WordSet: Hashable {}
