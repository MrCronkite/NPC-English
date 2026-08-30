//
//  Achievement.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.08.2026.
//

import Foundation

struct Achievement: Identifiable {
    let id: String
    let mode: QuizMode
    let title: String
    let iconName: String  // placeholder — заменишь на кастомные иконки позже
    let targetProgress: Int

    /// Проверяет текущий прогресс к достижению (0...targetProgress)
    let currentProgress: (WordProgressTracking) -> Int
}

enum AchievementCatalog {
    static let all: [Achievement] = [
        // Квиз
        Achievement(
            id: "quiz_100_words",
            mode: .multipleChoice,
            title: "100 слов выучено",
            iconName: "placeholder",
            targetProgress: 100
        ) { tracker in
            tracker.totalLearnedWordsCount(mode: .multipleChoice)
        },

        Achievement(
            id: "quiz_500_words",
            mode: .multipleChoice,
            title: "500 слов выучено",
            iconName: "placeholder",
            targetProgress: 500
        ) { tracker in
            tracker.totalLearnedWordsCount(mode: .multipleChoice)
        },

        Achievement(
            id: "quiz_1000_words",
            mode: .multipleChoice,
            title: "1000 слов выучено",
            iconName: "placeholder",
            targetProgress: 1000
        ) { tracker in
            tracker.totalLearnedWordsCount(mode: .multipleChoice)
        },

        Achievement(
            id: "quiz_phrasal_verbs_complete",
            mode: .multipleChoice,
            title: "Все фразовые глаголы пройдены",
            iconName: "placeholder",
            targetProgress: 1
        ) { tracker in
            let words = WordsLoader.loadWords(for: .phrasalVerbs)
            return tracker.isWordSetFullyLearned(words, wordSet: .phrasalVerbs, category: nil, mode: .multipleChoice) ? 1 : 0
        },

        // Напиши перевод
        Achievement(
            id: "typing_100_words",
            mode: .typing,
            title: "100 слов выучено",
            iconName: "placeholder",
            targetProgress: 100
        ) { tracker in
            tracker.totalLearnedWordsCount(mode: .typing)
        },

        Achievement(
            id: "typing_500_words",
            mode: .typing,
            title: "500 слов выучено",
            iconName: "placeholder",
            targetProgress: 500
        ) { tracker in
            tracker.totalLearnedWordsCount(mode: .typing)
        },

        Achievement(
            id: "typing_1000_words",
            mode: .typing,
            title: "1000 слов выучено",
            iconName: "placeholder",
            targetProgress: 1000
        ) { tracker in
            tracker.totalLearnedWordsCount(mode: .typing)
        },

        Achievement(
            id: "typing_phrasal_verbs_complete",
            mode: .typing,
            title: "Все фразовые глаголы пройдены",
            iconName: "placeholder",
            targetProgress: 1
        ) { tracker in
            tracker.isWordSetFullyLearned(
                WordsLoader.loadWords(for: .phrasalVerbs),
                wordSet: .phrasalVerbs,
                category: nil,
                mode: .typing
            ) ? 1 : 0
        }
    ]
}
