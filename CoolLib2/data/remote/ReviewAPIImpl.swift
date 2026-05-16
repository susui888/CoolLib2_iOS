//
//  ReviewAPIImpl.swift
//  Containerized Library Ecosystem
//
//  Created by Ryan Su on 2026/4/29.
//

import Alamofire
import Foundation

final class ReviewAPIImpl: ReviewAPI {

    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    /// Fetches a list of reviews for a specific book by its ID
    func getReviewsByBook(bookId: Int) async throws -> [ReviewDTO] {
        let urlString = "\(APIConfig.serverURL)/api/reviews/\(bookId)"

        // Performs a standard GET request using the generic APIClient
        return try await client.request(urlString)
    }

    /// Submits a new book review to the backend
    func createReview(review: ReviewDTO) async throws -> ReviewDTO {
        let urlString = "\(APIConfig.serverURL)/api/reviews"

        // Sends review data as a JSON body via POST
        return try await client.request(
            urlString,
            method: .post,
            body: review
        )
    }

    func deleteReview(bookId: Int) async throws {
        let urlString = "\(APIConfig.serverURL)/api/reviews/\(bookId)"

        let _: Empty = try await client.request(
            urlString,
            method: .delete
        )
    }

    /// Requests pre-signed URLs from the backend for image uploads
    /// This allows the client to upload files directly to Cloudflare R2/S3 without taxing the main server
    func getReviewImageUploadUrls(fileNames: [String]) async throws
        -> [UploadUrlResponse]
    {
        let urlString = "\(APIConfig.serverURL)/api/reviews/upload-urls"

        // Passes the requested filenames as query parameters
        let parameters: [String: [String]] = ["fileNames": fileNames]

        return try await client.request(
            urlString,
            method: .get,
            parameters: parameters
        )
    }

    /// Performs the actual binary data upload to the storage provider (R2/S3)
    /// Uses the pre-signed URL obtained from getReviewImageUploadUrls
    func uploadImageToS3(url: String, data: Data) async throws {
        try await client.put(
            url,
            data: data,
            // Explicitly set content-type for consistent image handling in the bucket
            headers: ["Content-Type": "image/webp"]
        )
    }
}

/// Data model representing the pre-signed URL and its associated key in the storage bucket
struct UploadUrlResponse: Codable {
    /// The pre-signed R2/S3 URL used for the PUT request
    let uploadUrl: String
    /// The unique identifier (Key) used to reference the file in the bucket
    let objectKey: String
}
