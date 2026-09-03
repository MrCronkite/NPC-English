//
//  CoreDataAchievementsManagerTests.swift
//  NPCEnglishTests
//
//  Created by Влад Шимченко on 30.08.2026.
//

import XCTest
@testable import NPCEnglish

@MainActor
final class CoreDataAchievementsManagerTests: XCTestCase {
    private var stack: CoreDataStack!
    private var sut: CoreDataAchievementsManager!
    private var progressTracker: MockProgressManager!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        sut = CoreDataAchievementsManager(context: stack.viewContext)
        progressTracker = MockProgressManager()
    }

    override func tearDown() {
        stack = nil
        sut = nil
        progressTracker = nil
        super.tearDown()
    }

    func testAchievementNotUnlockedInitially() {
        XCTAssertFalse(sut.isUnlocked("quiz_100_words"))
        XCTAssertNil(sut.unlockedDate(for: "quiz_100_words"))
    }

    func testCheckAndUnlockReturnsEmptyWhenNoProgressMade() {
        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker)

        XCTAssertTrue(unlocked.isEmpty)
    }

    func testCheckAndUnlockDetectsReachedTarget() {
        for id in 1...100 {
            progressTracker.markLearned(wordID: id, in: .a1Words, mode: .multipleChoice)
        }

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_100_words" })
        XCTAssertTrue(sut.isUnlocked("quiz_100_words"))
        XCTAssertNotNil(sut.unlockedDate(for: "quiz_100_words"))
    }

    func testAlreadyUnlockedAchievementIsNotReturnedAgain() {
        for id in 1...100 {
            progressTracker.markLearned(wordID: id, in: .a1Words, mode: .multipleChoice)
        }

        let firstCheck = sut.checkAndUnlockAchievements(progressTracker: progressTracker)
        let secondCheck = sut.checkAndUnlockAchievements(progressTracker: progressTracker)

        XCTAssertTrue(firstCheck.contains { $0.id == "quiz_100_words" })
        XCTAssertFalse(secondCheck.contains { $0.id == "quiz_100_words" })
    }

    func testModesAreIndependentForUnlocking() {
        for id in 1...100 {
            progressTracker.markLearned(wordID: id, in: .a1Words, mode: .multipleChoice)
        }

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_100_words" })
        XCTAssertFalse(unlocked.contains { $0.id == "typing_100_words" })
        XCTAssertFalse(sut.isUnlocked("typing_100_words"))
    }

    func testWordSetCompletionAchievementUnlocks() {
        let phrasalVerbs = WordsLoader.loadWords(for: .phrasalVerbs)
        for word in phrasalVerbs {
            progressTracker.markLearned(wordID: word.id, in: .phrasalVerbs, mode: .multipleChoice)
        }

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_phrasal_verbs_complete" })
    }

    func testMultipleAchievementsCanUnlockInOneCheck() {
        for id in 1...500 {
            progressTracker.markLearned(wordID: id, in: .a1Words, mode: .multipleChoice)
        }

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_100_words" })
        XCTAssertTrue(unlocked.contains { $0.id == "quiz_500_words" })
    }

    func testQuizPerfectSessionAchievementUnlocks() {
        progressTracker.recordPerfectSession(mode: .multipleChoice)

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_perfect_session" })
        XCTAssertTrue(sut.isUnlocked("quiz_perfect_session"))
    }

    func testTypingPerfectSessionAchievementUnlocks() {
        progressTracker.recordPerfectSession(mode: .typing)

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker)

        XCTAssertTrue(unlocked.contains { $0.id == "typing_perfect_session" })
        XCTAssertTrue(sut.isUnlocked("typing_perfect_session"))
    }

    func testPerfectSessionAchievementsAreIndependentByMode() {
        progressTracker.recordPerfectSession(mode: .multipleChoice)

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_perfect_session" })
        XCTAssertFalse(unlocked.contains { $0.id == "typing_perfect_session" })
        XCTAssertFalse(sut.isUnlocked("typing_perfect_session"))
    }
}
