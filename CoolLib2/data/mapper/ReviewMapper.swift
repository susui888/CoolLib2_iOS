//
//  ReviewMapper.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation


extension ReviewDTO {
    func toDomain() -> Review {
        return Review(
            id: self.id,
            bookId: self.bookId,
            userId: self.userId,
            userName: self.userName,
            rating: Int(self.rating),
            content: self.content ?? "",
            imageUrls: imageUrls ?? [],
            createdAt: self.createdAt
        )
    }
}



extension Review {
    func toDTO() -> ReviewDTO {
        return ReviewDTO(
            id: self.id,
            bookId: self.bookId,
            userId: self.userId,
            userName: self.userName,
            rating: Int16(self.rating),
            content: self.content.isEmpty ? nil : self.content,
            imageUrls: imageUrls,
            createdAt: self.createdAt
        )
    }
}
