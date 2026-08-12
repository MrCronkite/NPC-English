//
//  AnswerChecker.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 12.08.2026.
//

import Foundation

enum AnswerChecker {
    /// Проверяет, засчитывается ли введённый пользователем текст как правильный ответ.
    /// Логика: нормализуем оба текста (регистр, пробелы), разбиваем правильный ответ
    /// на отдельные значимые слова (на случай многословных переводов вроде
    /// "снимать деньги (со счёта)"), и засчитываем совпадение, если ввод достаточно
    /// близок хотя бы к одному из этих слов — либо как точное совпадение,
    /// либо с расстоянием Левенштейна ≤ 1 (одна опечатка: замена/пропуск/лишняя буква).
    static func isCorrect(input: String, expected: String) -> Bool {
        let normalizedInput = normalize(input)
        guard !normalizedInput.isEmpty else { return false }

        let normalizedExpected = normalize(expected)

        // Если пользователь ввёл ответ целиком (или близко к целому) — сразу засчитываем
        if normalizedInput == normalizedExpected || levenshteinDistance(normalizedInput, normalizedExpected) <= 1 {
            return true
        }

        // Иначе проверяем совпадение с отдельными значимыми словами (для многословных переводов
        // вроде "снимать деньги (со счёта)", где ожидать точное совпадение всей фразы нечестно)
        let candidates = significantWords(from: expected)

        return candidates.contains { candidate in
            normalizedInput == candidate || levenshteinDistance(normalizedInput, candidate) <= 1
        }
    }

    private static func normalize(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    /// Разбивает "снимать деньги (со счёта)" на ["снимать", "деньги", "со", "счёта"],
    /// убирая скобки и знаки препинания — каждое слово по отдельности можно засчитать как верный ответ.
    private static func significantWords(from text: String) -> [String] {
        let cleaned = text
            .replacingOccurrences(of: "(", with: " ")
            .replacingOccurrences(of: ")", with: " ")
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: "/", with: " ")

        return cleaned
            .lowercased()
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count >= 2 } // отсекаем однобуквенные предлоги/союзы вроде "с", "и"
    }

    /// Классическое расстояние Левенштейна между двумя строками.
    private static func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let a = Array(a)
        let b = Array(b)

        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        var previousRow = Array(0...b.count)
        var currentRow = [Int](repeating: 0, count: b.count + 1)

        for i in 1...a.count {
            currentRow[0] = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                currentRow[j] = Swift.min(
                    previousRow[j] + 1,      // удаление
                    currentRow[j - 1] + 1,   // вставка
                    previousRow[j - 1] + cost // замена
                )
            }
            previousRow = currentRow
        }

        return previousRow[b.count]
    }
}
