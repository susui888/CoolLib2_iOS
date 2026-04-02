//
//  LoanViewModel.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/2.
//

import SwiftUI
import Combine

// MARK: - UI State
struct LoanUIState {
    var loans: [Loan] = []
    var isLoading: Bool = false
    var isLoggedIn: Bool = false
    var errorMessage: String? = nil
}

// MARK: - ViewModel
@MainActor
final class LoanViewModel: ObservableObject {

    @Published private(set) var uiState = LoanUIState()

    private let loanUseCases: LoanUseCases
    private let sessionManager: SessionManager

    init(loanUseCases: LoanUseCases, sessionManager: SessionManager) {
        self.loanUseCases = loanUseCases
        self.sessionManager = sessionManager
    }
    
    // MARK: - Intentions / Actions

    func getLoans(loanType: LoanType) async {
        // 1. Login Check
        guard sessionManager.isLoggedIn else {
            uiState = LoanUIState(isLoggedIn: false)
            return
        }

        // 2. Start Loading & Reset State
        uiState.isLoading = true
        uiState.isLoggedIn = true
        uiState.errorMessage = nil
        
        do {
            // 3. Fetch Data from UseCase
            let allLoans = try await loanUseCases.getAllLoans()
            
            // 4. Filter Data based on LoanType
            let filteredLoans: [Loan]
            switch loanType {
            case .loans:
                filteredLoans = allLoans.filter { $0.status == .borrowed }
            case .history:
                filteredLoans = allLoans.filter {
                    $0.status == .returned || $0.status == .overdue
                }
            }

            // 5. Success Update
            uiState = LoanUIState(
                loans: filteredLoans,
                isLoading: false,
                isLoggedIn: true,
                errorMessage: nil
            )
            
        } catch {
            // 6. Error Update
            uiState.isLoading = false
            uiState.errorMessage = error.localizedDescription
            print("Failed to load loans: \(error)")
        }
    }
}
