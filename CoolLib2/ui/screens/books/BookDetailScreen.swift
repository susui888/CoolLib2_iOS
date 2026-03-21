//
//  BookDetailScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//

import SwiftUI

struct BookDetailScreen:View {
    
    let bookId: Int
    
    var body: some View {
        BookDetailScreenContent(book: MockBooks.list.first.unsafelyUnwrapped)
    }
}

struct BookDetailScreenContent: View {

    let book: Book

    var body: some View {
        ZStack {
            
            LinearGradient(
                colors: [
                    .brown.opacity(0.25),
                    .clear
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    AsyncImage(url: URL(string: book.coverUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .fill(.gray.opacity(0.2))
                    }
                    .frame(width: 180, height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(radius: 8, y: 6)
                    .padding(.top, 16)
                    
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text(book.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button {
                            
                        } label: {
                            Text("by \(book.author)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            
                            Label(
                                "Publisher: \(book.publisher)",
                                systemImage: "building.columns"
                            )
                            
                            Label(
                                "Year: \(book.year)",
                                systemImage: "calendar"
                            )

                            Label(
                                book.available ? "Available" : "Unavailable",
                                systemImage: book.available
                                    ? "checkmark.circle"
                                    : "xmark.circle"
                            )
                            .foregroundStyle(book.available ? .green : .red)
                        }

                        Divider()

                        Text("Description")
                            .font(.headline)

                        Text(book.description)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 16) {
                
                Button {
                    
                } label: {
                    Label("Add", systemImage: "cart.fill.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)

                Button {
                    
                } label: {
                    Label("Favourite", systemImage: "heart")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    BookDetailScreenContent(book: MockBooks.list.first.unsafelyUnwrapped)
}
