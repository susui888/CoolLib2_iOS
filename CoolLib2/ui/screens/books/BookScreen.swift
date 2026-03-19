//
//  BookScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/19.
//
import SwiftUI

struct BookScreen: View {

    @State var isGrid = true

    var body: some View {
        ZStack {
            if isGrid {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 5),
                            GridItem(.flexible(), spacing: 5),
                        ],
                        spacing: 14
                    ) {

                        ForEach(MockBooks.list) { book in
                            Button {

                            } label: {
                                BookGrid(book: book)
                            }
                        }
                    }
                }
            } else {
                List(MockBooks.list) { book in
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
        BookScreen(isGrid: true)
    }
}

