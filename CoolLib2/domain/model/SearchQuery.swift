//
//  SearchQuery.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/21.
//

import Foundation


enum SearchType: String {
    case all = "ALL"
    case category = "CATEGORY"
    case author = "AUTHOR"
    case publisher = "PUBLISHER"
    case year = "YEAR"
    case search = "SEARCH"
}

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
    

    var searchType: SearchType {
        if category != nil { return .category }
        if author != nil { return .author }
        if publisher != nil { return .publisher }
        if year != nil { return .year }
        if let term = searchTerm, !term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .search
        }
        return .all
    }
    
    func toLogText() -> String {
        switch searchType {
        case .category:
            return category != nil ? "\(category!)" : ""
        case .author:
            return author ?? ""
        case .publisher:
            return publisher ?? ""
        case .year:
            return year != nil ? "\(year!)" : ""
        case .search:
            return searchTerm ?? ""
        case .all:
            return "ALL_BOOKS"
        }
    }
}
