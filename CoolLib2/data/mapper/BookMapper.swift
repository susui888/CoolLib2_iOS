//
//  BookMapper.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
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
