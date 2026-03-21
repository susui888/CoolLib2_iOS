//
//  BookAPIImpl.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

import Foundation

final class BookAPIImpl: BookAPI {

    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func searchBooks(
        category: Int?,
        author: String?,
        publisher: String?,
        year: Int?,
        searchTerm: String?
    ) async throws -> [BookDTO] {
        var items: [URLQueryItem] = []

        if let category { items.append(.init(name: "category", value: "\(category)")) }
        if let author { items.append(.init(name: "author", value: author)) }
        if let publisher { items.append(.init(name: "publisher", value: publisher)) }
        if let year { items.append(.init(name: "year", value: "\(year)")) }
        if let searchTerm { items.append(.init(name: "q", value: searchTerm)) }
        
        var components = URLComponents(string: "\(APIConfig.serverURL)/api/books/search")!
        
        components.queryItems = items.isEmpty ? nil : items
        
        let urlString = components.url!.absoluteString
        
        return try await client.request(urlString)
    }
}
