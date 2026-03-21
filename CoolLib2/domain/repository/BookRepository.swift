//
//  BookRepository.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

protocol BookRepository {
    func searchBooks(query: SearchQuery) async throws -> [Book]
}
