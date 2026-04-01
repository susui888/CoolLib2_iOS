//
//  LoadRepository.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/1.
//

protocol LoanRepository {
    
    func getAllLoans() async throws -> [Loan]
}
