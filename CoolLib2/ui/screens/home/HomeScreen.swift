//
//  HomeScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//
import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var router: AppRouter

    @StateObject private var homeViewModel: HomeViewModel

    init(
        container: AppContainer
    ) {
        _homeViewModel = StateObject(
            wrappedValue: container.makeHomeViewModel()
        )
    }

    var body: some View {
        content
            .navigationTitle("CoolLib")
            .onAppear {
                homeViewModel.loadAllContent()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch homeViewModel.state {
        case .idle, .loading:
            ProgressView()
                .controlSize(.large)

        case .success(let categories, let recent, let favorites, let newest):
            HomeScreenContent(
                categoryList: categories,
                recentBooks: recent,
                wishlist: favorites,
                newestBooks: newest,
                onCategoryTap: { id in
                    router.push(.books(category: id))
                },
                onBookTap: { id in
                    router.push(.bookDetails(bookId: id))
                }
            )

        case .error(let message):
            ContentUnavailableView {
                Label("Error", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") { homeViewModel.loadAllContent() }
            }
        }
    }
}

struct HomeScreenContent: View {

    let categoryList: [Category]
    let recentBooks: [Book]
    let wishlist: [Book]
    let newestBooks: [Book]
    
    let onCategoryTap: (Int) -> Void
    let onBookTap: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                CategorySection(
                    title: "Discover by Category",
                    categories: categoryList,
                    onCategoryTap: onCategoryTap,
                )

                BookSection(
                    title: "Recently Viewed",
                    books: recentBooks,
                    onBookTap: onBookTap,
                )

                BookSection(
                    title: "Favourites",
                    books: wishlist,
                    onBookTap: onBookTap,
                )

                BookSection(
                    title: "New Arrivals",
                    books: newestBooks,
                    onBookTap: onBookTap,
                )
            }
            .padding(.vertical)
        }
    }
    
}

struct SectionTitle: View {

    let title: String

    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .padding(.horizontal)
    }
}

struct CategorySection: View {

    let title: String
    let categories: [Category]
    
    let onCategoryTap: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading) {

            SectionTitle(title: title)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(categories) { category in
                        Button {
                            onCategoryTap(category.id)
                        } label: {
                            CategoryCard(category: category)
                                .padding(.bottom, 4)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }
}

struct CategoryCard: View {

    let category: Category

    var body: some View {

        VStack(spacing: 10) {

            AsyncImage(url: URL(string: category.coverUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 240, height: 240)
            .clipped()

            Text(category.name)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
        }
        .frame(width: 240)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.22), radius: 1, y: 1)
    }
}

struct BookSection: View {

    @EnvironmentObject var router: AppRouter

    let title: String
    let books: [Book]
    
    let onBookTap: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading) {

            SectionTitle(title: title)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(books) { book in
                        Button {
                            onBookTap(book.id)
                        } label: {
                            BookCard(book: book)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
    }
}

struct BookCard: View {

    let book: Book

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: book.coverUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 140, height: 190)
            .clipped()

            Text(book.title)
                .font(.caption2)
                .fontWeight(.regular)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.bottom, 4)
                .padding(.horizontal, 4)
                .frame(height: 35)
        }
        .frame(width: 140)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.22), radius: 1, y: 1)
    }
}

#Preview {
    return NavigationStack {
        HomeScreenContent(
            categoryList: MockCategories.list,
            recentBooks: MockBooks.list.shuffled(),
            wishlist: MockBooks.list.shuffled(),
            newestBooks: MockBooks.list.shuffled(),
            onCategoryTap: { _ in },
            onBookTap: { _ in },
        )
    }
}
