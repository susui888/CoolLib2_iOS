//
//  ScannerViewModel.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/3.
//

import Combine
import Foundation

struct ScanUiState {
    var isLoading: Bool = false
    var detectedBookTitle: String? = nil
    var error: String? = nil
    var shouldNavigateToCart: Bool = false
}

@MainActor
class ScannerViewModel: ObservableObject {

    @Published private(set) var uiState = ScanUiState()

    private let bookUseCase: BookUseCases
    private let cartUseCase: CartUseCases

    private var lastScannedIsbn: String? = nil
    private var lastScanTime: Date = Date.distantPast

    init(bookUseCase: BookUseCases, cartUseCase: CartUseCases) {
        self.bookUseCase = bookUseCase
        self.cartUseCase = cartUseCase
    }

    func processIsbn(_ isbn: String) {
        let currentTime = Date()

        guard !uiState.isLoading else { return }

        if isbn == lastScannedIsbn
            && currentTime.timeIntervalSince(lastScanTime) < 5.0
        {
            return
        }

        lastScannedIsbn = isbn
        lastScanTime = currentTime

        Task {
            uiState.isLoading = true

            do {
                let book = try await bookUseCase.getBookByISBN(isbn: isbn)

                try await cartUseCase.addToCart(book: book)

                uiState.isLoading = false
                uiState.detectedBookTitle = book.title
                uiState.shouldNavigateToCart = true

                TelemetryManager.shared.fire(
                    TelemetryEvents.Actions.bookAddCart,
                    bookId: book.id
                ) {
                    [
                        "isbn": isbn,
                        "trigger_source": "BARCODE_SCANNER",
                    ]
                }
            } catch {
                uiState.isLoading = false
                uiState.error = "Book not found"
                uiState.shouldNavigateToCart = false

                TelemetryManager.shared.fireError(
                    TelemetryEvents.Actions.homeDataLoadFailure,
                    message: error.localizedDescription.isEmpty
                        ? "Network error or JSON breakdown when fetching ISBN: \(isbn)"
                        : error.localizedDescription
                )
            }
        }
    }

    func resetNavigation() {
        uiState.shouldNavigateToCart = false
    }
}
