//
//  BookAPI.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/21.
//

protocol BookAPI {
    
    func searchBooks(
        category: Int?,
        author: String?,
        publisher: String?,
        year: Int?,
        searchTerm: String?
    ) async throws -> [BookDTO]
    
    func getBookById(id: Int) async throws -> BookDTO
    
    func getCategory() async throws -> [CategoryDTO]
    
    func getNewestBooks() async throws -> [BookDTO]
}
