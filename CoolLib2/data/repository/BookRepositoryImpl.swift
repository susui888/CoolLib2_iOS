//
//  BookRepository.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

import Foundation
import SwiftData

final class BookRepositoryImpl: BookRepository {

    private let bookApi: BookAPI
    private let modelContext: ModelContext

    init(bookApi: BookAPI, modelContext: ModelContext) {
        self.bookApi = bookApi
        self.modelContext = modelContext
    }

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

    func getBookById(id: Int) async throws -> Book {
        let descriptor = FetchDescriptor<BookEntity>(
            predicate: #Predicate { $0.id == id }
        )

        if let bookEntity = try modelContext.fetch(descriptor).first {
            let isCacheFresh = Date().timeIntervalSince(bookEntity.createdAt) < APIConfig.cacheTimeInterval
            
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

    func getCategory() async throws -> [Category] {
        let dtos = try await bookApi.getCategory()
        return dtos.map { $0.toDomain() }
    }

    func getNewestBooks() async throws -> [Book] {
        let dtos = try await bookApi.getNewestBooks()
        return dtos.map { $0.toDomain() }
    }
    
    func getRecentBooks(limit: Int) async throws -> [Book] {
        var descriptor = FetchDescriptor<BookEntity> (
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        descriptor.fetchLimit = limit
        
        let bookEntities = try modelContext.fetch(descriptor)
        
        return bookEntities.map { $0.toDomain() }
    }
}
