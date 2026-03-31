import Combine
//
//  HomeViewModel.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/22.
//
import SwiftUI

enum HomeUIState {
    case idle
    case loading
    case success(
        categories: [Category],
        recent: [Book],
        favorites: [Book],
        newest: [Book]
    )
    case error(String)
}

@MainActor
class HomeViewModel: ObservableObject {

    @Published private(set) var state: HomeUIState = .idle

    private let bookUseCase: BookUseCases
    private let wishlistUseCase : WishlistUseCases

    init(bookUseCase: BookUseCases, wishlistUseCase: WishlistUseCases) {
        self.bookUseCase = bookUseCase
        self.wishlistUseCase = wishlistUseCase
    }

    func loadAllContent() {

        if case .loading = state { return }

        state = .loading

        Task {
            do {
                async let categoriesReq = try await bookUseCase.getCategory()
                async let newestReq = try await bookUseCase.getNewestBooks()

                async let recentReq = try await bookUseCase.getRecentBooks()
                async let rawFavorites = try await wishlistUseCase.allWishlistItems()

                let (categories, newest, recent, favoritesItems) = try await (
                    categoriesReq,
                    newestReq,
                    recentReq,
                    rawFavorites
                )

                let favorites = favoritesItems.map { $0.toBook() }
                
                state = .success(
                    categories: categories,
                    recent: recent,
                    favorites: favorites,
                    newest: newest
                )
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
