//
//  LoginPrompt.swift
//  CoolLib2
//
//  Created by susui on 2026/5/16.
//

import SwiftUI

struct LoginPrompt: View {
    let onLogin: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor.opacity(0.6))
            
            Text("Please login ...")
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
