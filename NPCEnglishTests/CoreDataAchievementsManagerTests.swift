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
    private var statsManager: MockStatsManager!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        sut = CoreDataAchievementsManager(context: stack.viewContext)
        progressTracker = MockProgressManager()
        statsManager = MockStatsManager()
    }

    override func tearDown() {
        stack = nil
        sut = nil
        progressTracker = nil
        statsManager = nil
        super.tearDown()
    }

    func testAchievementNotUnlockedInitially() {
        XCTAssertFalse(sut.isUnlocked("quiz_100_words"))
        XCTAssertNil(sut.unlockedDate(for: "quiz_100_words"))
    }

    func testCheckAndUnlockReturnsEmptyWhenNoProgressMade() {
        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.isEmpty)
    }

    func testCheckAndUnlockDetectsReachedTarget() {
        for id in 1...100 {
            progressTracker.markLearned(wordID: id, in: .a1Words, mode: .multipleChoice)
        }

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_100_words" })
        XCTAssertTrue(sut.isUnlocked("quiz_100_words"))
        XCTAssertNotNil(sut.unlockedDate(for: "quiz_100_words"))
    }

    func testAlreadyUnlockedAchievementIsNotReturnedAgain() {
        for id in 1...100 {
            progressTracker.markLearned(wordID: id, in: .a1Words, mode: .multipleChoice)
        }

        let firstCheck = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)
        let secondCheck = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(firstCheck.contains { $0.id == "quiz_100_words" })
        XCTAssertFalse(secondCheck.contains { $0.id == "quiz_100_words" })
    }

    func testModesAreIndependentForUnlocking() {
        for id in 1...100 {
            progressTracker.markLearned(wordID: id, in: .a1Words, mode: .multipleChoice)
        }

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_100_words" })
        XCTAssertFalse(unlocked.contains { $0.id == "typing_100_words" })
        XCTAssertFalse(sut.isUnlocked("typing_100_words"))
    }

    func testWordSetCompletionAchievementUnlocks() {
        let phrasalVerbs = WordsLoader.loadWords(for: .phrasalVerbs)
        for word in phrasalVerbs {
            progressTracker.markLearned(wordID: word.id, in: .phrasalVerbs, mode: .multipleChoice)
        }

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_phrasal_verbs_complete" })
    }

    func testMultipleAchievementsCanUnlockInOneCheck() {
        for id in 1...500 {
            progressTracker.markLearned(wordID: id, in: .a1Words, mode: .multipleChoice)
        }

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_100_words" })
        XCTAssertTrue(unlocked.contains { $0.id == "quiz_500_words" })
    }

    // MARK: - Perfect session achievements

    func testQuizPerfectSessionAchievementUnlocks() {
        progressTracker.recordPerfectSession(mode: .multipleChoice)

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_perfect_session" })
        XCTAssertTrue(sut.isUnlocked("quiz_perfect_session"))
    }

    func testTypingPerfectSessionAchievementUnlocks() {
        progressTracker.recordPerfectSession(mode: .typing)

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.contains { $0.id == "typing_perfect_session" })
        XCTAssertTrue(sut.isUnlocked("typing_perfect_session"))
    }

    func testPerfectSessionAchievementsAreIndependentByMode() {
        progressTracker.recordPerfectSession(mode: .multipleChoice)

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.contains { $0.id == "quiz_perfect_session" })
        XCTAssertFalse(unlocked.contains { $0.id == "typing_perfect_session" })
        XCTAssertFalse(sut.isUnlocked("typing_perfect_session"))
    }

    // MARK: - Streak achievements (новое)

    func testStreak7DaysUnlocksWhenTargetReached() {
        statsManager.currentStreak = 7

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.contains { $0.id == "streak_7_days" })
        XCTAssertTrue(sut.isUnlocked("streak_7_days"))
    }

    func testStreak7DaysNotUnlockedBelowTarget() {
        statsManager.currentStreak = 6

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertFalse(unlocked.contains { $0.id == "streak_7_days" })
        XCTAssertFalse(sut.isUnlocked("streak_7_days"))
    }

    func testStreak30DaysUnlocksAndAlsoUnlocks7DaysAtTheSameTime() {
        statsManager.currentStreak = 30

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        // 30-дневный стрик автоматически means, что 7-дневный порог тоже пройден —
        // оба достижения должны разблокироваться в одной проверке.
        XCTAssertTrue(unlocked.contains { $0.id == "streak_7_days" })
        XCTAssertTrue(unlocked.contains { $0.id == "streak_30_days" })
    }

    func testStreakAchievementDoesNotDependOnWordProgress() {
        // Стрик не должен смешиваться с прогрессом по словам — проверяем изолированно
        statsManager.currentStreak = 7

        let unlocked = sut.checkAndUnlockAchievements(progressTracker: progressTracker, statsManager: statsManager)

        XCTAssertTrue(unlocked.contains { $0.id == "streak_7_days" })
        XCTAssertFalse(unlocked.contains { $0.id == "quiz_100_words" })
    }
}
