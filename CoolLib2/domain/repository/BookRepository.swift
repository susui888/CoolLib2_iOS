//
//  BookRepository.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

protocol BookRepository {
    func searchBooks(query: SearchQuery) async throws -> [Book]
    
    func getBookById(id: Int) async throws -> Book
    
    func getCategory() async throws -> [Category]
    
    func getNewestBooks() async throws -> [Book]
    
    func getRecentBooks(limit: Int) async throws -> [Book]
}
