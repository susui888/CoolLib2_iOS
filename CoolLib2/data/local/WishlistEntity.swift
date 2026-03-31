//
//  WishlistEntity.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/27.
//

import Foundation
import SwiftData

@Model
final class WishlistEntity{
    @Attribute(.unique)
    var id: Int
    
    var isbn: String
    var title: String
    var author: String
    var publisher: String
    var year: Int
    
    var createdAt: Date
    var updatedAt: Date
    
    internal init(
        id: Int,
        isbn: String,
        title: String,
        author: String,
        publisher: String,
        year: Int,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
    ) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.author = author
        self.publisher = publisher
        self.year = year
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
