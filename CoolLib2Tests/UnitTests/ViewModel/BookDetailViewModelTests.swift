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
    
    override func setUp() {
        super.setUp()
        // 1. 使用合并后的公共 MockBookRepository
        mockRepo = MockBookRepository()
        
        // 2. 注入到真实的 struct BookUseCases
        let realUseCase = BookUseCases(repository: mockRepo)
        
        // 3. 初始化 ViewModel
        viewModel = BookDetailViewModel(usecase: realUseCase)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepo = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_initialState_shouldBeLoading() {
        // 根据你的代码，state 初始值就是 .loading
        if case .loading = viewModel.state {
            // Success
        } else {
            XCTFail("Initial state should be .loading")
        }
    }
    
    func test_getBook_success_updatesStateToSuccess() async throws {
        // Arrange
        let expectedBook = MockBooks.list[0]
        let targetId = expectedBook.id
        
        // 在 Mock 中准备好特定的返回数据
        mockRepo.stubBookById = expectedBook
        
        // Act
        viewModel.getBook(id: targetId)
        
        // 等待异步 Task 完成
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        // Assert
        if case let .success(book) = viewModel.state {
            XCTAssertEqual(book.id, targetId)
            XCTAssertEqual(book.title, expectedBook.title)
        } else {
            XCTFail("Expected .success, but got \(viewModel.state)")
        }
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
            XCTFail("Expected .error state")
        }
    }
}
