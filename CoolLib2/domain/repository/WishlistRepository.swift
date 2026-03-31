//
//  WishlistRepository.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/27.
//

protocol WishlistRepository {
    func toggleWishlist(book: Book) async throws
    
    func addToWishlist(book: Book) async throws
    
    func removeFromWishlist(bookId: Int) async throws
    
    func isBookInWishlist(bookId: Int) async throws -> Bool
    
    func allWishlistItems() async throws -> [Wishlist]
    
    func clearWishlist() async throws
}
