//
//  AddReviewView.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/5/3.
//
import SwiftUI
import PhotosUI

struct AddReviewView: View {
    //1. add one extra param
    var onPostReview: (Int, String, [PhotosPickerItem]) -> Void

    @State private var rating: Int = 5
    @State private var content: String = ""

    //2. add image status
    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What do you think?")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)

            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(
                            index <= rating ? .orange : .gray.opacity(0.5)
                        )
                        .onTapGesture {
                            rating = index
                        }
                }
            }
            .padding(.vertical, 4)

            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Share your reading experience...")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $content)
                    .frame(height: 38)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .padding(.horizontal, 4)
            }
            .overlay(
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
            )


            ImageAttachmentRow(images: selectedItems) { index in
                selectedItems.remove(at: index)
            }
            
            
            HStack {
                // 4. add image select button
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    Image(systemName: "photo.badge.plus")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }

                Spacer()

                Button(action: {
                    let trimmedContent = content.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    if !trimmedContent.isEmpty {
                        onPostReview(rating, trimmedContent, selectedItems)
                        content = ""
                        selectedItems = []      //5.reset after submit
                    }
                }) {
                    Text("Post Review")
                        .fontWeight(.semibold)
                }
                .disabled(
                    content.trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                )
                .buttonStyle(.borderedProminent)
                .tint(.brown)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3))
        )
        .padding(.horizontal)
    }
}

#Preview {
    AddReviewView { rating, content, images in
        print("Rating: \(rating)")
        print("Content: \(content)")
        print("Images selected: \(images.count)")
    }
}
