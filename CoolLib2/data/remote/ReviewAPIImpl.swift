//
//  ReviewAPIImpl.swift
//  CoolLib2
//
//  Created by Rayn Su on 2026/4/29.
//

import Foundation
import Alamofire

final class ReviewAPIImpl: ReviewAPI {
    
    private let client: APIClient
    
    init(client: APIClient) {
        self.client = client
    }
    
    func getReviewsByBook(bookId: Int) async throws -> [ReviewDTO] {
        
        let urlString = "\(APIConfig.serverURL)/api/reviews/\(bookId)"
        
        return try await client.request(urlString)
    }
    
    func createReview(review: ReviewDTO) async throws -> ReviewDTO {
        
        let urlString = "\(APIConfig.serverURL)/api/reviews"
        
        return try await client.request(
            urlString,
            method: .post,
            body: review
        )
    }
}
