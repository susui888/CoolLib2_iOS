//
//  BookEntity.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/23.
//

import Foundation
import SwiftData

@Model
final class BookEntity {
    internal init(
        id: Int,
        isbn: String,
        title: String,
        author: String,
        publisher: String,
        year: Int,
        available: Bool,
        desc: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
    ) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.author = author
        self.publisher = publisher
        self.year = year
        self.available = available
        self.desc = desc
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    @Attribute(.unique)
    var id: Int

    @Attribute(.unique)
    var isbn: String

    var title: String
    var author: String
    var publisher: String
    var year: Int
    var available: Bool
    var desc: String?

    var createdAt: Date
    var updatedAt: Date

}
