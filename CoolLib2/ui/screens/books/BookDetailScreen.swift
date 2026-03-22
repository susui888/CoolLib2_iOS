//
//  BookDetailScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//

import SwiftUI

struct BookDetailScreen: View {

    @EnvironmentObject var router: AppRouter

    @StateObject private var detailViewModel: BookDetailViewModel

    private let bookId: Int

    init(
        container: AppContainer,
        bookId: Int
    ) {
        _detailViewModel = StateObject(
            wrappedValue: container.makeBookDetailViewModel()
        )
        self.bookId = bookId
    }

    var body: some View {
        BookDetailScreenContent(
            state: detailViewModel.state,
            onRetryTap: {
                detailViewModel.getBook(id: bookId)
            },
            onAuthorTap: { author in
                router.push(.books(author: author))
            },
            onPublisherTap: { publisher in
                router.push(.books(publisher: publisher))
            },
            onYearTap: { year in
                router.push(.books(year: year))
            }
        )
        .onAppear {
            detailViewModel.getBook(id: bookId)
        }
    }
}

struct BookDetailScreenContent: View {
    let state: DetailState
    let onRetryTap: () -> Void
    let onAuthorTap: (String) -> Void
    let onPublisherTap: (String) -> Void
    let onYearTap: (Int) -> Void

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [.brown.opacity(0.25), .clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            switch state {
            case .loading:
                ProgressView("Fetching book details...")
                    .controlSize(.large)

            case .error(let message):
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again") {
                        onRetryTap()
                    }
                    .buttonStyle(.borderedProminent)
                }

            case .success(let book):
                renderBookDetail(book)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func renderBookDetail(_ book: Book) -> some View {
        ScrollView {
            VStack(spacing: 24) {

                AsyncImage(url: URL(string: book.coverUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .overlay(ProgressView())
                }
                .frame(width: 180, height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(radius: 8, y: 6)
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 16) {
                    Text(book.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Button {
                        onAuthorTap(book.author)
                    } label: {
                        Text("by \(book.author)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            onPublisherTap(book.publisher)
                        } label: {
                            Label(
                                "Publisher: \(book.publisher)",
                                systemImage: "building.columns"
                            )
                        }

                        Button {
                            onYearTap(book.year)
                        } label: {
                            Label(
                                "Year: \(book.year, format: .number.grouping(.never))",
                                systemImage: "calendar"
                            )
                        }

                        Label(
                            book.available ? "Available" : "Unavailable",
                            systemImage: book.available
                                ? "checkmark.circle" : "xmark.circle"
                        )
                        .foregroundStyle(book.available ? .green : .red)
                    }

                    Divider()

                    Text("Description")
                        .font(.headline)

                    Text(book.description)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 100)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 16) {
                Button {
                    // Add to cart
                } label: {
                    Label("Add", systemImage: "cart.fill.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)

                Button {
                    // Favourite
                } label: {
                    Label("Favourite", systemImage: "heart")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

#Preview("Success State") {
    NavigationStack {
        BookDetailScreenContent(
            state: .success(MockBooks.list[0]),
            onRetryTap: {},
            onAuthorTap: { _ in },
            onPublisherTap: { _ in },
            onYearTap: { _ in },
        )
    }
}

#Preview("Loading State") {
    BookDetailScreenContent(
        state: .loading,
        onRetryTap: {},
        onAuthorTap: { _ in },
        onPublisherTap: { _ in },
        onYearTap: { _ in },
    )
}

#Preview("Error State") {
    BookDetailScreenContent(
        state: .error("Could not find the book server."),
        onRetryTap: {},
        onAuthorTap: { _ in },
        onPublisherTap: { _ in },
        onYearTap: { _ in },
    )
}
