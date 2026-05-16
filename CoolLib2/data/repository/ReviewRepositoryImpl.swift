//
//  ReviewRepositoryImpl.swift
//  Containerized Library Ecosystem
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation
import SwiftData
import UIKit

@MainActor
final class ReviewRepositoryImpl: ReviewRepository {

    private let reviewApi: ReviewAPI
    private let modelContext: ModelContext
    private let tag = "ReviewRepository"

    init(reviewApi: ReviewAPI, modelContext: ModelContext) {
        self.reviewApi = reviewApi
        self.modelContext = modelContext
    }

    func getAllLocalReviews() async throws -> [Review] {
        let descriptor = FetchDescriptor<ReviewEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        let entities = (try? modelContext.fetch(descriptor)) ?? []
        var reviews: [Review] = []

        for entity in entities {
            var review = entity.toDomain()

            let bookIdFilter = review.bookId
            let bookDescriptor = FetchDescriptor<BookEntity>(
                predicate: #Predicate { $0.id == bookIdFilter }
            )

            if let bookEntity = try? modelContext.fetch(bookDescriptor).first {
                review.book = bookEntity.toDomain()
            }

            reviews.append(review)
        }

        return reviews
    }

    func deleteReview(review: Review) async throws -> Bool {
        do {
            try await reviewApi.deleteReview(bookId: review.bookId)

            let reviewId = review.id
            let descriptor = FetchDescriptor<ReviewEntity>(
                predicate: #Predicate { $0.id == reviewId }
            )

            if let entity = try modelContext.fetch(descriptor).first {
                modelContext.delete(entity)
                try modelContext.save()
            }
            return true
        } catch {
            print(
                "[\(tag)] Failed to delete remote review: \(error.localizedDescription)"
            )
            return false
        }
    }

    /// Fetches all reviews for a specific book and maps them from DTOs to Domain models
    func getReviewsByBook(bookId: Int) async throws -> [Review] {
        do {
            let dtos = try await reviewApi.getReviewsByBook(bookId: bookId)
            // Transform data transfer objects into clean domain entities
            return dtos.map { $0.toDomain() }
        } catch {
            print(
                "[\(tag)] Error fetching reviews for bookId \(bookId): \(error.localizedDescription)"
            )
            return []  // Return an empty list on failure to prevent UI crashes
        }
    }

    /// Creates a new review by converting the domain model to a DTO and sending it to the API
    func createReview(review: Review) async throws -> Review? {
        do {
            let dto = review.toDTO()
            let responseDto = try await reviewApi.createReview(review: dto)
            let savedReview = responseDto.toDomain()

            let entityToSave = savedReview.toEntity()
            entityToSave.imageUrls = review.imageUrls.joined(separator: ",")

            modelContext.insert(entityToSave)
            try modelContext.save()

            return savedReview
        } catch {
            print(
                "[\(tag)] Error creating review: \(error.localizedDescription)"
            )
            return nil
        }
    }

    /// Handles the multi-step process of uploading multiple images to Cloudflare R2/S3
    /// 1. Generates filenames
    /// 2. Fetches pre-signed URLs
    /// 3. Processes and uploads images in parallel using Swift Concurrency Task Groups
    func uploadReviewImages(images: [UIImage]) async throws -> [String] {
        // 1. Generate placeholder filenames for the upload request
        let fileNames = images.enumerated().map { "review-\($0.offset).webp" }

        // 2. Fetch pre-signed upload URLs from the backend
        let uploadInfos = try await reviewApi.getReviewImageUploadUrls(
            fileNames: fileNames
        )

        // 3. Parallel upload using TaskGroup for maximum efficiency
        return await withTaskGroup(of: String?.self) { group in
            for (index, info) in uploadInfos.enumerated() {
                group.addTask {
                    do {
                        let image = images[index]

                        // Compress and resize image before network transmission
                        guard
                            let imageData = await self.processImage(
                                image: image
                            )
                        else {
                            return nil
                        }

                        // Execute the direct PUT request to the storage bucket
                        try await self.reviewApi.uploadImageToS3(
                            url: info.uploadUrl,
                            data: imageData
                        )

                        // Clean the object key (remove leading slashes) to build the final CDN URL
                        let cleanKey =
                            info.objectKey.hasPrefix("/")
                            ? String(info.objectKey.dropFirst())
                            : info.objectKey

                        // Construct final public URL matching the project's asset management convention
                        return "\(APIConfig.IMG_REVIEW)/\(cleanKey)"
                    } catch {
                        print(
                            "[\(self.tag)] Upload failed for \(info.objectKey): \(error.localizedDescription)"
                        )
                        return nil
                    }
                }
            }

            // Collect successful upload results
            var results: [String] = []
            for await url in group {
                if let url = url { results.append(url) }
            }
            return results
        }
    }

    /// Prepares images for upload by resizing them to a maximum width and compressing to JPEG
    /// This reduces bandwidth usage and storage costs on Cloudflare R2
    private func processImage(image: UIImage) -> Data? {
        let maxWidth: CGFloat = 1024
        var targetSize = image.size

        // Downscale if the image exceeds the maximum allowed width
        if image.size.width > maxWidth {
            let ratio = maxWidth / image.size.width
            targetSize = CGSize(
                width: maxWidth,
                height: image.size.height * ratio
            )
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0  // Use 1.0 to avoid unnecessary pixel density scaling

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        // Return compressed data (75% quality is usually the "sweet spot" for mobile)
        return resizedImage.jpegData(compressionQuality: 0.75)
    }
}
