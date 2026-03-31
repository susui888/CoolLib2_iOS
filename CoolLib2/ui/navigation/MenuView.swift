//
//  MenuView.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/30.
//

import SwiftUI

struct MenuView: View {
    
    let isLoggedIn: Bool
    let username: String?
    
    let onMenuTap: (MenuOption) -> Void
    let onLogout: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View{
        ScrollView {
            VStack(spacing: 16) {
                
                VStack {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width:80, height: 80)
                        .foregroundColor(.brown)
                    
                    Text(username ?? "Guest")
                        .font(.title2)
                        .bold()
                    
                    if !isLoggedIn {
                        Text("Please login th access your lirary")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                
                VStack(spacing: 0) {
                    MenuItem(icon: "list.bullet", title: "My Loans") {
                        onMenuTap(.loans)
                    }
                    Divider()
                    MenuItem(icon:"bookmark", title: "Reservations") {
                        onMenuTap(.reservations)
                    }
                    Divider()
                    MenuItem(icon: "clock", title: "History"){
                        onMenuTap(.history)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                VStack(spacing: 0){
                    MenuItem(icon: "person", title: "Profile") {
                        onMenuTap(.profile)
                    }
                    Divider()
                    MenuItem(icon: "gear", title: "Settings") {
                        onMenuTap(.settings)
                    }
                    Divider()
                    MenuItem(icon: "info.circle", title: "About") {
                        onMenuTap(.about)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                VStack(spacing: 0) {
                    if isLoggedIn {
                        MenuItem(
                            icon: "arrow.right.square",
                            title: "Logout",
                            color: .red,
                            action: {
                                onLogout()
                            }
                        )
                    } else {
                        MenuItem(
                            icon: "arrow.right.square",
                            title: "Login",
                            action: {
                                onMenuTap(.login)
                            }
                        )
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
        }
    }
}

struct MenuItem: View {
    let icon: String
    let title: String
    var color: Color = .primary
    let action: () -> Void
    
    var body: some View{
        Button(action: action) {
            HStack{
                Image(systemName: icon)
                    .frame(width:28, height: 28)
                    .foregroundColor(color)
                
                Text(title)
                    .foregroundColor(color)
                    .font(.headline)
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    NavigationStack {
        MenuView(
            isLoggedIn: true,
            username: "Ryan Su",
            onMenuTap: { _ in },
            onLogout: {}
        )
    }
}
