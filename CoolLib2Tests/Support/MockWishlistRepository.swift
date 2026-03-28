//
//  MockWishlistRepository.swift
//  CoolLib2Tests
//
//  Created by susui on 2026/3/28.
//

import Foundation
@testable import CoolLib2

// MARK: - MockWishlistRepository

final class MockWishlistRepository: WishlistRepository {
    
    // --- 模拟存储 ---
    // 初始值可以设为空，或者使用你定义的 MockWishlist.list
    var stubWishlistItems: [Wishlist] = MockWishlist.list
    
    // --- 控制开关 ---
    var shouldThrowError = false
    
    // --- 验证变量 (用于验证 ViewModel 是否正确调用了接口) ---
    var toggleCalledWithBook: Book?
    var addCalledWithBook: Book?
    var removeCalledWithId: Int?
    var clearCalled = false

    // MARK: - WishlistRepository Protocol 实现

    func allWishlistItems() async throws -> [Wishlist] {
        if shouldThrowError { throw createError() }
        return stubWishlistItems
    }

    func isBookInWishlist(bookId: Int) async throws -> Bool {
        // 如果需要模拟错误，也可以在这里 throw
        return stubWishlistItems.contains { $0.id == bookId }
    }

    func toggleWishlist(book: Book) async throws {
        toggleCalledWithBook = book
        if shouldThrowError { throw createError() }
        
        // 模拟 Toggle 逻辑：存在则删，不存在则加
        if let index = stubWishlistItems.firstIndex(where: { $0.id == book.id }) {
            stubWishlistItems.remove(at: index)
        } else {
            try await addToWishlist(book: book)
        }
    }

    func addToWishlist(book: Book) async throws {
        addCalledWithBook = book
        if shouldThrowError { throw createError() }
        
        // 简单模拟去重添加
        if !stubWishlistItems.contains(where: { $0.id == book.id }) {
            let newItem = Wishlist(
                id: book.id,
                isbn: book.isbn,
                title: book.title,
                author: book.author,
                publisher: book.publisher
            )
            stubWishlistItems.append(newItem)
        }
    }

    func removeFromWishlist(bookId: Int) async throws {
        removeCalledWithId = bookId
        if shouldThrowError { throw createError() }
        
        stubWishlistItems.removeAll { $0.id == bookId }
    }

    func clearWishlist() async throws {
        clearCalled = true
        if shouldThrowError { throw createError() }
        
        stubWishlistItems = []
    }

    // MARK: - Helper
    private func createError() -> NSError {
        return NSError(
            domain: "WishlistError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Wishlist operation failed"]
        )
    }
}
