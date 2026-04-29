//
//  MockReviewRepository.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//
import Foundation
@testable import CoolLib2

final class MockReviewRepository: ReviewRepository {
    

    var stubReviews: [Review] = []
    var stubCreatedReview: Review?
    

    var shouldThrowError = false
    
  
    var getReviewsCallCount = 0
    var createReviewCallCount = 0
    var lastCapturedBookId: Int?
    var lastCapturedReview: Review?

    // MARK: - ReviewRepository


    func getReviewsByBook(bookId: Int) async throws -> [Review] {
        getReviewsCallCount += 1
        lastCapturedBookId = bookId
        
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fetch reviews failed"])
        }
        
        return stubReviews
    }

    func createReview(review: Review) async throws -> Review? {
        createReviewCallCount += 1
        lastCapturedReview = review
        
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Create review failed"])
        }
        
        return stubCreatedReview ?? review
    }
}
