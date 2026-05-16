//
//  ReviewScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/5/16.
//

//
//  ReviewScreen.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/5/15.
//

import SwiftUI
import Kingfisher

struct ReviewScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: ReviewViewModel

    init(container: AppContainer) {
        _viewModel = StateObject(
            wrappedValue: container.makeReviewViewModel()
        )
    }

    var body: some View {
        ReviewContent(
            state: viewModel.state,
            isLoggedIn: viewModel.isLoggedIn,
            onBack: {
                router.pop()
            },
            onLogin: {
                router.push(.login)
            },
            onDelete: { review in
                viewModel.deleteReview(review: review)
            }
        )
        .onAppear {
            viewModel.loadLocalReviews()
        }
    }
}

struct ReviewContent: View {
    let state: ReviewUIState
    let isLoggedIn: Bool
    var onBack: () -> Void
    var onLogin: () -> Void
    var onDelete: (Review) -> Void

    @State private var reviewToDelete: Review? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            if !isLoggedIn {
                LoginPrompt(onLogin : onLogin)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                switch state {
                case .idle:
                    Color.clear
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .error(let message):
                    Text(message)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let reviews):
                    if reviews.isEmpty {
                        emptyView(
                            icon: "text.bubble",
                            title: "No reviews found",
                            subtitle: "Your book reviews will appear here."
                        )
                    } else {
                        List {
                            ForEach(reviews) { review in
                                reviewRow(review: review)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                // 支持原生的 List 右滑删除
                                for index in indexSet {
                                    reviewToDelete = reviews[index]
                                    showDeleteAlert = true
                                }
                            }
                        }
                        .listStyle(.plain)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: onBack) {
//                    Image(systemName: "chevron.backward")
//                        .font(.body.weight(.medium))
//                }
//            }
//        }
        .background(Color(.systemGroupedBackground))
        .alert("Delete Review?", isPresented: $showDeleteAlert, presenting: reviewToDelete) { review in
            Button("Delete", role: .destructive) {
                onDelete(review)
                reviewToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                reviewToDelete = nil
            }
        } message: { _ in
            Text("This action will permanently remove your review and associated images from CoolLib. This cannot be undone.")
        }
    }

    @ViewBuilder
    private func reviewRow(review: Review) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部：书籍简要信息
            HStack(alignment: .top, spacing: 16) {
                // 统一改为你项目内的 Kingfisher + standardStyle 扩展样式
                KFImage(URL(string: review.book?.coverUrl ?? ""))
                    .standardStyle(width: 60, height: 90, cornerRadius: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(review.book?.title ?? "Unknown Book")
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)

                    Text(review.book?.author ?? "Unknown Author")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer().frame(height: 4)

                    // 星级展示
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(index < review.rating ? Color.orange : Color(.systemGray4))
                        }
                        Text(String(format: "%.1f", Double(review.rating)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.leading, 4)
                    }
                }
                Spacer()
            }

            Divider()
                .padding(.vertical, 12)

            // 底部：评论文本、晒图与日期
            VStack(alignment: .leading, spacing: 8) {
                if !review.content.isEmpty {
                        Text(review.content)
                            .font(.body)
                    }

                // 晒图横向滚动区域
                if !review.imageUrls.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(review.imageUrls, id: \.self) { imageUrl in
                                KFImage(URL(string: imageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Text("Reviewed on \(review.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private func emptyView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews
#Preview("Reviews - Filled") {
    NavigationStack {
        ReviewContent(
            state: .success(MockReviews.list),
            isLoggedIn: true,
            onBack: {},
            onLogin: {},
            onDelete: { _ in }
        )
    }
}

#Preview("Reviews - Empty") {
    NavigationStack {
        ReviewContent(
            state: .success([]),
            isLoggedIn: true,
            onBack: {},
            onLogin: {},
            onDelete: { _ in }
        )
    }
}
