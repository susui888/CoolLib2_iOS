//
//  LoanScreen.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/2.
//

import SwiftUI
import Kingfisher

struct LoanScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: LoanViewModel
    
    private let loanType: LoanType
    
    init(
        container: AppContainer,
        loanType: LoanType
    ) {
        _viewModel = StateObject(
            wrappedValue: container.makeLoanViewModel()
        )
        self.loanType = loanType
    }
    
    var body: some View {
        LoanScreenContent(
            loans: viewModel.uiState.loans,
            isLoading: viewModel.uiState.isLoading,
            isLoggedIn: viewModel.uiState.isLoggedIn,
            title: loanType == .loans ? "Current Loans" : "Loan History",
            onBack: {
                router.pop()
            },
            onLogin: {
                router.showLogin(true)
            }
        )
        .task {
            await viewModel.getLoans(loanType: loanType)
        }
    }
}

struct LoanScreenContent: View {
    let loans: [Loan]
    let isLoading: Bool
    let isLoggedIn: Bool
    let title: String
    let onBack: () -> Void
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                }
                
                Text(title)
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))

            Divider()

            // Main Content
            ZStack {
                if !isLoggedIn {
                    LoginPrompt(onLogin: onLogin)
                } else if isLoading && loans.isEmpty {
                    ProgressView("Loading records...")
                } else if loans.isEmpty && !isLoading {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No loan records found")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(loans) { loan in
                        LoanItemView(loan: loan)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        // Optional: Add pull-to-refresh logic here if needed
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
    }
}



// MARK: - Subviews

struct LoginPrompt: View {
    let onLogin: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor.opacity(0.6))
            
            Text("Please login to view your loans")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: onLogin) {
                Text("Login Now")
                    .bold()
                    .frame(maxWidth: 200)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(24)
    }
}

struct LoanItemView: View {
    let loan: Loan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                
                KFImage(URL(string: loan.book?.coverUrl ?? ""))
                    .standardStyle(width: 60, height: 90, cornerRadius: 6)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(loan.book?.title ?? "Unknown Book")
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(loan.book?.author ?? "Unknown Author")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer(minLength: 8)
                    
                    StatusBadge(status: loan.status)
                }
            }
            
            Divider()
            
            HStack {
                DateInfoView(label: "Borrowed", date: loan.borrowDate)
                Spacer()
                DateInfoView(label: "Due Date", date: loan.dueDate)
                if let returnDate = loan.returnDate {
                    Spacer()
                    DateInfoView(label: "Returned", date: returnDate)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.22), radius: 1, y: 1)
    }
}

struct StatusBadge: View {
    let status: LoanStatus
    
    var body: some View {
        Text(status.description)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.displayColor.opacity(0.15))
            .foregroundColor(status.displayColor)
            .cornerRadius(4)
    }
}

struct DateInfoView: View {
    let label: String
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(date, format: .dateTime.month().day().year())
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Previews

#Preview("Current Loans") {
    LoanScreenContent(
        loans: MockLoans.list, // Add mock data here if available
        isLoading: false,
        isLoggedIn: true,
        title: "Current Loans",
        onBack: {},
        onLogin: {}
    )
}

#Preview("Not Logged In") {
    LoanScreenContent(
        loans: [],
        isLoading: false,
        isLoggedIn: false,
        title: "Loan Records",
        onBack: {},
        onLogin: {}
    )
}
