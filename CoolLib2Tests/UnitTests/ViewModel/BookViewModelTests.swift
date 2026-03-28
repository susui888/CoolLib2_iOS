//
//  BookViewModelTests.swift
//  CoolLib2Tests
//
//  Created by susui on 2026/3/27.
//

import XCTest
@testable import CoolLib2

@MainActor
final class BookViewModelTests: XCTestCase {
    
    private var viewModel: BookViewModel!
    private var mockRepo: MockBookRepository!
    
    override func setUp() {
        super.setUp()
        // 1. Initialize Mock Repository
        mockRepo = MockBookRepository()
        
        // 2. Inject into the real BookUseCases struct
        let realUseCase = BookUseCases(repository: mockRepo)
        
        // 3. Initialize ViewModel
        viewModel = BookViewModel(usecase: realUseCase)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepo = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_initialState_shouldBeIdle() {
        if case .idle = viewModel.state {
            // Success
        } else {
            XCTFail("Initial state should be .idle")
        }
    }
    
    func test_search_success_updatesStateToSuccess() async throws {
        // 1. Arrange
        let expectedBooks = MockBooks.list
        mockRepo.stubSearchBooks = expectedBooks
        let query = SearchQuery(searchTerm: "Sapiens")
        
        // 2. Act
        viewModel.search(query: query)
        
        // 3. Wait
        // Using 0.2s sleep to ensure the asynchronous Task inside ViewModel completes
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // 4. Assert
        switch viewModel.state {
        case .success(let books):
            // Check if the count matches
            XCTAssertEqual(books.count, expectedBooks.count, "The number of books should match the mock data.")
            
            // Fix for shuffled order: compare IDs as a Set (order-independent)
            let returnedIds = Set(books.map { $0.id })
            let expectedIds = Set(expectedBooks.map { $0.id })
            XCTAssertEqual(returnedIds, expectedIds, "The set of returned book IDs should match the expected IDs.")
            
            // Verify a specific book exists (avoids issues with random ordering)
            XCTAssertTrue(books.contains { $0.title == "Sapiens: A Brief History of Humankind" }, "The list should contain the specific searched book.")
            
        case .loading:
            XCTFail("Test failed: State is still .loading. Try increasing sleep time or check for blocked UseCase.")
        case .error(let message):
            XCTFail("Test failed: Received .error state - \(message)")
        case .idle:
            XCTFail("Test failed: ViewModel is still .idle. The Task might not have started.")
        }
    }
    
    func test_search_failure_updatesStateToError() async throws {
        // Arrange
        mockRepo.shouldThrowError = true
        let query = SearchQuery(searchTerm: "ErrorTest")
        
        // Act
        viewModel.search(query: query)
        
        // Wait for asynchronous Task
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        if case .error(let message) = viewModel.state {
            XCTAssertFalse(message.isEmpty, "Error message should not be empty on failure.")
        } else {
            XCTFail("Expected state to be .error, but got \(viewModel.state) instead.")
        }
    }
}
