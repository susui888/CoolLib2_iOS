//
//  StatisticsScreen.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//

import SwiftUI

struct StatisticsScreen:View {
    
    var body: some View {
        StatisticsScreenContent()
    }
}

struct StatisticsScreenContent: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                StatCardView(
                    title: "Currently Borrowed",
                    value: "3",
                    systemImage: "book.fill"
                )

                StatCardView(
                    title: "Overdue",
                    value: "0",
                    systemImage: "exclamationmark.triangle.fill"
                )
                
                StatCardView(
                    title: "Total Borrowed",
                    value: "27",
                    systemImage: "books.vertical.fill"
                )
            }
            .padding()
        }
        .navigationTitle("Statistics")
    }
}

#Preview {
    StatisticsScreenContent()
        .preferredColorScheme(.light)
}

#Preview {
    StatisticsScreenContent()
        .preferredColorScheme(.dark)
}
