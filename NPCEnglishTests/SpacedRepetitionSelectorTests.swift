//
//  SpacedRepetitionSelectorTests.swift
//  NPCEnglishTests
//
//  Created by Влад Шимченко on 18.08.2026.
//

import XCTest
@testable import NPCEnglish

final class SpacedRepetitionSelectorTests: XCTestCase {

    private let word1 = Word(id: 1, english: "apple", translation: "яблоко", category: nil)
    private let word2 = Word(id: 2, english: "house", translation: "дом", category: nil)

    func testNewWordHasBaselineWeight() {
        let weighted = SpacedRepetitionSelector.weightedWords(from: [word1], snapshot: [:])

        XCTAssertEqual(weighted[0].weight, 1.0)
        XCTAssertFalse(weighted[0].isReviewWord)
    }

    func testIncorrectAnswersIncreaseWeight() {
        let snapshot: [Int: WordProgressSnapshot] = [
            1: WordProgressSnapshot(timesCorrect: 0, timesIncorrect: 3, lastReviewed: nil)
        ]

        let weighted = SpacedRepetitionSelector.weightedWords(from: [word1], snapshot: snapshot)

        XCTAssertEqual(weighted[0].weight, 7.0) // 1.0 + 3*2.0
        XCTAssertTrue(weighted[0].isReviewWord)
    }

    func testCorrectAnswersDecreaseWeightButNotBelowMinimum() {
        let snapshot: [Int: WordProgressSnapshot] = [
            1: WordProgressSnapshot(timesCorrect: 20, timesIncorrect: 0, lastReviewed: nil)
        ]

        let weighted = SpacedRepetitionSelector.weightedWords(from: [word1], snapshot: snapshot)

        // 1.0 - min(20*0.3, 2.0) = 1.0 - 2.0 = -1.0, но clamp снизу даёт 0.2
        XCTAssertEqual(weighted[0].weight, 0.2)
        XCTAssertFalse(weighted[0].isReviewWord)
    }

    func testOldLastReviewedIncreasesWeight() {
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let snapshot: [Int: WordProgressSnapshot] = [
            1: WordProgressSnapshot(timesCorrect: 0, timesIncorrect: 0, lastReviewed: tenDaysAgo)
        ]

        let weighted = SpacedRepetitionSelector.weightedWords(from: [word1], snapshot: snapshot, referenceDate: Date())

        // 1.0 + min(10*0.5, 5.0) = 1.0 + 5.0 = 6.0
        XCTAssertEqual(weighted[0].weight, 6.0)
        XCTAssertTrue(weighted[0].isReviewWord)
    }

    func testPickRandomAlwaysPicksHighWeightWordWithLowRandomValue() {
        let weighted = [
            SpacedRepetitionSelector.WeightedWord(word: word1, weight: 9.0, isReviewWord: true),
            SpacedRepetitionSelector.WeightedWord(word: word2, weight: 1.0, isReviewWord: false)
        ]

        // randomValue близко к 0 — должен попасть в первый (более широкий) интервал веса
        let picked = SpacedRepetitionSelector.pickRandom(from: weighted, randomValue: 0.05)

        XCTAssertEqual(picked?.word.id, word1.id)
    }

    func testPickRandomPicksSecondWordWhenRandomValueIsHigh() {
        let weighted = [
            SpacedRepetitionSelector.WeightedWord(word: word1, weight: 9.0, isReviewWord: true),
            SpacedRepetitionSelector.WeightedWord(word: word2, weight: 1.0, isReviewWord: false)
        ]

        // totalWeight = 10, randomValue 0.95 -> target = 9.5, попадает во второе слово (9.0..10.0)
        let picked = SpacedRepetitionSelector.pickRandom(from: weighted, randomValue: 0.95)

        XCTAssertEqual(picked?.word.id, word2.id)
    }

    func testPickRandomReturnsNilForEmptyArray() {
        XCTAssertNil(SpacedRepetitionSelector.pickRandom(from: []))
    }
}
