import SwiftUI

enum Tab {
    case home
    case book
    case cart
    case stats
    case search
}

struct MainTabView: View {

    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var container: AppContainer

    var body: some View {
        TabView(selection: $router.selectedTab) {

            // MARK: - Home Tab
            NavigationStack(path: $router.homePath) {
                HomeScreen(container: container)
                    .navigationDestination(for: Screen.self) {
                        router.destination(for: $0)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Tab.home)

            // MARK: - Book Tab
            NavigationStack(path: $router.bookPath) {
                BookScreen(container: container, initialQuery: SearchQuery())
                    .navigationDestination(for: Screen.self) {
                        router.destination(for: $0)
                    }
            }
            .tabItem {
                Label("Book", systemImage: "book")
            }
            .tag(Tab.book)

            // MARK: - Cart Tab
            NavigationStack(path: $router.cartPath) {
                CartScreen()
                    .navigationDestination(for: Screen.self) {
                        router.destination(for: $0)
                    }
            }
            .tabItem {
                Label("Cart", systemImage: "cart.fill")
            }
            .tag(Tab.cart)

            // MARK: - Stats Tab
            NavigationStack(path: $router.statsPath) {
                StatisticsScreen()
                    .navigationDestination(for: Screen.self) {
                        router.destination(for: $0)
                    }
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(Tab.stats)

            // MARK: - Search Tab
            NavigationStack(path: $router.searchPath) {
                SearchScreen()
                    .navigationDestination(for: Screen.self) {
                        router.destination(for: $0)
                    }
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)
        }
    }
}

#Preview {

    let container = AppContainer()
    let router = AppRouter(container: container)
    
    return MainTabView()
        .environmentObject(router)
        .environmentObject(container)
}
