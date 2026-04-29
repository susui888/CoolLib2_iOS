//
//  BookDetailViewModelTests.swift
//  CoolLib2Tests
//
//  Created by Ryan Su on 2026/3/27.
//

import XCTest
@testable import CoolLib2

@MainActor
final class BookDetailViewModelTests: XCTestCase {
    
    private var viewModel: BookDetailViewModel!
    private var mockRepo: MockBookRepository!
    private var mockReviewRepo: MockReviewRepository!

    override func setUp() {
        super.setUp()
        // 1. Initialize Mock Repositories
        mockRepo = MockBookRepository()
        mockReviewRepo = MockReviewRepository()
        
        // 2. Inject into real UseCase structures
        let realUseCase = BookUseCases(repository: mockRepo)
        let reviewUseCase = ReviewUseCases(repository: mockReviewRepo)
        
        // 3. Initialize ViewModel with injected dependencies
        viewModel = BookDetailViewModel(usecase: realUseCase, reviewUseCase: reviewUseCase)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepo = nil
        mockReviewRepo = nil
        super.tearDown()
    }
    
    // MARK: - Book Detail Loading Tests
    
    func test_initialState_shouldBeLoading() {
        // According to the logic, the initial state must be .loading
        if case .loading = viewModel.state {
            // Success
        } else {
            XCTFail("Initial state should be .loading")
        }
    }
    
    func test_getBook_success_updatesStateAndReviews() async throws {
        // Arrange
        let targetId = 262
        let expectedBook = MockBooks.list.first { $0.id == targetId }!
        let expectedReviews = MockReviews.getReviews(forBookId: targetId)
        
        mockRepo.stubBookById = expectedBook
        mockReviewRepo.stubReviews = expectedReviews
        
        // Act
        viewModel.getBook(id: targetId)
        
        // Wait for the asynchronous Task to complete (0.1s)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        // 1. Verify State contains the correct Book object
        if case let .success(book) = viewModel.state {
            XCTAssertEqual(book.id, targetId)
            XCTAssertEqual(book.title, expectedBook.title)
        } else {
            XCTFail("Expected .success(Book), but got \(viewModel.state)")
        }
        
        // 2. Verify the independent reviews property is updated
        XCTAssertEqual(viewModel.reviews.count, expectedReviews.count)
    }
    
    func test_getBook_failure_updatesStateToError() async throws {
        // Arrange
        mockRepo.shouldThrowError = true
        
        // Act
        viewModel.getBook(id: 999)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        if case .error(let message) = viewModel.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected state to be .error")
        }
    }

    // MARK: - Review Submission Tests (Handling Unstructured Concurrency)

    func test_postReview_success_triggersRefreshAndStopsLoading() async throws {
        // Arrange
        let bookId = 270
        let rating = 5
        let content = "Excellent read!"
        
        mockReviewRepo.shouldThrowError = false
        mockReviewRepo.stubCreatedReview = Review(
            id: 999, bookId: bookId, userId: 1, userName: "Me",
            rating: rating, content: content, createdAt: Date()
        )
        
        // Act
        // postReview contains an internal Task { }, so it returns immediately
        viewModel.postReview(bookId: bookId, rating: rating, content: content)
        
        // Give the internal Task time to execute
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        
        // Assert
        XCTAssertEqual(mockReviewRepo.createReviewCallCount, 1, "Should call createReview once")
        XCTAssertEqual(mockReviewRepo.getReviewsCallCount, 1, "Should call loadReviews to refresh on success")
        XCTAssertFalse(viewModel.isPosting, "isPosting should be reset to false after completion")
    }
    
    func test_postReview_failure_doesNotRefreshAndStopsLoading() async throws {
        // Arrange
        mockReviewRepo.shouldThrowError = true
        
        // Act
        viewModel.postReview(bookId: 101, rating: 1, content: "Failure Test")
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Assert
        XCTAssertEqual(mockReviewRepo.createReviewCallCount, 1)
        XCTAssertEqual(mockReviewRepo.getReviewsCallCount, 0, "Should not refresh list if submission fails")
        XCTAssertFalse(viewModel.isPosting, "isPosting should be reset to false even on failure")
    }
}
