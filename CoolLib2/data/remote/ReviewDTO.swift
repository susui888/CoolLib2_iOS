//
//  ReviewDTO.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import Foundation

struct ReviewDTO: Codable, Identifiable {
    let id: Int?
    let bookId: Int
    let userId: Int
    let userName: String
    let rating: Int16
    let content: String?
    let imageUrls: [String]?
    let createdAt: Date
}
