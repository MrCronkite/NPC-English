//
//  QuizViewModelTests.swift
//  NPCEnglishTests
//
//  Created by Влад Шимченко on 02.08.2026.
//

import XCTest
@testable import NPCEnglish

@MainActor
final class QuizViewModelTests: XCTestCase {

    func testInitLoadsWordsAndGeneratesFourOptions() {
        let sut = QuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        XCTAssertNotNil(sut.currentWord)
        XCTAssertEqual(sut.options.count, 4)
        XCTAssertTrue(sut.options.contains(where: { $0.id == sut.currentWord?.id }))
    }

    func testSelectCorrectOptionIncrementsScore() {
        let sut = QuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        guard let correctOption = sut.options.first(where: { $0.id == sut.currentWord?.id }) else {
            XCTFail("Правильный вариант должен быть среди options")
            return
        }

        sut.select(correctOption)

        XCTAssertEqual(sut.score, 1)
        XCTAssertEqual(sut.total, 1)
        XCTAssertTrue(sut.isAnswered)
        XCTAssertTrue(sut.isCorrect)
    }

    func testSelectWrongOptionDoesNotIncrementScore() {
        let sut = QuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        guard let wrongOption = sut.options.first(where: { $0.id != sut.currentWord?.id }) else {
            XCTFail("Должен быть хотя бы один неверный вариант")
            return
        }

        sut.select(wrongOption)

        XCTAssertEqual(sut.score, 0)
        XCTAssertEqual(sut.total, 1)
        XCTAssertFalse(sut.isCorrect)
    }

    func testSecondSelectAfterAnswerIsIgnored() {
        let sut = QuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        let firstOption = sut.options[0]
        let secondOption = sut.options[1]

        sut.select(firstOption)
        sut.select(secondOption) 

        XCTAssertEqual(sut.total, 1, "guard !isAnswered должен блокировать повторный выбор")
    }

    func testSessionFinishesAfterPlannedQuestions() {
        // sessionLength читается из @AppStorage("sessionLength"), по умолчанию 10.
        // Явно фиксируем значение, чтобы тест не зависел от состояния UserDefaults.
        UserDefaults.standard.set(3, forKey: "sessionLength")

        let sut = QuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        for _ in 0..<3 {
            guard let option = sut.options.first else { break }
            sut.select(option)
            sut.nextQuestion()
        }

        XCTAssertTrue(sut.isSessionFinished)
    }

    func testToggleFavoriteUpdatesIsCurrentFavorite() {
        let favoritesManager = MockFavoritesManager()
        let sut = QuizViewModel(
            wordSet: .a1Words,
            favoritesManager: favoritesManager,
            statsManager: MockStatsManager()
        )

        XCTAssertFalse(sut.isCurrentFavorite)

        sut.toggleFavorite()
        XCTAssertTrue(sut.isCurrentFavorite)

        sut.toggleFavorite()
        XCTAssertFalse(sut.isCurrentFavorite)
    }

    func testFavoritesSessionOnlyContainsFavoritedWords() {
        let favoritesManager = MockFavoritesManager()
        let allA1Words = WordsLoader.loadWords(for: .a1Words)

        guard allA1Words.count >= 4 else {
            XCTFail("Нужно минимум 4 слова в words_a1.json для теста")
            return
        }

        let favoritedIDs = allA1Words.prefix(4).map(\.id)
        favoritedIDs.forEach { favoritesManager.toggleFavorite(wordID: $0, in: .a1Words) }

        let sut = QuizViewModel(favoritesManager: favoritesManager, statsManager: MockStatsManager())

        XCTAssertEqual(sut.allWords.count, 4)
        XCTAssertTrue(sut.allWords.allSatisfy { favoritedIDs.contains($0.id) })
    }
}
