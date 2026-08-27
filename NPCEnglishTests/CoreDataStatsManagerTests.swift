//
//  CoreDataStatsManagerTests.swift
//  NPCEnglishTests
//
//  Created by Влад Шимченко on 02.08.2026.
//

import XCTest
@testable import NPCEnglish

@MainActor
final class CoreDataStatsManagerTests: XCTestCase {
    private var stack: CoreDataStack!
    private var sut: CoreDataStatsManager!
    private var notificationManager: MockNotificationManager!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        notificationManager = MockNotificationManager()
        sut = CoreDataStatsManager(
            context: stack.viewContext,
            notificationManager: notificationManager
        )
    }

    override func tearDown() {
        stack = nil
        sut = nil
        notificationManager = nil
        super.tearDown()
    }

    func testFirstCompletedSessionSetsStreakToOne() {
        sut.recordSessionCompleted(score: 8, total: 10)

        XCTAssertEqual(sut.currentStreak, 1)
        XCTAssertEqual(sut.longestStreak, 1)
        XCTAssertEqual(sut.totalStats.answered, 10)
        XCTAssertEqual(sut.totalStats.correct, 8)
    }

    func testSecondSessionSameDayDoesNotIncreaseStreak() {
        sut.recordSessionCompleted(score: 5, total: 10)
        sut.recordSessionCompleted(score: 7, total: 10)

        XCTAssertEqual(sut.currentStreak, 1, "Второй раз в тот же день не должен увеличивать стрик")
        XCTAssertEqual(sut.totalStats.answered, 20, "Но тоталы должны суммироваться")
    }

    func testDailyStatsAggregatesMultipleSessionsInOneDay() {
        sut.recordSessionCompleted(score: 5, total: 10)
        sut.recordSessionCompleted(score: 7, total: 10)

        let today = sut.dailyStats(lastDays: 1)

        XCTAssertEqual(today.count, 1)
        XCTAssertEqual(today.first?.questionsAnswered, 20)
        XCTAssertEqual(today.first?.correctAnswers, 12)
    }

    func testRecordSessionCompletedCancelsStreakReminder() {
        sut.recordSessionCompleted(score: 8, total: 10)

        XCTAssertEqual(notificationManager.cancelCallCount, 1)
    }
}
