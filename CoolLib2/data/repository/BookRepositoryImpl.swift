//
//  BookRepository.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

import Foundation

final class BookRepositoryImpl: BookRepository {

    private let bookApi: BookAPI

    init(bookApi: BookAPI) {
        self.bookApi = bookApi
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
        let dto = try await bookApi.getBookById(id: id)
        return dto.toDomain()
    }
    
    func getCategory() async throws -> [Category] {
        let dtos = try await bookApi.getCategory()
        return dtos.map { $0.toDomain() }
    }
}
