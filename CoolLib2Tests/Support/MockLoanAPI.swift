//
//  MockLoanAPI.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/14.
//

import Foundation
@testable import CoolLib2

final class MockLoanAPI: LoanAPI {
    
    var stubLoans: [CoolLib2.LoanDTO] = []
    var stubBorrowResponse: CoolLib2.BorrowResponse?
    var shouldThrowError = false

    func getAllLoans() async throws -> [CoolLib2.LoanDTO] {
        if shouldThrowError { throw createError() }
        return stubLoans
    }
    
    func borrowBooks(carts: [CoolLib2.CartDTO]) async throws -> CoolLib2.BorrowResponse {
        if shouldThrowError { throw createError() }
        
        if let response = stubBorrowResponse {
            return response
        }
        
        // 将 status 改为 "success" 以匹配 Repository 中的 if 判断
        return CoolLib2.BorrowResponse(status: "success", message: "Success")
    }

    private func createError() -> NSError {
        return NSError(
            domain: "MockLoanAPIError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Network failure"]
        )
    }
}
