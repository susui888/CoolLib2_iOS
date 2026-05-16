//
//  ReviewEntity.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/5/15.
//

import Foundation
import SwiftData

@Model
final class ReviewEntity {
    @Attribute(.unique)
    var id: Int
    
    var bookId: Int
    var userId: Int
    var userName: String
    var rating: Int16 // to Kotlin Short
    var content: String?
    var createdAt: Date
    var imageUrls: String
    
    internal init(
        id: Int,
        bookId: Int,
        userId: Int,
        userName: String,
        rating: Int16,
        content: String? = nil,
        createdAt: Date = Date(),
        imageUrls: String = ""
    ) {
        self.id = id
        self.bookId = bookId
        self.userId = userId
        self.userName = userName
        self.rating = rating
        self.content = content
        self.createdAt = createdAt
        self.imageUrls = imageUrls
    }
}
