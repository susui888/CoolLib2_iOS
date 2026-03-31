//
//  BookScreen.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//
import SwiftUI

struct BookScreen: View {
    @EnvironmentObject var router: AppRouter

    @StateObject private var bookViewModel: BookViewModel

    private let initialQuery: SearchQuery
    
    init(
        container: AppContainer,
        initialQuery: SearchQuery
    ) {
        _bookViewModel = StateObject(
            wrappedValue: container.makeBookViewModel()
        )
        self.initialQuery = initialQuery
    }

    var body: some View {

        BookScreenContent(
            state: bookViewModel.state,
            onRetryTap: {
                bookViewModel.search(query: initialQuery)
            },
            onBookTap: { bookId in
                router.push(.bookDetails(bookId: bookId))
            }
        )
        .onAppear {
            if case .idle = bookViewModel.state {
                bookViewModel.search(query: initialQuery)
            }
        }
    }
}

struct BookScreenContent: View {

    let state: BookUIState
    let onRetryTap: () -> Void
    let onBookTap: (Int) -> Void

    @State private var isGrid = true
    var body: some View {
        ZStack {
            switch state {
            case .idle:
                Color.clear
            
            case .loading:
                ProgressView("Loading...")
                
            case .error(let message):
                VStack(spacing: 12){
                    Text("Error").font(.headline)
                    Text(message).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    Button("Retry") { onRetryTap() }.buttonStyle(.bordered)
                }
                .padding()
                
            case .success(let books):
                if books.isEmpty {
                    ContentUnavailableView("No Books Found", systemImage: "book")
                } else {
                    renderBooks(books)
                }
            }
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isGrid.toggle()
                } label: {
                    Image(
                        systemName: isGrid ? "list.bullet" : "square.grid.2x2")}
            }
        }
    }
    
    private var navigationTitle: String {
        if case .success(let books) = state {
            return "\(books.count) Books Found"
        }
        return "Books"
    }
    
    @ViewBuilder
        private func renderBooks(_ books: [Book]) -> some View {
            if isGrid {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                        ForEach(books) { book in
                            Button { onBookTap(book.id) } label: { BookGrid(book: book) }
                        }
                    }
                }
            } else {
                List(books) { book in
                    Button { onBookTap(book.id) } label: { BookRow(book: book) }
                    .buttonStyle(.plain)
                }
            }
        }
}

#Preview("Success State") {
    NavigationStack {
        BookScreenContent(
            state: .success(MockBooks.list),
            onRetryTap: {},
            onBookTap: { _ in }
        )
    }
}

#Preview("Loading State") {
    NavigationStack {
        BookScreenContent(
            state: .loading,
            onRetryTap: {},
            onBookTap: { _ in }
        )
    }
}

#Preview("Error State") {
    NavigationStack {
        BookScreenContent(
            state: .error("Connection Timeout"),
            onRetryTap: {},
            onBookTap: { _ in }
        )
    }
}

