//
//  CoreDataProgressManagerTests.swift
//  NPCEnglishTests
//
//  Created by Влад Шимченко on 18.08.2026.
//

import XCTest
@testable import NPCEnglish

final class CoreDataProgressManagerTests: XCTestCase {
    private var stack: CoreDataStack!
    private var sut: CoreDataProgressManager!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        sut = CoreDataProgressManager(context: stack.viewContext)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "hasPerfectSession_multipleChoice")
        UserDefaults.standard.removeObject(forKey: "hasPerfectSession_typing")
        stack = nil
        sut = nil
        super.tearDown()
    }
    
    func testRecordAnswerCreatesEntityOnFirstCall() {
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)

        let snapshot = sut.snapshot(for: .a1Words, category: nil)

        XCTAssertEqual(snapshot[1]?.timesCorrect, 1)
        XCTAssertEqual(snapshot[1]?.timesIncorrect, 0)
        XCTAssertNotNil(snapshot[1]?.lastReviewed)
    }

    func testRecordAnswerAccumulatesAcrossCalls() {
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: false)
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: false)

        let snapshot = sut.snapshot(for: .a1Words, category: nil)

        XCTAssertEqual(snapshot[1]?.timesCorrect, 1)
        XCTAssertEqual(snapshot[1]?.timesIncorrect, 2)
    }

    func testSameIDDifferentWordSetsAreIndependent() {
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: false)
        sut.recordAnswer(wordID: 1, in: .phrasalVerbs, category: nil, mode: .multipleChoice, isCorrect: true)

        let a1Snapshot = sut.snapshot(for: .a1Words, category: nil)
        let phrasalSnapshot = sut.snapshot(for: .phrasalVerbs, category: nil)

        XCTAssertEqual(a1Snapshot[1]?.timesIncorrect, 1)
        XCTAssertEqual(phrasalSnapshot[1]?.timesCorrect, 1)
    }

    func testSnapshotForUnrelatedWordSetIsEmpty() {
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)

        let snapshot = sut.snapshot(for: .a2Words, category: nil)

        XCTAssertTrue(snapshot.isEmpty)
    }

    // MARK: - Раздельность режимов (новое)

    func testSameWordDifferentModesAreTrackedIndependently() {
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .typing, isCorrect: false)

        XCTAssertEqual(sut.totalLearnedWordsCount(mode: .multipleChoice), 1)
        XCTAssertEqual(sut.totalLearnedWordsCount(mode: .typing), 0)
    }

    func testSnapshotAggregatesBothModesForSpacedRepetition() {
        // snapshot(for:category:) должен объединять прогресс из обоих режимов —
        // используется для взвешивания в SpacedRepetitionSelector, где режим не важен.
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .typing, isCorrect: false)

        let snapshot = sut.snapshot(for: .a1Words, category: nil)

        XCTAssertEqual(snapshot[1]?.timesCorrect, 1)
        XCTAssertEqual(snapshot[1]?.timesIncorrect, 1)
    }

    // MARK: - totalLearnedWordsCount

    func testTotalLearnedWordsCountCountsUniqueWordsAcrossWordSets() {
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)
        sut.recordAnswer(wordID: 2, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)
        sut.recordAnswer(wordID: 1, in: .phrasalVerbs, category: nil, mode: .multipleChoice, isCorrect: true)

        XCTAssertEqual(sut.totalLearnedWordsCount(mode: .multipleChoice), 3)
    }

    func testTotalLearnedWordsCountExcludesWordsWithOnlyIncorrectAnswers() {
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: false)
        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: false)

        XCTAssertEqual(sut.totalLearnedWordsCount(mode: .multipleChoice), 0)
    }

    // MARK: - isWordSetFullyLearned

    func testIsWordSetFullyLearnedTrueWhenAllWordsHaveCorrectAnswer() {
        let words = [
            Word(id: 1, english: "one", translation: "один", category: nil),
            Word(id: 2, english: "two", translation: "два", category: nil)
        ]

        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)
        sut.recordAnswer(wordID: 2, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)

        XCTAssertTrue(sut.isWordSetFullyLearned(words, wordSet: .a1Words, category: nil, mode: .multipleChoice))
    }

    func testIsWordSetFullyLearnedFalseWhenSomeWordsMissing() {
        let words = [
            Word(id: 1, english: "one", translation: "один", category: nil),
            Word(id: 2, english: "two", translation: "два", category: nil)
        ]

        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)

        XCTAssertFalse(sut.isWordSetFullyLearned(words, wordSet: .a1Words, category: nil, mode: .multipleChoice))
    }

    func testIsWordSetFullyLearnedFalseForEmptyWordList() {
        XCTAssertFalse(sut.isWordSetFullyLearned([], wordSet: .a1Words, category: nil, mode: .multipleChoice))
    }

    func testIsWordSetFullyLearnedRespectsMode() {
        let words = [Word(id: 1, english: "one", translation: "один", category: nil)]

        sut.recordAnswer(wordID: 1, in: .a1Words, category: nil, mode: .multipleChoice, isCorrect: true)

        XCTAssertTrue(sut.isWordSetFullyLearned(words, wordSet: .a1Words, category: nil, mode: .multipleChoice))
        XCTAssertFalse(sut.isWordSetFullyLearned(words, wordSet: .a1Words, category: nil, mode: .typing))
    }

    func testHasPerfectSessionFalseInitially() {
        XCTAssertFalse(sut.hasPerfectSession(mode: .multipleChoice))
        XCTAssertFalse(sut.hasPerfectSession(mode: .typing))
    }

    func testRecordPerfectSessionSetsFlag() {
        sut.recordPerfectSession(mode: .multipleChoice)

        XCTAssertTrue(sut.hasPerfectSession(mode: .multipleChoice))
    }

    func testPerfectSessionModesAreIndependent() {
        sut.recordPerfectSession(mode: .multipleChoice)

        XCTAssertTrue(sut.hasPerfectSession(mode: .multipleChoice))
        XCTAssertFalse(sut.hasPerfectSession(mode: .typing))
    }

    func testRecordPerfectSessionIsIdempotent() {
        sut.recordPerfectSession(mode: .multipleChoice)
        sut.recordPerfectSession(mode: .multipleChoice)

        XCTAssertTrue(sut.hasPerfectSession(mode: .multipleChoice))
    }
}
