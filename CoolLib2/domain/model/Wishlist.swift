//
//  wishlist.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/20.
//

struct Wishlist: Identifiable, Sendable {
    internal init(
        id: Int,
        isbn: String,
        title: String,
        author: String,
        publisher: String? = nil,
        year: Int? = nil,
        coverUrl: String? = nil
    ) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.author = author
        self.publisher = publisher ?? "Publisher Unavailable"
        self.year = year ?? 1900
        self.coverUrl = coverUrl ?? "\(APIConfig.serverURL)/img/cover/\(isbn).webp"
    }

    let id: Int
    let isbn: String
    let title: String
    let author: String
    let publisher: String
    let year: Int
    let coverUrl: String


}
