//
//  BookRepositoryTests.swift
//  CoolLib2Tests
//
//  Created by Ryan Su on 2026/3/27.
//

import XCTest
import SwiftData
@testable import CoolLib2

@MainActor
final class BookRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    private var repository: BookRepositoryImpl!
    private var mockApi: MockBookAPI!
    private var modelContainer: ModelContainer!
    private var context: ModelContext!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        
        // 1. Initialize In-Memory SwiftData Stack
        let schema = Schema([BookEntity.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
            context = modelContainer.mainContext
        } catch {
            XCTFail("Failed to initialize ModelContainer: \(error)")
        }
        
        // 2. Initialize Dependencies
        mockApi = MockBookAPI()
        repository = BookRepositoryImpl(bookApi: mockApi, modelContext: context)
    }

    override func tearDown() {
        repository = nil
        mockApi = nil
        context = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Helper Methods
    /// Explicitly pass all parameters to avoid using 'Date()' default values in BookEntity init
    private func makeEntity(id: Int, title: String, updatedAt: Date) -> BookEntity {
        let entity = BookEntity(
            id: id,
            isbn: "978-fake-\(id)", // Ensure ISBN is unique for SwiftData
            title: title,
            author: "Test Author",
            publisher: "Test Publisher",
            year: 2024,
            available: true,
            desc: "Test Description",
            createdAt: updatedAt, // Explicitly set
            updatedAt: updatedAt   // Explicitly set
        )
        return entity
    }

    // MARK: - Search Tests
    func test_searchBooks_shouldReturnMappedDomainModels() async throws {
        // Arrange
        mockApi.stubSearchBooks = MockBooks.dtoList
        let query = SearchQuery(searchTerm: "Sapiens")

        // Act
        let results = try await repository.searchBooks(query: query)

        // Assert
        XCTAssertEqual(results.count, MockBooks.dtoList.count)
        XCTAssertEqual(results.first?.title, "Sapiens: A Brief History of Humankind")
    }

    // MARK: - Cache Logic Tests
    func test_getBookById_whenCacheIsFresh_shouldReturnCachedData() async throws {
        // Arrange
        let bookId = 270
        let entity = makeEntity(id: bookId, title: "Cached Title", updatedAt: Date())
        context.insert(entity)
        try context.save()
        
        // If API is called, this will throw and fail the test
        mockApi.shouldThrowError = true

        // Act
        let result = try await repository.getBookById(id: bookId)

        // Assert
        XCTAssertEqual(result.title, "Cached Title")
    }

    func test_getBookById_whenCacheIsExpired_shouldFetchFromAPIAndRefresh() async throws {
        // Arrange: 10 days ago (Exceeds APIConfig.cacheTimeInterval)
        let bookId = 262
        let oldDate = Date().addingTimeInterval(-86400 * 10)
        
        let expiredEntity = makeEntity(id: bookId, title: "Old Title", updatedAt: oldDate)
        context.insert(expiredEntity)
        try context.save()
        
        let apiDTO = BookDTO(
            id: bookId,
            isbn: "9780099590088",
            title: "Fresh API Title",
            author: "Yuval Noah Harari",
            publisher: "Vintage",
            year: 2011,
            available: true,
            description: "New Description",
        )
        mockApi.stubBookById = apiDTO

        // Act
        let result = try await repository.getBookById(id: bookId)

        // Assert
        XCTAssertEqual(result.title, "Fresh API Title")
        
        // Verify SwiftData update
        let descriptor = FetchDescriptor<BookEntity>(predicate: #Predicate { $0.id == bookId })
        let saved = try context.fetch(descriptor).first
        XCTAssertEqual(saved?.title, "Fresh API Title")
    }

    // MARK: - Sorting & Limit Tests
    func test_getRecentBooks_shouldRespectLimitAndOrdering() async throws {
        // Arrange: Create distinct time gaps
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)
        let twoHoursAgo = now.addingTimeInterval(-7200)

        let book1 = makeEntity(id: 1, title: "Oldest", updatedAt: twoHoursAgo)
        let book2 = makeEntity(id: 2, title: "Middle", updatedAt: oneHourAgo)
        let book3 = makeEntity(id: 3, title: "Newest", updatedAt: now)
        
        // Insert in random order
        context.insert(book1)
        context.insert(book3)
        context.insert(book2)
        try context.save()

        // Act: Fetch top 2 most recent
        let results = try await repository.getRecentBooks(limit: 2)

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].id, 3, "Index 0 should be ID 3 (Newest)")
        XCTAssertEqual(results[1].id, 2, "Index 1 should be ID 2 (Middle)")
    }
}
