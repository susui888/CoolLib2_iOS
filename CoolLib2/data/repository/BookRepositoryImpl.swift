import Foundation
import SwiftData

@MainActor
final class BookRepositoryImpl: BookRepository {

    // MARK: - Properties
    private let bookApi: BookAPI
    private let modelContext: ModelContext

    // MARK: - Initialization
    init(bookApi: BookAPI, modelContext: ModelContext) {
        self.bookApi = bookApi
        self.modelContext = modelContext
    }

    // MARK: - Search Operations
    func searchBooks(query: SearchQuery) async throws -> [Book] {
        let dtos = try await bookApi.searchBooks(
            category: query.category,
            author: query.author,
            publisher: query.publisher,
            year: query.year,
            searchTerm: query.searchTerm
        )

        return dtos.map { $0.toDomain() }
    }

    func getBookByISBN(isbn: String) async throws -> Book {
        try await bookApi.getBookByISBN(isbn: isbn).toDomain()
    }

    // MARK: - Book Detail Operations
    func getBookById(id: Int) async throws -> Book {
        let descriptor = FetchDescriptor<BookEntity>(
            predicate: #Predicate { $0.id == id }
        )

        if let bookEntity = try modelContext.fetch(descriptor).first {
            let isCacheFresh =
                Date().timeIntervalSince(bookEntity.createdAt)
                < APIConfig.cacheTimeInterval

            if isCacheFresh {
                bookEntity.updatedAt = Date()
                try modelContext.save()

                return bookEntity.toDomain()
            }
        }

        let dto = try await bookApi.getBookById(id: id)

        modelContext.insert(dto.toEntity())
        try modelContext.save()

        return dto.toDomain()
    }

    // MARK: - Category Operations & Recent Books
    func getCategory() async throws -> [Category] {
        let descriptor = FetchDescriptor<CategoryEntity>(
            sortBy: [SortDescriptor(\.id, order: .forward)]
        )

        let localCategories = try modelContext.fetch(descriptor)

        if let firstCategory = localCategories.first {
            let isCacheFresh =
                Date().timeIntervalSince(firstCategory.createdAt)
                < APIConfig.cacheTimeInterval

            if isCacheFresh {
                return localCategories.map { $0.toDomain() }
            }

            for category in localCategories {
                modelContext.delete(category)
            }
        }

        let dtos = try await bookApi.getCategory()

        for dto in dtos {
            modelContext.insert(dto.toEntity())
        }

        try modelContext.save()

        return dtos.map { $0.toDomain() }
    }

    func getRecentBooks(limit: Int) async throws -> [Book] {
        var descriptor = FetchDescriptor<BookEntity>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        descriptor.fetchLimit = limit

        let bookEntities = try modelContext.fetch(descriptor)

        return bookEntities.map { $0.toDomain() }
    }

    // MARK: - Newest Books (Cache Logic)
    func getNewestBooks() async throws -> [Book] {
        // 1. Check local database for cached books
        let cachedEntities = try getCachedNewestBooks(context: modelContext)

        if !cachedEntities.isEmpty {
            // Return cache if available
            return cachedEntities.map { $0.toDomain() }
        }

        // 2. Fetch fresh data from API if cache is empty
        let networkBooks = try await bookApi.getNewestBooks()
        
        // 3. Convert network data to domain and database models
        let domainBooks = networkBooks.map { $0.toDomain() }
        let bookEntities = domainBooks.map { $0.toEntity() }

        // 4. Update the local database (Transaction)
        for entity in bookEntities {
            modelContext.insert(entity)
        }

        try modelContext.delete(model: NewestBookRef.self)

        for (index, book) in domainBooks.enumerated() {
            let ref = NewestBookRef(bookId: book.id, priority: index)
            
            if let correspondingEntity = bookEntities.first(where: { $0.id == book.id }) {
                ref.book = correspondingEntity
            }
            
            modelContext.insert(ref)
        }

        try modelContext.save()

        return domainBooks
    }
    
    func updateNewestCache(books: [BookEntity], refs: [NewestBookRef]) throws {
        for book in books {
            modelContext.insert(book)
        }

        try modelContext.delete(model: NewestBookRef.self)

        for ref in refs {
            modelContext.insert(ref)
        }

        try modelContext.save()
    }
    
    func getCachedNewestBooks(context: ModelContext) throws -> [BookEntity] {
        let descriptor = FetchDescriptor<NewestBookRef>(
            sortBy: [SortDescriptor(\.priority, order: .forward)]
        )
        
        let refs = try context.fetch(descriptor)
        
        return refs.compactMap { $0.book }
    }
}
