//
//  Review.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation

struct Review: Identifiable, Sendable {
    internal init(
        id: Int? = nil,
        bookId: Int,
        userId: Int,
        userName: String,
        rating: Int,
        content: String,
        imageUrls: [String] = [],
        createdAt: Date? = nil
    ) {
        
        self.id = id ?? 0
        self.bookId = bookId
        self.userId = userId
        self.userName = userName
        self.rating = rating
        self.content = content
        self.imageUrls = imageUrls
        self.createdAt = createdAt ?? Date()
    }

    let id: Int
    let bookId: Int
    let userId: Int
    let userName: String
    let rating: Int
    let content: String
    let imageUrls: [String]
    let createdAt: Date
}
