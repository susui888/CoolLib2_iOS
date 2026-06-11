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

                TelemetryManager.shared.fireError(
                    TelemetryEvents.Actions.homeDataLoadFailure,
                    message: error.localizedDescription
                )
            }
        }
    }

    func toggleCart(book: Book) {
        Task {
            do {
                let isInCart = try await usecase.isBookInCart(bookId: book.id)

                try await usecase.toggleCart(book: book)

                TelemetryManager.shared.fire(
                    isInCart
                        ? TelemetryEvents.Actions.bookRemoveCart
                        : TelemetryEvents.Actions.bookAddCart,
                    bookId: book.id
                )

                let updatedItems = try await usecase.allCartItems()
                state = .success(updatedItems)
            } catch {
                state = .error("Failed to update cart")

                TelemetryManager.shared.fireError(
                    TelemetryEvents.Actions.borrowActionFailure,
                    message: error.localizedDescription
                )
            }
        }
    }

    func removeCart(bookId: Int) {
        Task {
            do {
                try await usecase.removeFromCart(bookId: bookId)

                TelemetryManager.shared.fire(
                    TelemetryEvents.Actions.bookRemoveCart,
                    bookId: bookId
                )

                let updatedItems = try await usecase.allCartItems()
                state = .success(updatedItems)
            } catch {
                state = .error("Failed to remove item")

                TelemetryManager.shared.fireError(
                    TelemetryEvents.Actions.borrowActionFailure,
                    message: error.localizedDescription
                )
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

                TelemetryManager.shared.fire(
                    TelemetryEvents.Actions.bookRemoveCart
                )
            } catch {
                state = .error("Failed to clear cart")
            }
        }
    }

    // MARK: - Borrow Books Logic

    func borrowBooks() async throws {
        guard case .success(let items) = state, !items.isEmpty else { return }

        do {
            let _ = try await usecase.borrowBooks(carts: items)

            let itemCount = items.count
            TelemetryManager.shared.fire(TelemetryEvents.Actions.bookRentAction)
            {
                ["cart_items_count": itemCount]
            }

            state = .success([])
        } catch {

            TelemetryManager.shared.fireError(
                TelemetryEvents.Actions.borrowActionFailure,
                message: error.localizedDescription
            )
            throw error
        }
    }
}
