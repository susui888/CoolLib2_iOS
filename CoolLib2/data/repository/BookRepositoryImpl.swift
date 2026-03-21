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
}
