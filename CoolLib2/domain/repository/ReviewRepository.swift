//
//  ReviewRepository.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation

protocol ReviewRepository {
    
    func getReviewsByBook(bookId: Int) async throws -> [Review]
    
    func createReview(review: Review) async throws -> Review?
}
