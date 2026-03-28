//
//  CartViewModelTests.swift
//  CoolLib2Tests
//
//  Created by susui on 2026/3/27.
//

import XCTest
@testable import CoolLib2

@MainActor
final class CartViewModelTests: XCTestCase {
    
    private var viewModel: CartViewModel!
    private var mockRepo: MockCartRepository!
    
    override func setUp() {
        super.setUp()
        // 1. 初始化 Mock Repository
        mockRepo = MockCartRepository()
        
        // 2. 注入到真实的 struct CartUseCases
        // 即使 UseCase 是 struct，只要它接受协议作为依赖，我们就能进行注入测试
        let realUseCase = CartUseCases(repository: mockRepo)
        
        // 3. 实例化 ViewModel
        viewModel = CartViewModel(usecase: realUseCase)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - 基础加载测试

    func test_load_success_updatesStateToSuccess() async throws {
        // Arrange: 使用预设的 MockCart.list 数据
        let expectedCount = MockCart.list.count
        
        // Act
        viewModel.load()
        
        // 断言同步状态变化
        if case .loading = viewModel.state {} else { XCTFail("State should be .loading") }
        
        // 等待异步 Task 内部的 do-catch 执行完毕
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        // Assert
        XCTAssertEqual(viewModel.state.count, expectedCount)
        if case .success(let items) = viewModel.state {
            XCTAssertEqual(items.count, expectedCount)
        } else {
            XCTFail("Expected .success, but got \(viewModel.state)")
        }
    }

    func test_load_failure_updatesStateToError() async throws {
        // Arrange
        mockRepo.shouldThrowError = true
        
        // Act
        viewModel.load()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        if case .error(let message) = viewModel.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected .error state")
        }
    }

    // MARK: - 交互逻辑测试 (Toggle/Remove)

    func test_toggleCart_removesItemIfAlreadyPresent() async throws {
        // Arrange: 准备一个已在购物车中的书籍
        let bookToToggle = MockBooks.list[0]
        let initialItem = Cart(
            id: bookToToggle.id,
            isbn: bookToToggle.isbn,
            title: bookToToggle.title,
            author: bookToToggle.author
        )
        mockRepo.stubCartItems = [initialItem] // 初始状态有 1 本书
        
        // Act: 再次 Toggle 同一本书（触发删除逻辑）
        viewModel.toggleCart(book: bookToToggle)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertNotNil(mockRepo.toggleCalledWithBook)
        XCTAssertEqual(viewModel.state.count, 0, "Cart should be empty after toggling existing book")
    }

    func test_removeCart_callsRepoAndRefreshesState() async throws {
        // Arrange
        let targetBook = MockBooks.list[1]
        mockRepo.stubCartItems = [] // 模拟删除后返回空列表
        
        // Act
        viewModel.removeCart(bookId: targetBook.id)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertEqual(mockRepo.removeCalledWithId, targetBook.id)
        XCTAssertEqual(viewModel.state.count, 0)
    }

    // MARK: - 状态查询测试

    func test_isBookInCart_returnsTrueForExistingItem() async {
        // Arrange
        let targetId = 262 // Sapiens ID
        let item = Cart(id: targetId, isbn: "9780099590088", title: "Sapiens", author: "Harari")
        mockRepo.stubCartItems = [item]
        
        // Act
        let isInCart = await viewModel.isBookInCart(bookId: targetId)
        let isNotInCart = await viewModel.isBookInCart(bookId: 99999)
        
        // Assert
        XCTAssertTrue(isInCart)
        XCTAssertFalse(isNotInCart)
    }

    // MARK: - 清空测试

    func test_clearLocalCart_success_resetsState() async throws {
        // Arrange
        mockRepo.stubCartItems = MockCart.list
        
        // Act
        viewModel.clearLocalCart()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        XCTAssertTrue(mockRepo.clearCalled)
        XCTAssertEqual(viewModel.state.count, 0)
        if case .success(let items) = viewModel.state {
            XCTAssertTrue(items.isEmpty)
        }
    }
}
