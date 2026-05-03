//
//  ReviewImagePreview.swift
//  Containerized Library Ecosystem
//
//  Created by Ryan Su on 2026/5/3.
//

import SwiftUI
import Kingfisher

struct ImagePreview: View {
    let imageUrls: [String]
    let initialIndex: Int
    @Environment(\.dismiss) var dismiss // Uses environment variable to handle view dismissal

    // Used to track the current page number
    @State private var currentIndex: Int

    init(imageUrls: [String], initialIndex: Int) {
        self.imageUrls = imageUrls
        self.initialIndex = initialIndex
        // Set the starting page index during initialization
        _currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        ZStack {
            // Set background to black, covering the full screen
            Color.black
                .ignoresSafeArea()

            // Corresponds to HorizontalPager in other frameworks (e.g., Jetpack Compose)
            TabView(selection: $currentIndex) {
                ForEach(0..<imageUrls.count, id: \.self) { index in
                    KFImage(URL(string: "\(imageUrls[index])"))
                        .resizable()
                        .placeholder {
                            ProgressView()
                                .tint(.white)
                        }
                        .scaledToFit() // Equivalent to ContentScale.Fit
                        .tag(index) // Bound to selection for index tracking
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Enables paging and hides default dot indicators
            .ignoresSafeArea()

            // Top-aligned close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding(.top, 40) // Adjust for the Notch/Safe Area
                    .padding(.trailing, 16)
                }
                Spacer()
            }

            // Bottom page indicator (e.g., "1 / 3")
            if imageUrls.count > 1 {
                VStack {
                    Spacer()
                    Text("\(currentIndex + 1) / \(imageUrls.count)")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.black.opacity(0.4)))
                        .padding(.bottom, 40)
                }
            }
        }
    }
}
