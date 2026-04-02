//
//  CartMapper.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/20.
//

extension Cart {
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

extension CartEntity {
    func toDomain() -> Cart {
        Cart(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            year: year,
        )
    }
}

extension Cart {
    func toDTO() -> CartDTO {
        return CartDTO(
            bookId: self.id,
            quantity: 1
        )
    }
}
