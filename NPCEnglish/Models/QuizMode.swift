//
//  QuizMode.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 17.08.2026.
//

import Foundation

enum QuizMode: String, Hashable {
    case multipleChoice
    case typing
}

struct WordSetSelection: Hashable {
    let wordSet: WordSet
    let mode: QuizMode
}
