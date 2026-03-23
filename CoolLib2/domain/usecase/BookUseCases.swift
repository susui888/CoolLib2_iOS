//
//  BookUseCases.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
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
        try await repository.getCategory().sorted { $0.name < $1.name}
    }
    
    func getNewestBooks() async throws -> [Book]{
        try await repository.getNewestBooks().shuffled()
    }
    
    func getRecentBooks(limit: Int = 12) async throws -> [Book] {
        try await repository.getRecentBooks(limit: limit)
    }
}
