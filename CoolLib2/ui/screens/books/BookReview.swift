//
//  BookReview.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Kingfisher
import SwiftUI

struct AddReviewView: View {
    var onPostReview: (Int, String) -> Void

    @State private var rating: Int = 5
    @State private var content: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What do you think?")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(
                            index <= rating ? .orange : .gray.opacity(0.5)
                        )
                        .onTapGesture {
                            rating = index
                        }
                }
            }
            .padding(.vertical, 4)

            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Share your reading experience...")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $content)
                    .frame(height: 38)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .padding(.horizontal, 4)
            }
            .overlay(
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
            )

            HStack {
                Spacer()

                Button(action: {
                    let trimmedContent = content.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    if !trimmedContent.isEmpty {
                        onPostReview(rating, trimmedContent)
                        content = ""
                    }
                }) {
                    Text("Post Review")
                        .fontWeight(.semibold)
                }
                .disabled(
                    content.trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                )
                .buttonStyle(.borderedProminent)
                .tint(.brown)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3))
        )
        .padding(.horizontal)
    }
}

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
                // 评论列表
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

struct ReviewRow: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {

                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 50, height: 50)

                    Text(review.userName.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.white)

                    KFImage(
                        URL(
                            string: "\(APIConfig.IMG_USER)/\(review.userId).png"
                        )
                    )
                    .placeholder {
                        Color.clear
                    }
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.3)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                }

                VStack(alignment: .leading) {
                    Text(review.userName)
                        .font(.subheadline)
                        .fontWeight(.bold)

                    Text(
                        review.createdAt.formatted(
                            date: .abbreviated,
                            time: .omitted
                        )
                    )
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }

                Spacer()
            }

            if !review.content.isEmpty {
                Text(review.content)
                    .font(.body)
                    .lineSpacing(4)
            }

            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Image(
                        systemName: index <= review.rating
                            ? "star.fill" : "star"
                    )
                    .font(.caption)
                    .foregroundColor(
                        index <= review.rating ? .orange : .gray.opacity(0.3)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2))
        )
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

#Preview("Review List with Mock") {
    ScrollView {
        AddReviewView { _,_ in }
        
        BookReviewView(reviews: MockReviews.getReviews(forBookId: 262))
            .padding(.vertical)
    }
}
