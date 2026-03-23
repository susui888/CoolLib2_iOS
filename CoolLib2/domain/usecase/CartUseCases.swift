//
//  CartUseCases.swift
//  CoolLib2
//
//  Created by susui on 2026/3/23.
//

struct CartUseCases {

    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func toggleCart(book: Book) async throws {
        try await repository.toggleCart(book: book)
    }

    func addToCart(book: Book) async throws {
        try await repository.addToCart(book: book)
    }

    func removeFromCart(bookId: Int) async throws {
        try await repository.removeFromCart(bookId: bookId)
    }

    func isBookInCart(bookId: Int) async throws -> Bool {
        try await repository.isBookInCart(bookId: bookId)
    }

    func allCartItems() async throws -> [Cart] {
        try await repository.allCartItems()
    }

    func clearLocalCart() async throws {
        try await repository.clearLocalCart()
    }
}
