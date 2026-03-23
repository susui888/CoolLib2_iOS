//
//  CartRepository.swift
//  CoolLib2
//
//  Created by susui on 2026/3/23.
//

protocol CartRepository {
    func toggleCart(book: Book) async throws
    
    func addToCart(book: Book) async throws
    
    func removeFromCart(bookId: Int) async throws
    
    func isBookInCart(bookId: Int) async throws -> Bool
    
    func allCartItems() async throws -> [Cart]
    
    func clearLocalCart() async throws
}
