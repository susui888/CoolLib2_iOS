//
//  Mocks.swift
//  CoolLib2Tests
//

import Foundation

@testable import CoolLib2

final class MockBookRepository: BookRepository {
    // --- 模拟数据持有者 ---
    var stubCategories: [CoolLib2.Category] = []
    var stubNewestBooks: [Book] = []
    var stubRecentBooks: [Book] = []
    var stubSearchBooks: [Book] = []

    var stubBookById: Book?

    // --- 控制开关 ---
    var shouldThrowError = false
    var lastSearchQuery: SearchQuery?  // 可选：用于验证 ViewModel 传参是否正确

    // MARK: - BookRepository Protocol 实现

    func getCategory() async throws -> [CoolLib2.Category] {
        if shouldThrowError { throw createError() }
        return stubCategories
    }

    func getNewestBooks() async throws -> [Book] {
        if shouldThrowError { throw createError() }
        return stubNewestBooks
    }

    func getRecentBooks(limit: Int) async throws -> [Book] {
        if shouldThrowError { throw createError() }
        return stubRecentBooks
    }

    func searchBooks(query: SearchQuery) async throws -> [Book] {
        lastSearchQuery = query
        if shouldThrowError { throw createError() }
        return stubSearchBooks
    }

    func getBookById(id: Int) async throws -> Book {
        if shouldThrowError {
            throw NSError(
                domain: "Network",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Book not found"]
            )
        }

        if let book = stubBookById {
            return book
        }

        // 如果没有预设数据，默认抛错
        throw NSError(domain: "Mock", code: -1)
    }

    // 辅助私有方法
    private func createError() -> NSError {
        return NSError(
            domain: "MockError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Mocked network failure"]
        )
    }
}
