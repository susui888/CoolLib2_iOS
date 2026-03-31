//
//  BookDTO.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/21.
//

struct BookDTO: Codable, Sendable {
    
    let id: Int
    let isbn: String
    let title: String
    let author: String
    let publisher: String
    let year: Int
    let available: Bool
    let description: String?
}
