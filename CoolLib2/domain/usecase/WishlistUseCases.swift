//
//  WishlistUseCases.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/27.
//

struct WishlistUseCases {

    private let repository: WishlistRepository

    init(repository: WishlistRepository) {
        self.repository = repository
    }

    func toggleWishlist(book: Book) async throws {
        try await repository.toggleWishlist(book: book)
    }

    func addToWishlist(book: Book) async throws {
        try await repository.addToWishlist(book: book)
    }

    func removeFromWishlist(bookId: Int) async throws {
        try await repository.removeFromWishlist(bookId: bookId)
    }

    func isBookInWishlist(bookId: Int) async throws -> Bool {
        try await repository.isBookInWishlist(bookId: bookId)
    }

    func allWishlistItems() async throws -> [Wishlist] {
        try await repository.allWishlistItems()
    }

    func clearWishlist() async throws {
        try await repository.clearWishlist()
    }
}
