//
//  LoanAPIImpl.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/1.
//

import Foundation

final class LoanAPIImpl: LoanAPI{
    
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }
    
    
    func getAllLoans() async throws -> [LoanDTO] {
        let urlString = "\(APIConfig.serverURL)/api/loan"
        
        return try await client.request(urlString)
    }
}
