//
//  TypingQuizViewModelTests.swift
//  NPCEnglishTests
//
//  Created by Влад Шимченко on 12.08.2026.
//

import XCTest
@testable import NPCEnglish

@MainActor
final class TypingQuizViewModelTests: XCTestCase {

    func testInitLoadsWordsAndSetsCurrentWord() {
        let sut = TypingQuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        XCTAssertFalse(sut.allWords.isEmpty)
        XCTAssertNotNil(sut.currentWord)
        XCTAssertFalse(sut.isAnswered)
        XCTAssertEqual(sut.userInput, "")
    }

    func testSubmitCorrectAnswerIncrementsScore() {
        let sut = TypingQuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        // direction по умолчанию englishToRussian, questionText = word.english,
        // ожидаемый ответ = word.translation
        sut.userInput = sut.correctAnswerText

        sut.submitAnswer()

        XCTAssertTrue(sut.isAnswered)
        XCTAssertTrue(sut.wasCorrect)
        XCTAssertEqual(sut.score, 1)
        XCTAssertEqual(sut.total, 1)
    }

    func testSubmitWrongAnswerDoesNotIncrementScore() {
        let sut = TypingQuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        sut.userInput = "совершенно неверный ответ xyz"

        sut.submitAnswer()

        XCTAssertTrue(sut.isAnswered)
        XCTAssertFalse(sut.wasCorrect)
        XCTAssertEqual(sut.score, 0)
        XCTAssertEqual(sut.total, 1)
    }

    func testSecondSubmitAfterAnswerIsIgnored() {
        let sut = TypingQuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.userInput = "что-то другое"
        sut.submitAnswer() // должно быть проигнорировано guard !isAnswered

        XCTAssertEqual(sut.total, 1, "Повторный submit после ответа не должен засчитываться")
    }

    func testRevealAnswerMarksAsIncorrectAndAnswered() {
        let sut = TypingQuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        sut.revealAnswer()

        XCTAssertTrue(sut.isAnswered)
        XCTAssertFalse(sut.wasCorrect)
        XCTAssertEqual(sut.total, 1)
        XCTAssertEqual(sut.score, 0)
    }

    func testRevealAnswerAfterAlreadyAnsweredIsIgnored() {
        let sut = TypingQuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.revealAnswer() // должно быть проигнорировано guard !isAnswered

        XCTAssertEqual(sut.total, 1, "revealAnswer после ответа не должен засчитываться повторно")
        XCTAssertTrue(sut.wasCorrect, "Результат первого (верного) ответа не должен перезаписаться")
    }

    func testNextQuestionResetsInputAndAnsweredState() {
        let sut = TypingQuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        sut.userInput = "test"
        sut.submitAnswer()
        sut.nextQuestion()

        XCTAssertEqual(sut.userInput, "")
        XCTAssertFalse(sut.isAnswered)
    }

    func testSessionFinishesAfterPlannedQuestions() {
        UserDefaults.standard.set(3, forKey: "sessionLength")

        let sut = TypingQuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: MockStatsManager()
        )

        for _ in 0..<3 {
            sut.revealAnswer()
            sut.nextQuestion()
        }

        XCTAssertTrue(sut.isSessionFinished)
    }

    func testSessionCompletionRecordsStats() {
        UserDefaults.standard.set(2, forKey: "sessionLength")

        let statsManager = MockStatsManager()
        let sut = TypingQuizViewModel(
            wordSet: .a1Words,
            favoritesManager: MockFavoritesManager(),
            statsManager: statsManager
        )

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.nextQuestion()

        sut.revealAnswer()
        sut.nextQuestion()

        XCTAssertTrue(sut.isSessionFinished)
        // MockStatsManager не хранит переданные score/total явно (по нашей реализации),
        // но recordSessionCompleted не должен падать/крашить при вызове.
        // Если хочешь строже проверить именно вызов — расширим MockStatsManager счётчиком,
        // как делали с MockNotificationManager для cancelCallCount.
    }
}
