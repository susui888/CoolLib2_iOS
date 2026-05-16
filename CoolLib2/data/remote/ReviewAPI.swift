//
//  ReviewAPI.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation

protocol ReviewAPI {
    
    func getReviewsByBook(bookId: Int) async throws -> [ReviewDTO]
    
    func createReview(review: ReviewDTO) async throws -> ReviewDTO
    
    func getReviewImageUploadUrls(fileNames: [String]) async throws -> [UploadUrlResponse]
        
    func uploadImageToS3(url: String, data: Data) async throws
    
    func deleteReview(bookId: Int) async throws
}
