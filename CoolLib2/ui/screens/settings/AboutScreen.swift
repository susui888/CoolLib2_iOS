//
//  AboutScreen.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/17.
//

import SwiftUI

struct AboutScreen: View {

    var onUrlClick: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                // MARK: - Logo Section
                Image("User")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer().frame(height: 16)

                // MARK: - App Info Section
                Text("CoolLib")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Version 1.0.0 (Build 20260415)")
                    .font(.body)
                    .foregroundColor(.secondary)

                Spacer().frame(height: 32)

                // MARK: - Links Section
                InfoLinkItem(
                    label: "Website",
                    value: "ryansu.uk",
                    onClick: { onUrlClick("https://ryansu.uk") }
                )

                InfoLinkItem(
                    label: "GitHub",
                    value: "github.ryansu.uk",
                    onClick: { onUrlClick("https://github.ryansu.uk") }
                )

                Divider()
                    .padding(.vertical, 16)

                // MARK: - Technical Info Section
                Text(
                    "Developed as part of the CoolLib Ecosystem.\nBuilt with SwiftUI & Clean Architecture."
                )
                .font(.caption)
                .lineSpacing(4)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            .padding(24)
        }
        .navigationTitle("About CoolLib")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper View (Sub-composable)
struct InfoLinkItem: View {
    let label: String
    let value: String
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(value)
                    .font(.body)
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews (Light & Dark Mode)
#Preview("Light Mode") {
    AboutScreen(onUrlClick: { _ in })
}

#Preview("Dark Mode") {
    AboutScreen(onUrlClick: { _ in })
        .preferredColorScheme(.dark)
}
