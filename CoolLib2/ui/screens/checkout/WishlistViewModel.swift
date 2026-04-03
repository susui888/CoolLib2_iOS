//
//  WishlistViewModel.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/27.
//

import Combine
import Foundation

enum WishlistUIState {
    case idle
    case loading
    case success([Wishlist])
    case error(String)
}

@MainActor
final class WishlistViewModel: ObservableObject {
    @Published private(set) var state: WishlistUIState = .idle

    private let usecase: WishlistUseCases

    init(usecase: WishlistUseCases) {
        self.usecase = usecase
    }

    func load() {
        if case .loading = state { return }

        state = .loading

        Task {
            do {
                let wishlists = try await usecase.allWishlistItems()
                state = .success(wishlists)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func toggleWishlist(book: Book)  {
        Task {
            do {
                try await usecase.toggleWishlist(book: book)
                
                let updatedItems = try await usecase.allWishlistItems()
                state = .success(updatedItems)
            } catch {
                state = .error("Failed to update cart")
            }
        }
    }

    func removeWishlist(bookId: Int)  {
        Task {
            do {
                try await usecase.removeFromWishlist(bookId: bookId)
                let updatedItems = try await usecase.allWishlistItems()
                state = .success(updatedItems)
            } catch {
                state = .error("Failed to remove item")
            }
        }
    }

    func isBookInWishlist(bookId: Int) async -> Bool {
        return (try? await usecase.isBookInWishlist(bookId: bookId)) ?? false
    }

    func clearWishlist()  {
        Task {
            do {
                try await usecase.clearWishlist()
                state = .success([])
            } catch {
                state = .error("Failed to clear cart")
            }
        }
    }
}
