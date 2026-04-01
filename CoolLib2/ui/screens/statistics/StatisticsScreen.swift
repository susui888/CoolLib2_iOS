//
//  StatisticsScreen.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//

import SwiftUI

struct StatisticsScreen:View {
    
    @EnvironmentObject var router: AppRouter

    @StateObject private var statisticsViewModel: StatisticsViewModel

    init(
        container: AppContainer,
    ) {
        _statisticsViewModel = StateObject(
            wrappedValue: container.makeStatisticsViewModel()
        )
    }
    
    var body: some View {
        StatisticsScreenContent(
            state: statisticsViewModel.uiState
        )
    }
}

import SwiftUI

struct StatisticsScreenContent: View {
    let state: StatisticsUIState
    
    var body: some View {
        ScrollView {
            if state.isLoading {
                ProgressView()
                    .padding(.top, 50)
            } else {
                VStack(spacing: 16) {

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCardView(
                            title: "Current",
                            value: "\(state.currentlyBorrowed)",
                            systemImage: "book.fill",
                            color: .blue
                        )
                        
                        StatCardView(
                            title: "Due Soon",
                            value: "\(state.dueSoon)",
                            systemImage: "clock.badge.exclamationmark.fill",
                            color: .orange
                        )
                        
                        StatCardView(
                            title: "Overdue",
                            value: "\(state.overdue)",
                            systemImage: "exclamationmark.triangle.fill",
                            color: .red
                        )
                        
                        StatCardView(
                            title: "Total",
                            value: "\(state.totalBorrowed)",
                            systemImage: "books.vertical.fill",
                            color: .secondary
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Statistics")
    }
}

// MARK: - Previews
#Preview("Light Mode") {
    NavigationStack {
        StatisticsScreenContent(state: StatisticsUIState(
            currentlyBorrowed: 2,
            dueSoon: 1,
            overdue: 0,
            totalBorrowed: 15,
            isLoading: false,
            isLoggedIn: true
        ))
        .navigationTitle("Statistics")
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationStack {
        StatisticsScreenContent(state: StatisticsUIState(
            currentlyBorrowed: 5,
            dueSoon: 3,
            overdue: 1,
            totalBorrowed: 20,
            isLoading: false,
            isLoggedIn: true
        ))
        .navigationTitle("Statistics")
    }
    .preferredColorScheme(.dark)
}
