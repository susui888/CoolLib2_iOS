//
//  CartViewModel.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/23.
//

import Combine
import Foundation

enum CartUIState {
    case idle
    case loading
    case success([Cart])
    case error(String)
}

extension CartUIState {
    var count: Int {
        if case .success(let items) = self {
            return items.count
        }
        return 0
    }
}

@MainActor
final class CartViewModel: ObservableObject {
    @Published private(set) var state: CartUIState = .idle

    private let usecase: CartUseCases

    init(usecase: CartUseCases) {
        self.usecase = usecase
    }

    func load() {
        if case .loading = state { return }

        state = .loading

        Task {
            do {
                let carts = try await usecase.allCartItems()
                state = .success(carts)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func toggleCart(book: Book) {
        Task {
            do {
                try await usecase.toggleCart(book: book)

                let updatedItems = try await usecase.allCartItems()
                state = .success(updatedItems)
            } catch {
                state = .error("Failed to update cart")
            }
        }
    }

    func removeCart(bookId: Int) {
        Task {
            do {
                try await usecase.removeFromCart(bookId: bookId)
                let updatedItems = try await usecase.allCartItems()
                state = .success(updatedItems)
            } catch {
                state = .error("Failed to remove item")
            }
        }
    }

    func isBookInCart(bookId: Int) async -> Bool {
        return (try? await usecase.isBookInCart(bookId: bookId)) ?? false
    }

    func clearLocalCart() {
        Task {
            do {
                try await usecase.clearLocalCart()
                state = .success([])
            } catch {
                state = .error("Failed to clear cart")
            }
        }
    }

    // MARK: - Borrow Books Logic


    func borrowBooks() async throws {
        guard case .success(let items) = state, !items.isEmpty else { return }
        
        let _ = try await usecase.borrowBooks(carts: items)
        state = .success([])
    }
}
