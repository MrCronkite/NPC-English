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
        stack = nil
        sut = nil
        super.tearDown()
    }

    func testRecordAnswerCreatesEntityOnFirstCall() {
        sut.recordAnswer(wordID: 1, in: .a1Words, isCorrect: true)

        let snapshot = sut.snapshot(for: .a1Words)

        XCTAssertEqual(snapshot[1]?.timesCorrect, 1)
        XCTAssertEqual(snapshot[1]?.timesIncorrect, 0)
        XCTAssertNotNil(snapshot[1]?.lastReviewed)
    }

    func testRecordAnswerAccumulatesAcrossCalls() {
        sut.recordAnswer(wordID: 1, in: .a1Words, isCorrect: true)
        sut.recordAnswer(wordID: 1, in: .a1Words, isCorrect: false)
        sut.recordAnswer(wordID: 1, in: .a1Words, isCorrect: false)

        let snapshot = sut.snapshot(for: .a1Words)

        XCTAssertEqual(snapshot[1]?.timesCorrect, 1)
        XCTAssertEqual(snapshot[1]?.timesIncorrect, 2)
    }

    func testSameIDDifferentWordSetsAreIndependent() {
        sut.recordAnswer(wordID: 1, in: .a1Words, isCorrect: false)
        sut.recordAnswer(wordID: 1, in: .phrasalVerbs, isCorrect: true)

        let a1Snapshot = sut.snapshot(for: .a1Words)
        let phrasalSnapshot = sut.snapshot(for: .phrasalVerbs)

        XCTAssertEqual(a1Snapshot[1]?.timesIncorrect, 1)
        XCTAssertEqual(phrasalSnapshot[1]?.timesCorrect, 1)
    }

    func testSnapshotForUnrelatedWordSetIsEmpty() {
        sut.recordAnswer(wordID: 1, in: .a1Words, isCorrect: true)

        let snapshot = sut.snapshot(for: .a2Words)

        XCTAssertTrue(snapshot.isEmpty)
    }
}
