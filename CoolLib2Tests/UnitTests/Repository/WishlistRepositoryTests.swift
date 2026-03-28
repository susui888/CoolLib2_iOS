//
//  WishlistRepositoryTests.swift
//  CoolLib2Tests
//
//  Created by susui on 2026/3/27.
//

import XCTest
import SwiftData
@testable import CoolLib2

@MainActor
final class WishlistRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    private var repository: WishlistRepositoryImpl!
    private var modelContainer: ModelContainer!
    private var context: ModelContext!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        
        // 1. Initialize In-Memory SwiftData Stack for WishlistEntity
        let schema = Schema([WishlistEntity.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
            context = modelContainer.mainContext
            repository = WishlistRepositoryImpl(modelContext: context)
        } catch {
            XCTFail("Failed to initialize ModelContainer: \(error)")
        }
    }

    override func tearDown() {
        repository = nil
        context = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_addToWishlist_shouldSaveCorrectly() async throws {
        // Arrange
        let book = MockBooks.list[0]
        
        // Act
        try await repository.addToWishlist(book: book)
        
        // Assert
        let exists = try await repository.isBookInWishlist(bookId: book.id)
        XCTAssertTrue(exists, "Book should be saved in wishlist")
        
        let allItems = try await repository.allWishlistItems()
        XCTAssertEqual(allItems.count, 1)
        XCTAssertEqual(allItems.first?.id, book.id)
    }

    func test_removeFromWishlist_shouldDeleteCorrectly() async throws {
        // Arrange
        let book = MockBooks.list[0]
        try await repository.addToWishlist(book: book)
        
        // Act
        try await repository.removeFromWishlist(bookId: book.id)
        
        // Assert
        let exists = try await repository.isBookInWishlist(bookId: book.id)
        XCTAssertFalse(exists, "Book should be removed from wishlist")
    }

    func test_toggleWishlist_shouldAddThenRemove() async throws {
        // Arrange
        let book = MockBooks.list[1]
        
        // Act 1: First toggle (Add)
        try await repository.toggleWishlist(book: book)
        let statusAfterFirstToggle = try await repository.isBookInWishlist(bookId: book.id)
        XCTAssertTrue(statusAfterFirstToggle)
        
        // Act 2: Second toggle (Remove)
        try await repository.toggleWishlist(book: book)
        let statusAfterSecondToggle = try await repository.isBookInWishlist(bookId: book.id)
        XCTAssertFalse(statusAfterSecondToggle)
    }

    func test_allWishlistItems_shouldOrderDescendingByDate() async throws {
        // Arrange
        let book1 = MockBooks.list[0]
        let book2 = MockBooks.list[1]
        
        try await repository.addToWishlist(book: book1)
        // Add a small delay to ensure different createdAt timestamps
        try await Task.sleep(nanoseconds: 50_000_000)
        try await repository.addToWishlist(book: book2)
        
        // Act
        let items = try await repository.allWishlistItems()
        
        // Assert
        XCTAssertEqual(items.count, 2)
        if items.count >= 2 {
            XCTAssertEqual(items[0].id, book2.id, "Most recent added should be first")
            XCTAssertEqual(items[1].id, book1.id)
        }
    }

    func test_clearWishlist_shouldWipeAllData() async throws {
        // Arrange
        try await repository.addToWishlist(book: MockBooks.list[0])
        try await repository.addToWishlist(book: MockBooks.list[1])
        
        // Act
        try await repository.clearWishlist()
        
        // Assert
        let items = try await repository.allWishlistItems()
        XCTAssertTrue(items.isEmpty, "Wishlist should be completely empty")
    }

    func test_duplicateAdd_shouldNotInsertTwice() async throws {
        // Arrange
        let book = MockBooks.list[0]
        
        // Act
        try await repository.addToWishlist(book: book)
        try await repository.addToWishlist(book: book) // Try adding again
        
        // Assert
        let items = try await repository.allWishlistItems()
        XCTAssertEqual(items.count, 1, "Should prevent duplicate entries of the same book")
    }
}
