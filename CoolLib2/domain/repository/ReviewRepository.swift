//
//  ReviewRepository.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation
import UIKit

protocol ReviewRepository {
    
    func getReviewsByBook(bookId: Int) async throws -> [Review]
    
    func createReview(review: Review) async throws -> Review?
    
    func uploadReviewImages(images: [UIImage]) async throws -> [String]

    func getAllLocalReviews() async throws -> [Review]
    
    func deleteReview(review: Review) async throws -> Bool
}
