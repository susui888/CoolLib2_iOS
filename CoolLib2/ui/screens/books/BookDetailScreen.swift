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
    @StateObject private var cartViewModel: CartViewModel
    @StateObject private var wishlistViewModel: WishlistViewModel

    @State private var isInCart: Bool = false
    @State private var isInWishlist: Bool = false

    private let bookId: Int

    init(
        container: AppContainer,
        bookId: Int
    ) {
        _detailViewModel = StateObject(
            wrappedValue: container.makeBookDetailViewModel()
        )
        _cartViewModel = StateObject(
            wrappedValue: container.makeCartViewModel()
        )
        _wishlistViewModel = StateObject(
            wrappedValue: container.makeWishlistViewModel()
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
            },

            inCart: isInCart,

            onToggleCart: { book in
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()  // 震动反馈

                cartViewModel.toggleCart(book: book)
                withAnimation(.spring()) {
                    isInCart.toggle()
                }
            },

            inWishlist: isInWishlist,
            
            onToggleWishlist: { book in
                wishlistViewModel.toggleWishlist(book: book)
                withAnimation(.spring()){
                    isInWishlist.toggle()
                }
            },
        )
        .onAppear {
            detailViewModel.getBook(id: bookId)
        }
        .task {
            isInCart = await cartViewModel.isBookInCart(bookId: bookId)
            isInWishlist = await wishlistViewModel.isBookInWishlist(
                bookId: bookId
            )
        }
    }
}

struct BookDetailScreenContent: View {
    let state: DetailState
    let onRetryTap: () -> Void
    let onAuthorTap: (String) -> Void
    let onPublisherTap: (String) -> Void
    let onYearTap: (Int) -> Void

    let inCart: Bool
    let onToggleCart: (Book) -> Void

    let inWishlist: Bool
    let onToggleWishlist: (Book) -> Void

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [.brown.opacity(0.35), .clear],
                startPoint: .top,
                endPoint: .bottom
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
                    onToggleCart(book)
                } label: {

                    HStack(spacing: 4) {
                        Image(
                            systemName: inCart
                                ? "cart.fill.badge.minus" : "cart.badge.plus"
                        )
                        .font(.system(size: 20))

                        Text(inCart ? "Remove" : "Add")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
                .disabled(!book.available)

                Button {
                    onToggleWishlist(book)
                } label: {
                    
                    HStack(spacing: 4){
                        Image (
                            systemName: inWishlist
                            ? "heart.fill" : "heart"
                        )
                        .font(.system(size: 20))
                        
                        Text(inWishlist ? "Remove" : "Favourite")
                            .font(.system(size:16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
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
            inCart: false,
            onToggleCart: { _ in },
            inWishlist: false,
            onToggleWishlist: { _ in }
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
        inCart: true,
        onToggleCart: { _ in },
        inWishlist: true,
        onToggleWishlist: { _ in }
    )
}

#Preview("Error State") {
    BookDetailScreenContent(
        state: .error("Could not find the book server."),
        onRetryTap: {},
        onAuthorTap: { _ in },
        onPublisherTap: { _ in },
        onYearTap: { _ in },
        inCart: true,
        onToggleCart: { _ in },
        inWishlist: true,
        onToggleWishlist: { _ in },
    )
}
