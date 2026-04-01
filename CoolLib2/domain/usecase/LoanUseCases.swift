//
//  LoanUseCases.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/1.
//

struct LoanUseCases {
    private let repository: LoanRepository
    
    init(repository: LoanRepository) {
        self.repository = repository
    }
    
    func getAllLoans() async throws -> [Loan] {
        try await repository.getAllLoans().sorted { $0.borrowDate > $1.borrowDate }
    }
}
