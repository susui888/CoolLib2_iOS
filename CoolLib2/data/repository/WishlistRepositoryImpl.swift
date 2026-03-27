//  WishlistRepositoryImpl.swift
//  CoolLib2
//
//  Created by susui on 2026/3/27.
//



import Foundation
import SwiftData

@MainActor
final class WishlistRepositoryImpl: WishlistRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func toggleWishlist(book: Book) async throws {
        let exists = try await isBookInWishlist(bookId: book.id)

        if exists {
            try await removeFromWishlist(bookId: book.id)
        } else {
            try await addToWishlist(book: book)
        }
    }

    func addToWishlist(book: Book) async throws {
        if try await !isBookInWishlist(bookId: book.id) {
            modelContext.insert(book.toWishlistEntity())
            try modelContext.save()
        }
    }

    func removeFromWishlist(bookId: Int) async throws {
        let descriptor = FetchDescriptor<WishlistEntity>(
            predicate: #Predicate { $0.id == bookId }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(entity)
        try modelContext.save()
    }

    func isBookInWishlist(bookId: Int) async throws -> Bool {
        let descriptor = FetchDescriptor<WishlistEntity>(
            predicate: #Predicate { $0.id == bookId }
        )

        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }

    func allWishlistItems() async throws -> [Wishlist] {
        let descriptor = FetchDescriptor<WishlistEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        return (try? modelContext.fetch(descriptor).map { $0.toDomain() }) ?? []
    }

    func clearWishlist() async throws {

        try modelContext.delete(model: WishlistEntity.self)
        try modelContext.save()
    }

}
