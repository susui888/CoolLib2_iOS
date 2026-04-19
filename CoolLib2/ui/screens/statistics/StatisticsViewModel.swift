//
//  StatisticsViewModel.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/1.
//

import Combine
import SwiftUI

// MARK: - UI State
struct StatisticsUIState {
    var currentlyBorrowed: Int = 0
    var dueSoon: Int = 0
    var overdue: Int = 0
    var totalBorrowed: Int = 0
    var weeklyActivity: [Double] = Array(repeating: 0.0, count: 14)
    var isLoading: Bool = false
    var isLoggedIn: Bool = false
    var errorMessage: String? = nil
}

// MARK: - ViewModel
@MainActor
final class StatisticsViewModel: ObservableObject {

    @Published private(set) var uiState = StatisticsUIState()

    private let loanUseCases: LoanUseCases
    private let sessionManager: SessionManager

    init(loanUseCases: LoanUseCases, sessionManager: SessionManager) {
        self.loanUseCases = loanUseCases
        self.sessionManager = sessionManager

        Task {
            await loadStatistics()
        }
    }

    func loadStatistics() async {

        guard sessionManager.isLoggedIn else {
            uiState = StatisticsUIState(isLoggedIn: false)
            return
        }

        uiState.isLoading = true
        uiState.isLoggedIn = true
        uiState.errorMessage = nil

        do {
            let loans = try await loanUseCases.getAllLoans()

            let now = Date()
            let calendar = Calendar.current

            let borrowedCount = loans.count { $0.status == .borrowed }
            let overdueCount = loans.count { $0.status == .overdue }

            let dueSoonCount = loans.count { loan in
                guard loan.status == .borrowed else { return false }

                let components = calendar.dateComponents(
                    [.day],
                    from: now,
                    to: loan.dueDate
                )
                let days = components.day ?? -1
                return (0...3).contains(days)
            }

            // Process Activity Trend (Last 14 Days)
            // Get dates for the last 14 days (stripped of time)
            let last14Days = (0..<14).compactMap { offset -> Date? in
                calendar.date(byAdding: .day, value: -offset, to: now)
            }.reversed()

            // Map loans to daily counts
            let dailyCounts: [Double] = last14Days.map { date in
                Double(
                    loans.filter { loan in
                        calendar.isDate(loan.borrowDate, inSameDayAs: date)
                    }.count
                )
            }

            // Normalize (0.0 ~ 1.0)
            let maxVal = dailyCounts.max() ?? 1.0
            let normalizedActivity = dailyCounts.map {
                maxVal == 0 ? 0.0 : $0 / maxVal
            }

            uiState = StatisticsUIState(
                currentlyBorrowed: borrowedCount,
                dueSoon: dueSoonCount,
                overdue: overdueCount,
                totalBorrowed: loans.count,
                weeklyActivity: normalizedActivity,
                isLoading: false,
                isLoggedIn: true
            )

        } catch {
            uiState.isLoading = false
            uiState.errorMessage = error.localizedDescription
            print("Failed to load statistics: \(error)")
        }
    }
}
