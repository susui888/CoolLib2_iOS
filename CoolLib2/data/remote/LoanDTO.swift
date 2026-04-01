//
//  LoanDTO.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/1.
//

import Foundation

struct LoanDTO: Codable, Sendable {
    let id: Int
    let bookId: Int
    let borrowDate: Date
    let dueDate: Date
    let returnDate: Date?
    let status: LoanStatus
}

