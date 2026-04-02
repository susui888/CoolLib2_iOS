//
//  StatCardView.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//
import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(.title, design: .serif))
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.22), radius: 1, y: 1)
    }
}

#Preview{
    StatCardView(
        title: "Currently Borrowed",
        value: "3",
        systemImage: "book.fill",
        color: .blue
    )
}
