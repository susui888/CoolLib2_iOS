//
//  ReviewRepositoryImpl.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation

final class ReviewRepositoryImpl: ReviewRepository {
    
    private let reviewApi: ReviewAPI
    private let tag = "ReviewRepository"


    init(reviewApi: ReviewAPI) {
        self.reviewApi = reviewApi
    }

    func getReviewsByBook(bookId: Int) async throws -> [Review] {
        do {
            let dtos = try await reviewApi.getReviewsByBook(bookId: bookId)
            
            return dtos.map { $0.toDomain() }
            
        } catch {
            
            print("[\(tag)] Error fetching reviews for bookId \(bookId): \(error.localizedDescription)")

            return []
        }
    }

    func createReview(review: Review) async throws -> Review? {
        do {
    
            let dto = review.toDTO()
            
            let responseDto = try await reviewApi.createReview(review: dto) 

            return responseDto.toDomain()
            
        } catch {
            print("[\(tag)] Error creating review: \(error.localizedDescription)")
            return nil
        }
    }
}
