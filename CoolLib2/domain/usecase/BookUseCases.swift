//
//  BookUseCases.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/21.
//

struct BookUseCases {
    private let repository: BookRepository
    
    init(repository: BookRepository) {
        self.repository = repository
    }
    
    func searchBooks(query: SearchQuery) async throws -> [Book] {
        try await repository.searchBooks(query: query).shuffled()
    }
    
    func getBookById(id: Int) async throws -> Book {
        try await repository.getBookById(id: id)
    }
    
    func getCategory() async throws -> [Category] {
        try await repository.getCategory()
    }
    
    func getNewestBooks() async throws -> [Book]{
        try await repository.getNewestBooks().shuffled()
    }
    
    func getRecentBooks(limit: Int = 12) async throws -> [Book] {
        try await repository.getRecentBooks(limit: limit)
    }
    
    func getBookByISBN(isbn: String) async throws -> Book {
        try await repository.getBookByISBN(isbn: isbn)
    }
}
