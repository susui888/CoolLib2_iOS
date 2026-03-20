//
//  BookScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/19.
//
import SwiftUI

struct BookScreen: View {

    @State var isGrid = true
    let books: [Book]

    var body: some View {
        ZStack {
            if isGrid {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 5),
                            GridItem(.flexible(), spacing: 5),
                        ],
                        spacing: 24
                    ) {

                        ForEach(books) { book in
                            Button {

                            } label: {
                                BookGrid(book: book)
                            }
                        }
                    }
                }
            } else {
                List(books) { book in
                    Button {

                    } label: {
                        BookRow(book: book)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("Books")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isGrid.toggle()
                } label: {
                    Image(
                        systemName: isGrid ? "list.bullet" : "square.grid.2x2"
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        BookScreen(
            isGrid: true,
            books: MockBooks.list.shuffled()
        )
    }
}

