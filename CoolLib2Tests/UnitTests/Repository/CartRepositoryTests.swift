//
//  CartRepositoryTests.swift
//  CoolLib2Tests
//
//  Created by Ryan Su on 2026/3/27.
//

import SwiftData
import XCTest

@testable import CoolLib2

@MainActor
final class CartRepositoryTests: XCTestCase {

    // MARK: - Properties
    private var repository: CartRepositoryImpl!
    private var modelContainer: ModelContainer!
    private var context: ModelContext!
    private var mockLoanAPI: MockLoanAPI!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()

        // Initialize In-Memory SwiftData Stack
        let schema = Schema([CartEntity.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: config
            )
            context = modelContainer.mainContext

            mockLoanAPI = MockLoanAPI()
            repository = CartRepositoryImpl(
                loanAPI: mockLoanAPI,
                modelContext: context
            )
        } catch {
            XCTFail("Failed to initialize ModelContainer: \(error)")
        }
    }

    override func tearDown() {
        repository = nil
        context = nil
        modelContainer = nil
        mockLoanAPI = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_borrowBooks_success() async throws {
        // Arrange
        let testCarts = [MockCart.list[0]]

        // Act
        let result = try await repository.borrowBooks(carts: testCarts)

        // Assert
        XCTAssertEqual(result, "Success")
    }

    func test_borrowBooks_failure() async throws {
        // Arrange
        mockLoanAPI.shouldThrowError = true
        let testCarts = [MockCart.list[0]]

        // Act & Assert
        do {
            _ = try await repository.borrowBooks(carts: testCarts)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_addToCart_shouldPersistInDatabase() async throws {
        // Arrange
        let testBook = MockBooks.list[0]

        // Act
        try await repository.addToCart(book: testBook)

        // Assert
        // ✅ Fix: Await the result first, then assert
        let isInCart = try await repository.isBookInCart(bookId: testBook.id)
        XCTAssertTrue(isInCart, "Book should be in the cart after adding")

        let allItems = try await repository.allCartItems()
        XCTAssertEqual(allItems.count, 1)
        XCTAssertEqual(allItems.first?.id, testBook.id)
    }

    func test_removeFromCart_shouldDeleteFromDatabase() async throws {
        // Arrange: Pre-insert a book
        let testBook = MockBooks.list[0]
        try await repository.addToCart(book: testBook)

        // Act
        try await repository.removeFromCart(bookId: testBook.id)

        // Assert
        // ✅ Fix: Await the result first
        let isInCart = try await repository.isBookInCart(bookId: testBook.id)
        XCTAssertFalse(isInCart, "Book should be removed from cart")
    }

    func test_toggleCart_shouldSwitchStates() async throws {
        // Arrange
        let testBook = MockBooks.list[1]

        // Act 1: Toggle ON (Add)
        try await repository.toggleCart(book: testBook)
        let statusAfterAdd = try await repository.isBookInCart(
            bookId: testBook.id
        )
        XCTAssertTrue(
            statusAfterAdd,
            "Status should be TRUE after first toggle"
        )

        // Act 2: Toggle OFF (Remove)
        try await repository.toggleCart(book: testBook)
        let statusAfterRemove = try await repository.isBookInCart(
            bookId: testBook.id
        )
        XCTAssertFalse(
            statusAfterRemove,
            "Status should be FALSE after second toggle"
        )
    }

    func test_allCartItems_shouldBeSortedByCreatedAtDescending() async throws {
        // Arrange: Add two books with a small delay
        let book1 = MockBooks.list[0]
        let book2 = MockBooks.list[1]

        try await repository.addToCart(book: book1)
        // Ensure time difference for sorting
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
        try await repository.addToCart(book: book2)

        // Act
        let items = try await repository.allCartItems()

        // Assert: Most recently added (book2) should be first
        XCTAssertEqual(items.count, 2)
        if items.count >= 2 {
            XCTAssertEqual(
                items[0].id,
                book2.id,
                "Most recently added item (ID: \(book2.id)) should be first"
            )
            XCTAssertEqual(
                items[1].id,
                book1.id,
                "Older item (ID: \(book1.id)) should be second"
            )
        }
    }

    func test_clearLocalCart_shouldRemoveAllEntries() async throws {
        // Arrange: Fill the cart
        try await repository.addToCart(book: MockBooks.list[0])
        try await repository.addToCart(book: MockBooks.list[1])

        // Act
        try await repository.clearLocalCart()

        // Assert
        let items = try await repository.allCartItems()
        XCTAssertTrue(items.isEmpty, "Cart should be empty after clearing")
    }

    func test_addToCart_duplicatePrevention() async throws {
        // Arrange
        let testBook = MockBooks.list[0]

        // Act: Add the same book twice
        try await repository.addToCart(book: testBook)
        try await repository.addToCart(book: testBook)

        // Assert
        let items = try await repository.allCartItems()
        XCTAssertEqual(
            items.count,
            1,
            "Duplicate prevention should ensure only one entry exists"
        )
    }
}
