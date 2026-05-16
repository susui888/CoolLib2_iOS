//
//  MockReviewRepository.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation
import UIKit
@testable import CoolLib2

final class MockReviewRepository: ReviewRepository {
    
    // MARK: - Stubbed Properties (模拟数据桩)
    var stubReviews: [Review] = []
    var stubCreatedReview: Review?
    var stubUploadedUrls: [String] = ["https://r2.ryansu.uk/mock-image.webp"] // 模拟 R2 返回的图片链接
    var stubDeleteResult: Bool = true // 模拟删除是否成功的布尔值
    
    // MARK: - Error Simulation Control (错误模拟控制)
    var shouldThrowError = false
    
    // MARK: - Call Counters (调用计数器)
    var getReviewsCallCount = 0
    var createReviewCallCount = 0
    var uploadImagesCallCount = 0
    var getAllLocalReviewsCallCount = 0
    var deleteReviewCallCount = 0
    
    // MARK: - Captured Arguments (入参捕获器)
    var lastCapturedBookId: Int?
    var lastCapturedReview: Review?
    var lastCapturedImages: [UIImage]?
    var lastCapturedDeleteReview: Review?

    // MARK: - ReviewRepository Implementation

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
    
    func uploadReviewImages(images: [UIImage]) async throws -> [String] {
        uploadImagesCallCount += 1
        lastCapturedImages = images
        
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload images failed"])
        }
        
        return stubUploadedUrls
    }

    func getAllLocalReviews() async throws -> [Review] {
        getAllLocalReviewsCallCount += 1
        
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fetch local reviews failed"])
        }
        
        return stubReviews
    }
    
    func deleteReview(review: Review) async throws -> Bool {
        deleteReviewCallCount += 1
        lastCapturedDeleteReview = review
        
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Delete remote review failed"])
        }
        
        // 如果删除成功，模拟从内部存根中移除
        if stubDeleteResult {
            stubReviews.removeAll { $0.id == review.id }
        }
        
        return stubDeleteResult
    }
}
