//
//  Screen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//

enum Screen: Hashable {

    case bookDetails(
        bookId: Int
    )

    case books(
        category: Int? = nil,
        author: String? = nil,
        publisher: String? = nil,
        year: Int? = nil,
        searchTerm: String? = nil,
    )

    case myLoans
    case reservations
    case history
    case profile
}
