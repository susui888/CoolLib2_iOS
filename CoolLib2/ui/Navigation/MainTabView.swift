//
//  MainTabView.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//

import SwiftUI

enum Tab {
    case home
    case book
    case cart
    case stats
    case search
}

struct MainTabView: View {

    @State private var path: [Screen] = []
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationStack(path: $path) {
                HomeScreen(
                    categoryList: MockCategories.list,
                    lastViewBooks: MockBooks.list.shuffled(),
                    wishlist: MockBooks.list.shuffled(),
                    newestBooks: MockBooks.list.shuffled()
                )
            }
            .tabItem{
                Label("Home",systemImage: "house.fill")
            }
            .tag(Tab.home)
            
            
            NavigationStack(path: $path){
                BookScreen(
                    isGrid: true,
                    books: MockBooks.list.shuffled()
                )
            }
            .tabItem{
                Label("Book",systemImage: "book")
            }
            .tag(Tab.book)
            
            
            NavigationStack(path: $path){
                CartScreen(
                    cart: MockCart.list,
                    wishlist: MockWishlist.list
                )
            }
            .tabItem {
                Label("Cart",systemImage: "cart.fill")
            }
            .tag(Tab.cart)
            
            
            NavigationStack(path: $path){
                StatisticsScreen()
            }
            .tabItem {
                Label("Stats",systemImage: "chart.bar.fill")
            }
            .tag(Tab.stats)
            
            
            NavigationStack(path: $path){
                SearchScreen()
            }
            .tabItem {
                Label("Search",systemImage: "magnifyingglass")
            }
            .tag(Tab.search)
        }
    }
}

#Preview {
    MainTabView()
}
