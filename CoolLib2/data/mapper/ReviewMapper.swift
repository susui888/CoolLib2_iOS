//
//  ReviewMapper.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation

// MARK: - DTO Mappers
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

// MARK: - Entity Mappers
extension ReviewEntity {
    func toDomain() -> Review {
        // 将逗号分隔的字符串还原为 [String] 数组，如果是空字符串则返回空数组
        let urls = self.imageUrls.isEmpty ? [] : self.imageUrls.components(separatedBy: ",")
        
        return Review(
            id: self.id,
            bookId: self.bookId,
            userId: self.userId,
            userName: self.userName,
            rating: Int(self.rating),
            content: self.content ?? "",
            imageUrls: urls,
            createdAt: self.createdAt
        )
    }
}

extension Review {
    func toEntity() -> ReviewEntity {
        // 将 [String] 数组转换为逗号分隔的字符串进行存储
        let urlsString = self.imageUrls.joined(separator: ",")
        
        return ReviewEntity(
            id: self.id,
            bookId: self.bookId,
            userId: self.userId,
            userName: self.userName,
            rating: Int16(self.rating),
            content: self.content.isEmpty ? nil : self.content,
            createdAt: self.createdAt,
            imageUrls: urlsString
        )
    }
}
