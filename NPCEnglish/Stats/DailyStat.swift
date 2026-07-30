//
//  DailyStat.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.07.2026.
//

import Foundation

struct DailyStat: Identifiable {
    let id = UUID()
    let date: Date
    let questionsAnswered: Int
    let correctAnswers: Int
}
