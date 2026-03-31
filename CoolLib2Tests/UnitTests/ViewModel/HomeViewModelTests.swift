//
//  HomeViewModelTests.swift
//  CoolLib2Tests
//
//  Created by Ryan Su on 2026/3/27.
//

import XCTest
import SwiftData
@testable import CoolLib2

@MainActor
final class HomeViewModelTests: XCTestCase {

    private var viewModel: HomeViewModel!
    private var mockBookRepo: MockBookRepository!
    private var mockWishlistRepo: MockWishlistRepository!

    override func setUp() {
        super.setUp()
        
        // 1. 初始化底层的 Mock Repository
        mockBookRepo = MockBookRepository()
        mockWishlistRepo = MockWishlistRepository()
        
        // 2. 注入到真实的 struct UseCases 中
        let bookUseCase = BookUseCases(repository: mockBookRepo)
        let wishlistUseCase = WishlistUseCases(repository: mockWishlistRepo)
        
        // 3. 实例化 ViewModel
        viewModel = HomeViewModel(
            bookUseCase: bookUseCase,
            wishlistUseCase: wishlistUseCase
        )
    }

    override func tearDown() {
        viewModel = nil
        mockBookRepo = nil
        mockWishlistRepo = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_loadAllContent_success_updatesState() async throws {
        // Arrange: 设置 Repo 的模拟返回值
        let expectedCategory = CoolLib2.Category(id: 1, name: "Technology",description: "Technology")
        mockBookRepo.stubCategories = [expectedCategory]
        mockBookRepo.stubNewestBooks = MockBooks.list
        mockBookRepo.stubRecentBooks = MockBooks.list
        
        let favBook = MockBooks.list[0]
        let mockWishlistItem = Wishlist(
                    id: favBook.id,
                    isbn: favBook.isbn,
                    title: favBook.title,
                    author: favBook.author,
                    publisher: favBook.publisher, // 可选，不传则使用默认值
                    year: favBook.year,           // 可选，不传则使用默认值
                    coverUrl: nil                 // 可选，不传则自动生成 URL
                )
        
        mockWishlistRepo.stubWishlistItems = [mockWishlistItem]
        
        // Act
        viewModel.loadAllContent()
        
        // 给 Task { ... } 内部异步任务一点执行时间
        try await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        if case let .success(categories, recent, favorites, newest) = viewModel.state {
            XCTAssertFalse(categories.isEmpty)
            XCTAssertFalse(recent.isEmpty)
            XCTAssertEqual(categories.first?.name, "Technology")
            XCTAssertEqual(favorites.first?.id, favBook.id)
            XCTAssertFalse(newest.isEmpty)
        } else {
            XCTFail("Expected .success state, but got \(viewModel.state)")
        }
    }

    func test_loadAllContent_failure_updatesErrorState() async throws {
        // Arrange
        mockBookRepo.shouldThrowError = true
        
        // Act
        viewModel.loadAllContent()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        if case .error(let message) = viewModel.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected .error state")
        }
    }
}



