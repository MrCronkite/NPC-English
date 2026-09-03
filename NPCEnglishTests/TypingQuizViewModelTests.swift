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

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "sessionLength")
        super.tearDown()
    }

    private func makeSUT(
        wordSet: WordSet = .a1Words,
        favoritesManager: FavoritesManaging = MockFavoritesManager(),
        statsManager: StatsManaging = MockStatsManager(),
        progressTracker: WordProgressTracking = MockProgressManager(),
        achievementsManager: AchievementsManaging = MockAchievementsManager()
    ) -> TypingQuizViewModel {
        TypingQuizViewModel(
            wordSet: wordSet,
            favoritesManager: favoritesManager,
            statsManager: statsManager,
            progressTracker: progressTracker,
            achievementsManager: achievementsManager
        )
    }

    func testInitLoadsWordsAndSetsCurrentWord() {
        let sut = makeSUT()

        XCTAssertFalse(sut.allWords.isEmpty)
        XCTAssertNotNil(sut.currentWord)
        XCTAssertFalse(sut.isAnswered)
        XCTAssertEqual(sut.userInput, "")
    }

    func testSubmitCorrectAnswerIncrementsScore() {
        let sut = makeSUT()

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()

        XCTAssertTrue(sut.isAnswered)
        XCTAssertTrue(sut.wasCorrect)
        XCTAssertEqual(sut.score, 1)
        XCTAssertEqual(sut.total, 1)
    }

    func testSubmitWrongAnswerDoesNotIncrementScore() {
        let sut = makeSUT()

        sut.userInput = "совершенно неверный ответ xyz"
        sut.submitAnswer()

        XCTAssertTrue(sut.isAnswered)
        XCTAssertFalse(sut.wasCorrect)
        XCTAssertEqual(sut.score, 0)
        XCTAssertEqual(sut.total, 1)
    }

    func testSecondSubmitAfterAnswerIsIgnored() {
        let sut = makeSUT()

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.userInput = "что-то другое"
        sut.submitAnswer()

        XCTAssertEqual(sut.total, 1)
    }

    func testRevealAnswerMarksAsIncorrectAndAnswered() {
        let sut = makeSUT()

        sut.revealAnswer()

        XCTAssertTrue(sut.isAnswered)
        XCTAssertFalse(sut.wasCorrect)
        XCTAssertEqual(sut.total, 1)
        XCTAssertEqual(sut.score, 0)
    }

    func testRevealAnswerAfterAlreadyAnsweredIsIgnored() {
        let sut = makeSUT()

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.revealAnswer()

        XCTAssertEqual(sut.total, 1)
        XCTAssertTrue(sut.wasCorrect)
    }

    func testNextQuestionResetsInputAndAnsweredState() {
        let sut = makeSUT()

        sut.userInput = "test"
        sut.submitAnswer()
        sut.nextQuestion()

        XCTAssertEqual(sut.userInput, "")
        XCTAssertFalse(sut.isAnswered)
    }

    func testSessionFinishesAfterPlannedQuestions() {
        UserDefaults.standard.set(3, forKey: "sessionLength")

        let sut = makeSUT()

        for _ in 0..<3 {
            sut.revealAnswer()
            sut.nextQuestion()
        }

        XCTAssertTrue(sut.isSessionFinished)
    }

    func testSessionCompletionRecordsStats() {
        UserDefaults.standard.set(2, forKey: "sessionLength")

        let statsManager = MockStatsManager()
        let sut = makeSUT(statsManager: statsManager)

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.nextQuestion()

        sut.revealAnswer()
        sut.nextQuestion()

        XCTAssertEqual(statsManager.recordSessionCallCount, 1)
        XCTAssertEqual(statsManager.lastRecordedScore, 1)
        XCTAssertEqual(statsManager.lastRecordedTotal, 2)
    }

    // MARK: - Избранное (добавлено при редизайне)

    func testToggleFavoriteUpdatesIsCurrentFavorite() {
        let favoritesManager = MockFavoritesManager()
        let sut = makeSUT(favoritesManager: favoritesManager)

        XCTAssertFalse(sut.isCurrentFavorite)

        sut.toggleFavorite()
        XCTAssertTrue(sut.isCurrentFavorite)

        sut.toggleFavorite()
        XCTAssertFalse(sut.isCurrentFavorite)
    }

    // MARK: - Достижения (новое)

    func testSubmitCorrectAnswerRecordsAnswerWithTypingMode() {
        let progressTracker = MockProgressManager()
        let sut = makeSUT(progressTracker: progressTracker)

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()

        XCTAssertEqual(progressTracker.totalLearnedWordsCount(mode: .typing), 1)
        XCTAssertEqual(progressTracker.totalLearnedWordsCount(mode: .multipleChoice), 0)
    }

    func testRevealAnswerDoesNotCountAsLearned() {
        let progressTracker = MockProgressManager()
        let sut = makeSUT(progressTracker: progressTracker)

        sut.revealAnswer()

        XCTAssertEqual(progressTracker.totalLearnedWordsCount(mode: .typing), 0)
    }

    func testNoAchievementUnlockedWhenTargetNotReached() {
        let sut = makeSUT()

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()

        XCTAssertNil(sut.newlyUnlockedAchievement)
    }

    func testPerfectSessionRecordsFlagOnCompletion() {
        UserDefaults.standard.set(2, forKey: "sessionLength")

        let progressTracker = MockProgressManager()
        let sut = makeSUT(progressTracker: progressTracker)

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.nextQuestion()

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.nextQuestion()

        XCTAssertTrue(progressTracker.hasPerfectSession(mode: .typing))
    }

    func testImperfectSessionDoesNotRecordFlag() {
        UserDefaults.standard.set(2, forKey: "sessionLength")

        let progressTracker = MockProgressManager()
        let sut = makeSUT(progressTracker: progressTracker)

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.nextQuestion()

        sut.revealAnswer() // засчитывается как неверный
        sut.nextQuestion()

        XCTAssertFalse(progressTracker.hasPerfectSession(mode: .typing))
    }

    func testPerfectSessionUnlocksAchievement() {
        UserDefaults.standard.set(1, forKey: "sessionLength")

        let progressTracker = MockProgressManager()
        let achievementsManager = MockAchievementsManager()
        let sut = makeSUT(progressTracker: progressTracker, achievementsManager: achievementsManager)

        sut.userInput = sut.correctAnswerText
        sut.submitAnswer()
        sut.nextQuestion()

        XCTAssertTrue(sut.isSessionFinished)
        XCTAssertEqual(sut.newlyUnlockedAchievement?.id, "typing_perfect_session")
    }
}
