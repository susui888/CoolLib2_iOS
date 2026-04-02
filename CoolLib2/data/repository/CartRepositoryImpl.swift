//
//  CartRepositoryImpl.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/23.
//

import Foundation
import SwiftData

@MainActor
final class CartRepositoryImpl: CartRepository {
    
    private let loanAPI: LoanAPI
    private let modelContext: ModelContext
    
    init(loanAPI: LoanAPI, modelContext: ModelContext) {
        self.modelContext = modelContext
        self.loanAPI = loanAPI
    }

    func toggleCart(book: Book) async throws {
        let exists = try await isBookInCart(bookId: book.id)

        if exists {
            try await removeFromCart(bookId: book.id)
        } else {
            try await addToCart(book: book)
        }
    }

    func addToCart(book: Book) async throws {
        if try await !isBookInCart(bookId: book.id) {
            modelContext.insert(book.toCartEntity())
            try modelContext.save()
        }
    }

    func removeFromCart(bookId: Int) async throws {
        let descriptor = FetchDescriptor<CartEntity>(
            predicate: #Predicate { $0.id == bookId }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(entity)
        try modelContext.save()
    }

    func isBookInCart(bookId: Int) async throws -> Bool {
        let descriptor = FetchDescriptor<CartEntity>(
            predicate: #Predicate { $0.id == bookId }
        )

        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }

    func allCartItems() async throws -> [Cart] {
        let descriptor = FetchDescriptor<CartEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        return (try? modelContext.fetch(descriptor).map { $0.toDomain() }) ?? []
    }

    func clearLocalCart() async throws {

        try modelContext.delete(model: CartEntity.self)
        try modelContext.save()
    }

    func borrowBooks(carts: [Cart]) async throws -> String {

        let dtoList = carts.map { $0.toDTO() }

        let response: BorrowResponse = try await loanAPI.borrowBooks(carts: dtoList)

        if response.status == "success" {
          
            try await clearLocalCart()
            return response.message
        } else {
            throw NSError(
                domain: "BorrowError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: response.message]
            )
        }
    }
}
