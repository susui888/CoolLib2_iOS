//
//  BookMapper.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/21.
//

extension BookDTO {
    func toDomain() -> Book {
        Book(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            year: year,
            available: available,
            description: description
        )
    }
}

extension BookDTO {
    func toEntity() -> BookEntity {
        BookEntity(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            year: year,
            available: available,
            desc: description
        )
    }
}

extension BookEntity {
    func toDomain() -> Book {
        Book(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            year: year,
            available: available,
            description: desc
        )
    }
}

extension Book {
    func toCartEntity() -> CartEntity {
        CartEntity(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            year: year,
        )
    }
}

extension Book {
    func toWishlistEntity() -> WishlistEntity {
        WishlistEntity(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            year: year,
        )
    }
}

