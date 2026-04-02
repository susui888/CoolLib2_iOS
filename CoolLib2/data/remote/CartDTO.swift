//
//  CartDTO.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/2.
//

import Foundation

struct CartDTO: Codable, Sendable {
    
    let bookId: Int
    let quantity: Int
}

struct BorrowResponse: Decodable {
    let status: String
    let message: String
}
