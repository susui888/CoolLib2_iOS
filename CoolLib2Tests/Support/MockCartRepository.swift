//
//  MockCartRepository.swift
//  CoolLib2Tests
//

import Foundation
@testable import CoolLib2

final class MockCartRepository: CartRepository {
    
    // --- 模拟存储 ---
    // 默认使用你提供的 MockCart.list 数据
    var stubCartItems: [Cart] = MockCart.list
    
    // --- 控制开关 ---
    var shouldThrowError = false
    
    // --- 验证变量 (用于验证接口是否被调用) ---
    var toggleCalledWithBook: Book?
    var addCalledWithBook: Book?
    var removeCalledWithId: Int?
    var clearCalled = false

    // MARK: - CartRepository Protocol 实现

    func allCartItems() async throws -> [Cart] {
        if shouldThrowError { throw createError(message: "Failed to fetch cart") }
        return stubCartItems
    }

    func toggleCart(book: Book) async throws {
        toggleCalledWithBook = book
        if shouldThrowError { throw createError(message: "Toggle failed") }
        
        // 模拟逻辑：如果已存在则删除，不存在则添加
        if let index = stubCartItems.firstIndex(where: { $0.id == book.id }) {
            stubCartItems.remove(at: index)
        } else {
            let newItem = Cart(
                id: book.id,
                isbn: book.isbn,
                title: book.title,
                author: book.author,
                publisher: book.publisher,
                coverUrl: book.coverUrl
            )
            stubCartItems.append(newItem)
        }
    }

    func addToCart(book: Book) async throws {
        addCalledWithBook = book
        if shouldThrowError { throw createError(message: "Add failed") }
        
        // 避免重复添加
        if !stubCartItems.contains(where: { $0.id == book.id }) {
            let newItem = Cart(
                id: book.id,
                isbn: book.isbn,
                title: book.title,
                author: book.author,
                publisher: book.publisher,
                coverUrl: book.coverUrl
            )
            stubCartItems.append(newItem)
        }
    }

    func removeFromCart(bookId: Int) async throws {
        removeCalledWithId = bookId
        if shouldThrowError { throw createError(message: "Remove failed") }
        
        stubCartItems.removeAll { $0.id == bookId }
    }

    func isBookInCart(bookId: Int) async throws -> Bool {
        if shouldThrowError { return false }
        return stubCartItems.contains { $0.id == bookId }
    }

    func clearLocalCart() async throws {
        clearCalled = true
        if shouldThrowError { throw createError(message: "Clear failed") }
        stubCartItems = []
    }

    // MARK: - Helper
    private func createError(message: String) -> NSError {
        return NSError(
            domain: "CartMockError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}
