//
//  LoanMapper.swift
//  CoolLib2
//
//  Created by susui on 2026/4/1.
//


extension LoanDTO {
    
    func toDomain(book: Book) -> Loan {
        Loan(
            id: id,
            book: book,
            borrowDate: borrowDate,
            dueDate: dueDate,
            status: status
        )
    }
}
