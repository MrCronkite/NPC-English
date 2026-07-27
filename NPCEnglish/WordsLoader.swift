//
//  WordsLoader.swift
//  CombineApp
//
//  Created by Влад Шимченко on 27.07.2026.
//


import Foundation

enum WordsLoader {
    /// Загружает слова из words.json, добавленного в таргет приложения.
    static func loadWords(from fileName: String = "words") -> [Word] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("⚠️ Не найден файл \(fileName).json в бандле")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([Word].self, from: data)
            return words
        } catch {
            print("⚠️ Ошибка декодирования \(fileName).json: \(error)")
            return []
        }
    }
}
