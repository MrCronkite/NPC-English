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

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "sessionLength")
        super.tearDown()
    }
    
    private func makeSUT(
        wordSet: WordSet = .a1Words,
        favoritesManager: FavoritesManaging = MockFavoritesManager(),
        statsManager: StatsManaging = MockStatsManager(),
        speechManager: SpeechSynthesizing = MockSpeechManager(),
        progressTracker: WordProgressTracking = MockProgressManager(),
        achievementsManager: AchievementsManaging = MockAchievementsManager()
    ) -> QuizViewModel {
        QuizViewModel(
            wordSet: wordSet,
            favoritesManager: favoritesManager,
            statsManager: statsManager,
            speechManager: speechManager,
            progressTracker: progressTracker,
            achievementsManager: achievementsManager
        )
    }

    func testInitLoadsWordsAndGeneratesFourOptions() {
        let sut = makeSUT()

        XCTAssertNotNil(sut.currentWord)
        XCTAssertEqual(sut.options.count, 4)
        XCTAssertTrue(sut.options.contains(where: { $0.id == sut.currentWord?.id }))
    }

    func testSelectCorrectOptionIncrementsScore() {
        let sut = makeSUT()

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
        let sut = makeSUT()

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
        let sut = makeSUT()

        let firstOption = sut.options[0]
        let secondOption = sut.options[1]

        sut.select(firstOption)
        sut.select(secondOption)

        XCTAssertEqual(sut.total, 1)
    }

    func testSessionFinishesAfterPlannedQuestions() {
        UserDefaults.standard.set(3, forKey: "sessionLength")

        let sut = makeSUT()

        for _ in 0..<3 {
            guard let option = sut.options.first else { break }
            sut.select(option)
            sut.nextQuestion()
        }

        XCTAssertTrue(sut.isSessionFinished)
    }

    func testToggleFavoriteUpdatesIsCurrentFavorite() {
        let favoritesManager = MockFavoritesManager()
        let sut = makeSUT(favoritesManager: favoritesManager)

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

        let sut = QuizViewModel(
            favoritesManager: favoritesManager,
            statsManager: MockStatsManager(),
            speechManager: MockSpeechManager(),
            progressTracker: MockProgressManager(),
            achievementsManager: MockAchievementsManager()
        )

        XCTAssertEqual(sut.allWords.count, 4)
        XCTAssertTrue(sut.allWords.allSatisfy { favoritedIDs.contains($0.word.id) })
    }

    func testFavoritesWithMatchingIDsKeepTheirSourcesSeparate() {
        let favorites = MockFavoritesManager()
        for set in [WordSet.a1Words, .a2Words] {
            for id in [1, 2] { favorites.toggleFavorite(wordID: id, in: set) }
        }
        let progress = MockProgressManager()
        let sut = QuizViewModel(favoritesManager: favorites, statsManager: MockStatsManager(),
                                speechManager: MockSpeechManager(), progressTracker: progress,
                                achievementsManager: MockAchievementsManager())

        XCTAssertEqual(Set(sut.options.map(\.id)).count, 4)
        guard let current = sut.currentWord,
              let other = sut.options.first(where: { $0.word.id == current.word.id && $0.wordSet != current.wordSet }) else {
            return XCTFail("Words from both sets should appear as distinct options")
        }
        sut.select(other)
        XCTAssertFalse(sut.isCorrect)
        let category = current.word.category.flatMap(WordCategory.init(rawValue:))
        XCTAssertEqual(progress.snapshot(for: current.wordSet, category: category)[current.word.id]?.timesIncorrect, 1)
        XCTAssertNil(progress.snapshot(for: other.wordSet, category: other.word.category.flatMap(WordCategory.init(rawValue:)))[other.word.id])
        sut.toggleFavorite()
        XCTAssertFalse(favorites.isFavorite(wordID: current.word.id, in: current.wordSet))
        XCTAssertTrue(favorites.isFavorite(wordID: other.word.id, in: other.wordSet))
    }

    // MARK: - Достижения (новое)

    func testSelectRecordsAnswerWithMultipleChoiceMode() {
        let progressTracker = MockProgressManager()
        let sut = makeSUT(progressTracker: progressTracker)

        guard let correctOption = sut.options.first(where: { $0.id == sut.currentWord?.id }) else {
            XCTFail("Правильный вариант должен быть среди options")
            return
        }

        sut.select(correctOption)

        XCTAssertEqual(progressTracker.totalLearnedWordsCount(mode: .multipleChoice), 1)
        XCTAssertEqual(progressTracker.totalLearnedWordsCount(mode: .typing), 0)
    }

    func testSelectTriggersAchievementCheck() {
        let progressTracker = MockProgressManager()
        let achievementsManager = MockAchievementsManager()

        // Заранее доводим прогресс до 99 слов — следующий правильный ответ должен разблокировать 100-е
        let allWords = WordsLoader.loadWords(for: .a1Words)
        for word in allWords.prefix(99) {
            progressTracker.markLearned(wordID: word.id, in: .a1Words, mode: .multipleChoice)
        }

        let sut = makeSUT(progressTracker: progressTracker, achievementsManager: achievementsManager)

        guard let correctOption = sut.options.first(where: { $0.id == sut.currentWord?.id }) else {
            XCTFail("Правильный вариант должен быть среди options")
            return
        }

        sut.select(correctOption)

        // Если выбранное слово ещё не было в первых 99 — это как раз 100-е уникальное слово
        if progressTracker.totalLearnedWordsCount(mode: .multipleChoice) >= 100 {
            XCTAssertNotNil(sut.newlyUnlockedAchievement)
            XCTAssertEqual(sut.newlyUnlockedAchievement?.id, "quiz_100_words")
        }
    }

    func testNoAchievementUnlockedWhenTargetNotReached() {
        let sut = makeSUT()

        guard let correctOption = sut.options.first(where: { $0.id == sut.currentWord?.id }) else {
            XCTFail("Правильный вариант должен быть среди options")
            return
        }

        sut.select(correctOption)

        XCTAssertNil(sut.newlyUnlockedAchievement)
    }

    func testPerfectSessionRecordsFlagOnCompletion() {
        UserDefaults.standard.set(3, forKey: "sessionLength")

        let progressTracker = MockProgressManager()
        let sut = makeSUT(progressTracker: progressTracker)

        for _ in 0..<3 {
            guard let correctOption = sut.options.first(where: { $0.id == sut.currentWord?.id }) else {
                XCTFail("Правильный вариант должен быть среди options")
                return
            }
            sut.select(correctOption)
            sut.nextQuestion()
        }

        XCTAssertTrue(progressTracker.hasPerfectSession(mode: .multipleChoice))
    }

    func testImperfectSessionDoesNotRecordFlag() {
        UserDefaults.standard.set(2, forKey: "sessionLength")

        let progressTracker = MockProgressManager()
        let sut = makeSUT(progressTracker: progressTracker)

        // Первый ответ верный
        guard let correctOption = sut.options.first(where: { $0.id == sut.currentWord?.id }) else {
            XCTFail("Правильный вариант должен быть среди options")
            return
        }
        sut.select(correctOption)
        sut.nextQuestion()

        // Второй ответ неверный
        guard let wrongOption = sut.options.first(where: { $0.id != sut.currentWord?.id }) else {
            XCTFail("Должен быть хотя бы один неверный вариант")
            return
        }
        sut.select(wrongOption)
        sut.nextQuestion()

        XCTAssertFalse(progressTracker.hasPerfectSession(mode: .multipleChoice))
    }

    func testPerfectSessionUnlocksAchievement() {
        UserDefaults.standard.set(1, forKey: "sessionLength")

        let progressTracker = MockProgressManager()
        let achievementsManager = MockAchievementsManager()
        let sut = makeSUT(progressTracker: progressTracker, achievementsManager: achievementsManager)

        guard let correctOption = sut.options.first(where: { $0.id == sut.currentWord?.id }) else {
            XCTFail("Правильный вариант должен быть среди options")
            return
        }
        sut.select(correctOption)
        sut.nextQuestion()

        XCTAssertTrue(sut.isSessionFinished)
        XCTAssertEqual(sut.newlyUnlockedAchievement?.id, "quiz_perfect_session")
    }
}
