//
//  ReviewRow.swift
//  Containerized Library Ecosystem
//
//  Created by Ryan Su on 2026/5/3.
//

import Kingfisher
import SwiftUI

/// A model used to trigger the full-screen image preview.
/// Must be defined outside ReviewRow to ensure global visibility within the file.
struct ImageItem: Identifiable {
    let id: Int
}

struct ReviewRow: View {
    let review: Review
    
    // Tracks which image is currently selected for the full-screen modal
    @State private var selectedImageItem: ImageItem? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            ratingSection
            
            // Display review text only if it is not empty
            if !review.content.isEmpty {
                Text(review.content)
                    .font(.body)
                    .lineSpacing(4)
                    .padding(.bottom, 12)
            }

            // Display the horizontal scrollable list if images exist
            if !review.imageUrls.isEmpty {
                imageHorizontalList
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        // Present the full-screen image gallery when an ImageItem is assigned
        .fullScreenCover(item: $selectedImageItem) { (item: ImageItem) in
            ImagePreview(
                imageUrls: review.imageUrls,
                initialIndex: item.id
            )
        }
    }

    // --- Sub-view variables extracted to optimize Swift compiler performance ---

    /// User profile info and review timestamp
    private var headerSection: some View {
        HStack(spacing: 12) {
            ZStack {
                // Background circle with the user's first initial as a fallback
                Circle().fill(Color.accentColor).frame(width: 50, height: 50)
                Text(review.userName.prefix(1).uppercased())
                    .font(.headline).foregroundColor(.white)
                
                // Load user avatar from the backend service
                KFImage(URL(string: "\(APIConfig.IMG_USER)/\(review.userId).png"))
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.3)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(review.userName).font(.subheadline).fontWeight(.bold)
                Text(review.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2).foregroundColor(.secondary.opacity(0.6))
            }
            Spacer()
        }
        .padding(.bottom, 6)
    }

    /// Star-based rating display
    private var ratingSection: some View {
        HStack(spacing: 6) {
            ForEach(0..<5) { index in
                Image(systemName: index < review.rating ? "star.fill" : "star")
                    .foregroundColor(index < review.rating ? .orange : .gray.opacity(0.3))
            }
        }
        .padding(.bottom, 12)
    }

    /// Horizontal list of review images with tap-to-preview functionality
    private var imageHorizontalList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(review.imageUrls.enumerated()), id: \.offset) { index, imageUrl in
                    KFImage(URL(string: imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Assigning the item triggers the .fullScreenCover
                            self.selectedImageItem = ImageItem(id: index)
                        }
                }
            }
            .padding(.trailing, 16)
        }
        .frame(height: 120)
    }
}
