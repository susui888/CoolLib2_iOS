//
//  BookScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/19.
//
import SwiftUI

struct BookScreen: View {
    @StateObject private var bookViewModel: BookViewModel

    init(container: AppContainer) {
        _bookViewModel = StateObject(
            wrappedValue: container.makeBookViewModel()
        )
    }

    var body: some View {
        BookScreenContent(
            books: $bookViewModel.books
        )
        .onAppear {
            if bookViewModel.books.isEmpty {
                bookViewModel.search(query: SearchQuery())
            }
        }
    }
}

struct BookScreenContent: View {

    @EnvironmentObject var router: AppRouter

    @State private var isGrid = true

    @Binding var books: [Book]

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
                                router.push(.bookDetails(bookId: book.id))
                            } label: {
                                BookGrid(book: book)
                            }
                        }
                    }
                }
            } else {
                List(books) { book in
                    Button {
                        router.push(.bookDetails(bookId: book.id))
                    } label: {
                        BookRow(book: book)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("\(books.count) Books Found")
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
    let container = AppContainer()
    let router = AppRouter(container: container)
    
    NavigationStack {
        BookScreenContent(books: .constant(MockBooks.list))
            .environmentObject(router)
            .environmentObject(container)
    }
}

