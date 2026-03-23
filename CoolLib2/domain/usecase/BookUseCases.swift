//
//  BookUseCases.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

struct BookUseCases {
    private let repo: BookRepository
    
    init(repo: BookRepository) {
        self.repo = repo
    }
    
    func searchBooks(query: SearchQuery) async throws -> [Book] {
        try await repo.searchBooks(query: query).shuffled()
    }
    
    func getBookById(id: Int) async throws -> Book {
        try await repo.getBookById(id: id)
    }
    
    func getCategory() async throws -> [Category] {
        try await repo.getCategory().sorted { $0.name < $1.name}
    }
    
    func getNewestBooks() async throws -> [Book]{
        try await repo.getNewestBooks().shuffled()
    }
    
    func getRecentBooks(limit: Int = 12) async throws -> [Book] {
        try await repo.getRecentBooks(limit: limit)
    }
}
