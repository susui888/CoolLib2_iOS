//
//  LoanRepositoryImpl.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/1.
//

import Foundation


final class LoanRepositoryImpl: LoanRepository {
    
    private let loanApi: LoanAPI
    private let bookRepository: BookRepository
    
    init(loanApi: LoanAPI, bookRepository: BookRepository) {
        self.loanApi = loanApi
        self.bookRepository = bookRepository
    }

    func getAllLoans() async -> [Loan] {
        do {

            let loanDtos = try await loanApi.getAllLoans()

            let results = try await withThrowingTaskGroup(of: Loan?.self) { group in
                for dto in loanDtos {
                    group.addTask {
                        do {
                            let book = try await self.bookRepository.getBookById(id: dto.bookId)
                            return await dto.toDomain(book: book)
                        } catch {
                            print("Failed to fetch book details for ID \(dto.bookId): \(error)")
                            return nil
                        }
                    }
                }
                
                var loans: [Loan] = []
                for try await loan in group {
                    if let loan = loan {
                        loans.append(loan)
                    }
                }
                return loans
            }
            
            return results
            
        } catch {
            print("Error fetching loans: \(error)")
            return []
        }
    }
}
