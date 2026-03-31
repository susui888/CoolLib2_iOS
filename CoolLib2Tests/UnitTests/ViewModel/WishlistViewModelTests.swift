//
//  WishlistViewModelTests.swift
//  CoolLib2Tests
//
//  Created by Ryan Su on 2026/3/27.
//

import XCTest
@testable import CoolLib2

@MainActor
final class WishlistViewModelTests: XCTestCase {
    
    private var viewModel: WishlistViewModel!
    private var mockRepo: MockWishlistRepository!
    
    override func setUp() {
        super.setUp()
        // 1. Initialize Mock Repository
        mockRepo = MockWishlistRepository()
        
        // 2. Inject into the real WishlistUseCases struct
        let realUseCase = WishlistUseCases(repository: mockRepo)
        
        // 3. Initialize ViewModel
        viewModel = WishlistViewModel(usecase: realUseCase)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_initialState_shouldBeIdle() {
        if case .idle = viewModel.state {
            // Success
        } else {
            XCTFail("Initial state must be .idle")
        }
    }

    // MARK: - Loading Tests

    func test_load_success_updatesStateToSuccess() async throws {
        // Arrange
        let expectedItems = MockWishlist.list
        mockRepo.stubWishlistItems = expectedItems
        
        // Act
        viewModel.load()
        
        // Verify immediate transition to loading
        if case .loading = viewModel.state {} else { XCTFail("State should immediately change to .loading") }
        
        // Wait for async task completion
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Assert
        switch viewModel.state {
        case .success(let items):
            XCTAssertEqual(items.count, expectedItems.count)
            // Order-independent ID check
            XCTAssertEqual(Set(items.map { $0.id }), Set(expectedItems.map { $0.id }))
        default:
            XCTFail("Expected .success state, but got \(viewModel.state)")
        }
    }

    // MARK: - Interaction Tests

    func test_toggleWishlist_removesItemIfAlreadyPresent() async throws {
        // Arrange
        let bookToToggle = MockBooks.list[0]
        let initialWishlistItem = Wishlist(
            id: bookToToggle.id,
            isbn: bookToToggle.isbn,
            title: bookToToggle.title,
            author: bookToToggle.author,
            publisher: bookToToggle.publisher
        )
        mockRepo.stubWishlistItems = [initialWishlistItem]
        
        // Act: Toggling an existing book should remove it
        viewModel.toggleWishlist(book: bookToToggle)
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Assert
        XCTAssertNotNil(mockRepo.toggleCalledWithBook)
        if case .success(let items) = viewModel.state {
            XCTAssertTrue(items.isEmpty, "Wishlist should be empty after toggling off an existing book.")
        } else {
            XCTFail("Expected .success with empty list")
        }
    }

    func test_removeWishlist_updatesStateAfterRemoval() async throws {
        // Arrange
        let bookIdToRemove = 262
        mockRepo.stubWishlistItems = [] // Simulate empty result after removal
        
        // Act
        viewModel.removeWishlist(bookId: bookIdToRemove)
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Assert
        XCTAssertEqual(mockRepo.removeCalledWithId, bookIdToRemove)
        if case .success(let items) = viewModel.state {
            XCTAssertTrue(items.isEmpty)
        }
    }

    // MARK: - Status Query Tests

    func test_isBookInWishlist_returnsCorrectValue() async {
        // Arrange
        let targetId = 270
        let item = Wishlist(id: targetId, isbn: "9780132350884", title: "Clean Code", author: "Uncle Bob", publisher: "Prentice Hall")
        mockRepo.stubWishlistItems = [item]
        
        // Act
        let isInWishlist = await viewModel.isBookInWishlist(bookId: targetId)
        let isNotInWishlist = await viewModel.isBookInWishlist(bookId: 999)
        
        // Assert
        XCTAssertTrue(isInWishlist)
        XCTAssertFalse(isNotInWishlist)
    }

    // MARK: - Batch Action Tests

    func test_clearWishlist_success_resetsStateToEmptySuccess() async throws {
        // Arrange
        mockRepo.stubWishlistItems = MockWishlist.list
        
        // Act
        viewModel.clearWishlist()
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Assert
        XCTAssertTrue(mockRepo.clearCalled)
        if case .success(let items) = viewModel.state {
            XCTAssertTrue(items.isEmpty)
        }
    }

    // MARK: - Error Handling Tests

    func test_load_failure_updatesStateToError() async throws {
        // Arrange
        mockRepo.shouldThrowError = true
        
        // Act
        viewModel.load()
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Assert
        if case .error(let message) = viewModel.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected .error state on repository failure")
        }
    }
}
