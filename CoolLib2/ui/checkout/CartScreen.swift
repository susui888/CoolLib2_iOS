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

struct CartScreen:View {

    
    var body: some View {
        CartScreenContent(
            cart: MockCart.list,
            wishlist: MockWishlist.list
        )
    }
}

struct CartScreenContent: View {
    
    @EnvironmentObject var router: AppRouter
    @State private var selectedTab: CartTab = .cart

    let cart: [Cart]
    let wishlist: [Wishlist]

    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Text("Cart").tag(CartTab.cart)
                Text("Favourites").tag(CartTab.wishlist)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if selectedTab == .wishlist {
                wishlistView
            } else {
                cartView
            }
        }
        .navigationTitle("Cart & Favourites")
        .navigationBarTitleDisplayMode(.inline)
    }

    var wishlistView: some View {
        Group {
            if wishlist.isEmpty {
                emptyView(
                    icon: "heart",
                    title: "No saved books",
                    subtitle: "Books you save will appear here"
                )
            } else {
                List {
                    ForEach(wishlist) { wishlist in
                        bookRow(book: wishlist.toBook())
                    }
                }
            }
        }
    }

    var cartView: some View {
        Group {
            if cart.isEmpty {
                emptyView(
                    icon: "cart",
                    title: "Cart is empty",
                    subtitle: "Books you add will appear here."
                )
            } else {
                List {
                    ForEach(cart) { cart in
                        bookRow(book: cart.toBook())
                    }
                }
                .listStyle(.plain)
            }
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
            router.push(.bookDetails(bookId: book.id))
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

    let container = AppContainer()
    let router = AppRouter(container: container)
    
    return NavigationStack {
        CartScreenContent(
            cart: MockCart.list,
            wishlist: MockWishlist.list
        )
        .environmentObject(router)
    }
}

#Preview("Cart & Wishlist - Empty") {
    NavigationStack {
        CartScreenContent(
            cart: [],
            wishlist: []
        )
    }
}
