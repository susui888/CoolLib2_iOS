//
//  CartScreen.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/20.
//
import SwiftUI

enum CartTab {
    case wishlist
    case cart
}

struct CartScreen: View {
    @EnvironmentObject var router: AppRouter

    @StateObject private var cartViewModel: CartViewModel
    @StateObject private var wishlistViewModel: WishlistViewModel

    init(
        container: AppContainer,
    ) {
        _cartViewModel = StateObject(
            wrappedValue: container.makeCartViewModel()
        )

        _wishlistViewModel = StateObject(
            wrappedValue: container.makeWishlistViewModel()
        )
    }

    var body: some View {
        CartScreenContent(
            cartState: cartViewModel.state,

            onDeleteCartItem: { id in
                cartViewModel.removeCart(bookId: id)
            },

            onItemTap: { id in
                router.push(.bookDetails(bookId: id))
            },

            onBorrow: {
                Task {
                    try? await cartViewModel.borrowBooks()
                    router.navigate(fromMenu: .loans)
                }
            },

            wishlistState: wishlistViewModel.state,

            onDeleteWishlistItem: { id in
                wishlistViewModel.removeWishlist(bookId: id)
            },
        )
        .onAppear {
            cartViewModel.load()
            wishlistViewModel.load()
        }
    }
}

struct CartScreenContent: View {
    let cartState: CartUIState
    let onDeleteCartItem: (Int) -> Void
    let onItemTap: (Int) -> Void
    let onBorrow: () -> Void

    let wishlistState: WishlistUIState
    let onDeleteWishlistItem: (Int) -> Void

    @State private var selectedTab: CartTab = .cart

    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Text("Cart").tag(CartTab.cart)
                Text("Favourites").tag(CartTab.wishlist)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch selectedTab {
            case .wishlist:
                renderWishlist()
            case .cart:
                renderCart()
            }
        }
        .navigationTitle("Cart & Favourites")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func renderWishlist() -> some View {
        switch wishlistState {
        case .idle:
            Color.clear
        case .loading:
            ProgressView().frame(maxHeight: .infinity)
        case .success(let items):
            if items.isEmpty {
                emptyView(
                    icon: "heart",
                    title: "No saved book",
                    subtitle: "Books you save will appear here"
                )
            } else {
                List {
                    ForEach(items) { item in
                        bookRow(book: item.toBook())
                    }
                    .onDelete { IndexSet in
                        for index in IndexSet {
                            onDeleteWishlistItem(items[index].id)
                        }

                    }
                }
                .listStyle(.plain)
            }
        case .error(let message):
            Text(message).foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private func renderCart() -> some View {
        switch cartState {
        case .idle:
            Color.clear
        case .loading:
            ProgressView().frame(maxHeight: .infinity)
        case .success(let items):
            if items.isEmpty {
                emptyView(
                    icon: "cart",
                    title: "Cart is empty",
                    subtitle: "Books you add will appear here."
                )
            } else {
                List {
                    ForEach(items) { item in
                        bookRow(book: item.toBook())
                    }
                    .onDelete { IndexSet in
                        for index in IndexSet {
                            onDeleteCartItem(items[index].id)
                        }
                    }
                }
                .listStyle(.plain)

                Button(action: onBorrow) {
                    Text("Borrow All (\(items.count))")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
                .background(.background)
                .shadow(color: .black.opacity(0.05), radius: 5, y: -5)
            }
        case .error(let message):
            Text(message).foregroundStyle(.red)
        }
    }

    func bookRow(book: Book) -> some View {
        HStack(spacing: 12) {

            AsyncImage(url: URL(string: book.coverUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(.gray.opacity(0.2))
            }
            .frame(width: 60, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)

                Text(book.author)
                    .font(.subheadline)

                Text(book.publisher)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .onTapGesture {
            onItemTap(book.id)
        }
    }

    func emptyView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.default)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(subtitle)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Cart & Wishlist - Filled") {
    NavigationStack {
        CartScreenContent(
            cartState: .success(MockCart.list),
            onDeleteCartItem: { _ in },
            onItemTap: { _ in },
            onBorrow: {},
            wishlistState: .success(MockWishlist.list),
            onDeleteWishlistItem: { _ in },
        )
    }
}

#Preview("Cart & Wishlist - Empty") {
    NavigationStack {
        CartScreenContent(
            cartState: .success([]),
            onDeleteCartItem: { _ in },
            onItemTap: { _ in },
            onBorrow: {},
            wishlistState: .success(MockWishlist.list),
            onDeleteWishlistItem: { _ in }
        )
    }
}
