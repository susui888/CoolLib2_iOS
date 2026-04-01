//
//  Loan.swift
//  CoolLib2
//
//  Created by susui on 2026/4/1.
//

import SwiftUI
import Foundation

// MARK: - Loan Status
enum LoanStatus: String, Codable, CaseIterable {
    case borrowed = "Borrowed"
    case returned = "Returned"
    case overdue = "Overdue"


    var userFriendlyDescription: String {
        return self.rawValue
    }

    func isFinished() -> Bool {
        return self == .returned
    }
}

// MARK: - Loan Model
struct Loan: Identifiable {
    let id: Int
    var book: Book?
    var borrowDate: Date
    var dueDate: Date
    var returnDate: Date?
    var status: LoanStatus
}
