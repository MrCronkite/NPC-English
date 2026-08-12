//
//  AnswerCheckerTests.swift
//  NPCEnglishTests
//
//  Created by Влад Шимченко on 12.08.2026.
//

import XCTest
@testable import NPCEnglish

final class AnswerCheckerTests: XCTestCase {

    func testExactMatchSingleWord() {
        XCTAssertTrue(AnswerChecker.isCorrect(input: "backup", expected: "backup"))
    }

    func testCaseInsensitiveMatch() {
        XCTAssertTrue(AnswerChecker.isCorrect(input: "BackUp", expected: "backup"))
    }

    func testIgnoresLeadingAndTrailingWhitespace() {
        XCTAssertTrue(AnswerChecker.isCorrect(input: "  backup  ", expected: "backup"))
    }

    func testFullMultiWordAnswerMatchesExactly() {
        // Регрессия на баг, который мы только что нашли и починили:
        // ввод "резервная копия" должен засчитываться при expected "резервная копия"
        XCTAssertTrue(AnswerChecker.isCorrect(input: "резервная копия", expected: "резервная копия"))
    }

    func testSingleSignificantWordMatchesMultiWordExpected() {
        // Пользователь ответил короче, но по сути верно:
        // "снимать" засчитывается для "снимать деньги (со счёта)"
        XCTAssertTrue(AnswerChecker.isCorrect(input: "снимать", expected: "снимать деньги (со счёта)"))
    }

    func testOneTypoIsAllowedOnFullAnswer() {
        // Одна опечатка в целой фразе (пропущена буква) — Левенштейн = 1
        XCTAssertTrue(AnswerChecker.isCorrect(input: "резервная копя", expected: "резервная копия"))
    }

    func testOneTypoIsAllowedOnSingleWord() {
        // Одна опечатка в отдельном слове
        XCTAssertTrue(AnswerChecker.isCorrect(input: "снемать", expected: "снимать деньги (со счёта)"))
    }

    func testTwoTyposAreRejected() {
        // Расстояние Левенштейна 2 — уже не должно засчитываться
        XCTAssertFalse(AnswerChecker.isCorrect(input: "снжмасть", expected: "снимать"))
    }

    func testCompletelyWrongAnswerIsRejected() {
        XCTAssertFalse(AnswerChecker.isCorrect(input: "яблоко", expected: "снимать деньги (со счёта)"))
    }

    func testEmptyInputIsRejected() {
        XCTAssertFalse(AnswerChecker.isCorrect(input: "", expected: "backup"))
    }

    func testWhitespaceOnlyInputIsRejected() {
        XCTAssertFalse(AnswerChecker.isCorrect(input: "   ", expected: "backup"))
    }

    func testShortWordsInExpectedAreIgnoredAsCandidates() {
        // "и" (1 символ) не входит в significantWords и не должен матчиться
        // с "деньги" — а вот "и" vs "со" из другой фразы был бы плохим тест-кейсом
        // из-за случайной близости по Левенштейну, поэтому берём фразу без коротких слов рядом.
        XCTAssertFalse(AnswerChecker.isCorrect(input: "и", expected: "рыба и мясо"))
    }

    func testParenthesesAndPunctuationAreStrippedFromCandidates() {
        // "(со счёта)" должно разбиться на отдельные слова без скобок
        XCTAssertTrue(AnswerChecker.isCorrect(input: "счёта", expected: "снимать деньги (со счёта)"))
    }
}
