//
//  CartScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//
import SwiftUI

enum CartTab {
    case wishlist
    case cart
}

struct CartScreen: View {
    @EnvironmentObject var router: AppRouter

    @StateObject private var cartViewModel: CartViewModel

    init(
        container: AppContainer,
    ) {
        _cartViewModel = StateObject(
            wrappedValue: container.makeCartViewModel()
        )
    }

    var body: some View {
        CartScreenContent(
            cartState: cartViewModel.state,
            onDeleteCartItem: { id in
                cartViewModel.removeCart(bookId: id)
            },
            onCartItemTap: { id in
                router.push(.bookDetails(bookId: id))
            }
        )
        .onAppear {
            cartViewModel.load()
        }
    }
}

struct CartScreenContent: View {
    let cartState: CartUIState
    let onDeleteCartItem: (Int) -> Void
    let onCartItemTap: (Int) -> Void

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
//            if wishlist.isEmpty {
//                emptyView(
//                    icon: "heart",
//                    title: "No saved books",
//                    subtitle: "Books you save will appear here"
//                )
//            } else {
//                List {
//                    ForEach(wishlist) { wishlist in
//                        bookRow(book: wishlist.toBook())
//                    }
//                }
//            }
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
            onCartItemTap(book.id)
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
            onCartItemTap: { _ in }
        )
    }
}

#Preview("Cart & Wishlist - Empty") {
    NavigationStack {
        CartScreenContent(
            cartState: .success([]),
            onDeleteCartItem: { _ in },
            onCartItemTap: { _ in }
        )
    }
}
