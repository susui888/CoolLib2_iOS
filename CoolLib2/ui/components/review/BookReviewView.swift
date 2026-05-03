//
//  BookReview.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Kingfisher
import SwiftUI



struct BookReviewView: View {
    var reviews: [Review]

    private var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Reader Feedback")
                        .font(.title2)
                        .fontWeight(.heavy)

                    Text(
                        reviews.isEmpty
                            ? "No ratings yet"
                            : "Based on \(reviews.count) reviews"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer()

                if !reviews.isEmpty {
                    HStack {
                        Text(String(format: "%.1f", averageRating))
                            .font(.title2)
                            .fontWeight(.bold)
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            if reviews.isEmpty {
                Text("Be the first to rate this book!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(reviews.sorted(by: { $0.createdAt > $1.createdAt }))
                    { review in
                        ReviewRow(review: review)
                    }
                }
            }
        }
    }
}



#Preview("Review List with Mock") {
    ScrollView {
        AddReviewView { _,_,_ in }
        
        BookReviewView(reviews: MockReviews.getReviews(forBookId: 262))
            .padding(.vertical)
    }
}
