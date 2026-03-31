//
//  WishlistMapper.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/20.
//


extension Wishlist {
    func toBook() -> Book {
        Book(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            year: year,
            available: true,
            description: "",
            coverUrl: coverUrl
        )
    }
}

extension WishlistEntity {
    func toDomain() -> Wishlist {
        Wishlist(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            year: year,
        )
    }
}
