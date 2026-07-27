//
//  Word.swift
//  CombineApp
//
//  Created by Влад Шимченко on 27.07.2026.
//


import Foundation

struct Word: Identifiable, Codable, Equatable {
    let id: Int
    let english: String
    let translation: String
}
