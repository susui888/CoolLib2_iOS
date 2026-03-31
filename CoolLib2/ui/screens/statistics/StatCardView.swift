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
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title)
                .frame(width: 40)
            
            
            VStack(alignment: .leading){
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title)
                    .bold()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview{
    StatCardView(
        title: "Currently Borrowed",
        value: "3",
        systemImage: "book.fill"
    )
}
