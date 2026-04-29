//
//  ReviewUseCases.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation


struct ReviewUseCases {
    private let repository: ReviewRepository
    
    init(repository: ReviewRepository) {
        self.repository = repository
    }
    
    func getReviewsByBook(bookId: Int) async throws -> [Review] {
        try await repository.getReviewsByBook(bookId: bookId)
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func createReview(review: Review) async throws -> Review? {
        try await repository.createReview(review: review)
    }
}
