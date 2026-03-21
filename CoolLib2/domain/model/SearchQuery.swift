//
//  SearchQuery.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

struct SearchQuery {
    let category: Int?
    let author: String?
    let publisher: String?
    let year: Int?
    let searchTerm: String?

    init(
        category: Int? = nil,
        author: String? = nil,
        publisher: String? = nil,
        year: Int? = nil,
        searchTerm: String? = nil
    ) {
        self.category = category
        self.author = author
        self.publisher = publisher
        self.year = year
        self.searchTerm = searchTerm
    }
}
