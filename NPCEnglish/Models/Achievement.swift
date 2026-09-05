//
//  Achievement.swift
//  NPCEnglish
//
//  Created by Влад Шимченко on 30.08.2026.
//

import Foundation

struct Achievement: Identifiable {
    let id: String
    let mode: QuizMode?
    let title: String
    let iconName: String
    let targetProgress: Int

    let currentProgress: (WordProgressTracking, StatsManaging) -> Int

    var lockedIconName: String { "achievement_locked" }
}

enum AchievementCatalog {
    static let all: [Achievement] = [
        // Квиз
        Achievement(
            id: "quiz_100_words",
            mode: .multipleChoice,
            title: "100 слов выучено",
            iconName: "quiz_100_words",
            targetProgress: 100
        ) { tracker, _ in
            tracker.totalLearnedWordsCount(mode: .multipleChoice)
        },

        Achievement(
            id: "quiz_500_words",
            mode: .multipleChoice,
            title: "500 слов выучено",
            iconName: "quiz_500_words",
            targetProgress: 500
        ) { tracker, _ in
            tracker.totalLearnedWordsCount(mode: .multipleChoice)
        },

        Achievement(
            id: "quiz_1000_words",
            mode: .multipleChoice,
            title: "1000 слов выучено",
            iconName: "quiz_1000_words",
            targetProgress: 1000
        ) { tracker, _ in
            tracker.totalLearnedWordsCount(mode: .multipleChoice)
        },

        Achievement(
            id: "quiz_phrasal_verbs_complete",
            mode: .multipleChoice,
            title: "Все фразовые глаголы пройдены",
            iconName: "quiz_phrasal_verbs_complete",
            targetProgress: 1
        ) { tracker, _ in
            let words = WordsLoader.loadWords(for: .phrasalVerbs)
            return tracker.isWordSetFullyLearned(words, wordSet: .phrasalVerbs, category: nil, mode: .multipleChoice) ? 1 : 0
        },

        // Напиши перевод
        Achievement(
            id: "typing_100_words",
            mode: .typing,
            title: "100 слов выучено",
            iconName: "typing_100_words",
            targetProgress: 100
        ) { tracker, _ in
            tracker.totalLearnedWordsCount(mode: .typing)
        },

        Achievement(
            id: "typing_500_words",
            mode: .typing,
            title: "500 слов выучено",
            iconName: "typing_500_words",
            targetProgress: 500
        ) { tracker, _ in
            tracker.totalLearnedWordsCount(mode: .typing)
        },

        Achievement(
            id: "typing_1000_words",
            mode: .typing,
            title: "1000 слов выучено",
            iconName: "typing_1000_words",
            targetProgress: 1000
        ) { tracker, _ in
            tracker.totalLearnedWordsCount(mode: .typing)
        },

        Achievement(
            id: "typing_phrasal_verbs_complete",
            mode: .typing,
            title: "Все фразовые глаголы пройдены",
            iconName: "typing_phrasal_verbs_complete",
            targetProgress: 1
        ) { tracker, _ in
            tracker.isWordSetFullyLearned(
                WordsLoader.loadWords(for: .phrasalVerbs),
                wordSet: .phrasalVerbs,
                category: nil,
                mode: .typing
            ) ? 1 : 0
        },

        Achievement(
            id: "quiz_perfect_session",
            mode: .multipleChoice,
            title: "100% в сессии",
            iconName: "achievement_quiz_perfect",
            targetProgress: 1
        ) { tracker, _ in
            tracker.hasPerfectSession(mode: .multipleChoice) ? 1 : 0
        },

        Achievement(
            id: "typing_perfect_session",
            mode: .typing,
            title: "100% в сессии",
            iconName: "achievement_typing_perfect",
            targetProgress: 1
        ) { tracker, _ in
            tracker.hasPerfectSession(mode: .typing) ? 1 : 0
        },

        Achievement(
            id: "streak_7_days",
            mode: nil,
            title: "7 дней подряд",
            iconName: "achievement_streak_7",
            targetProgress: 7
        ) { _, statsManager in
                    statsManager.currentStreak
        },

        Achievement(
            id: "streak_30_days",
            mode: nil,
            title: "30 дней подряд",
            iconName: "achievement_streak_30",
            targetProgress: 30
        ) { _, statsManager in
            statsManager.currentStreak
        }
    ]
}
