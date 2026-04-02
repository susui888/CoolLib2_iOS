//
//  LoanAPI.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/1.
//

protocol LoanAPI {
    
    func getAllLoans() async throws -> [LoanDTO]
    
    func borrowBooks(carts: [CartDTO]) async throws -> BorrowResponse
}
