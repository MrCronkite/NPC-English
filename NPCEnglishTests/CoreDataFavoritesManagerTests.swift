//
//  CoreDataFavoritesManagerTests.swift
//  NPCEnglishTests
//
//  Created by Влад Шимченко on 02.08.2026.
//

import XCTest
@testable import NPCEnglish

final class CoreDataFavoritesManagerTests: XCTestCase {
    private var stack: CoreDataStack!
    private var sut: CoreDataFavoritesManager!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        sut = CoreDataFavoritesManager(context: stack.viewContext)
    }

    override func tearDown() {
        stack = nil
        sut = nil
        super.tearDown()
    }

    func testToggleFavoriteAddsAndRemoves() {
        XCTAssertFalse(sut.isFavorite(wordID: 1, in: .a1Words))

        sut.toggleFavorite(wordID: 1, in: .a1Words)
        XCTAssertTrue(sut.isFavorite(wordID: 1, in: .a1Words))

        sut.toggleFavorite(wordID: 1, in: .a1Words)
        XCTAssertFalse(sut.isFavorite(wordID: 1, in: .a1Words))
    }

    func testSameIDDifferentWordSetsAreIndependent() {
        // Проверяем главный edge case: id=1 существует в обоих JSON-наборах
        sut.toggleFavorite(wordID: 1, in: .a1Words)

        XCTAssertTrue(sut.isFavorite(wordID: 1, in: .a1Words))
        XCTAssertFalse(sut.isFavorite(wordID: 1, in: .phrasalVerbs))
    }

    func testFavoriteWordIDsReturnsOnlyFavorited() {
        sut.toggleFavorite(wordID: 1, in: .a1Words)
        sut.toggleFavorite(wordID: 5, in: .a1Words)
        sut.toggleFavorite(wordID: 10, in: .a1Words)
        sut.toggleFavorite(wordID: 10, in: .a1Words) // снова — снимаем избранное

        let ids = sut.favoriteWordIDs(in: .a1Words)

        XCTAssertEqual(Set(ids), Set([1, 5]))
    }
}
