//
//  Book.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//
import SwiftUI

struct Book: Identifiable, Sendable {
    internal init(
        id: Int,
        isbn: String,
        title: String,
        author: String,
        publisher: String? = nil,
        year: Int? = nil,
        available: Bool? = nil,
        description: String? = nil,
        coverUrl: String? = nil
    ) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.author = author
        self.publisher = publisher ?? "Publisher Unavailable"
        self.year = year ?? 1900
        self.available = available ?? false
        self.description = description ?? "Description Unavailable"
        self.coverUrl = coverUrl ?? "\(APIConfig.IMG_BOOK_COVER)/\(isbn).webp"
    }

    let id: Int
    let isbn: String
    let title: String
    let author: String
    let publisher: String
    let year: Int
    let available: Bool
    let description: String
    let coverUrl: String
}
