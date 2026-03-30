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

    @StateObject private var cartViewModel: CartViewModel

    @State private var topBarManager = TopBarManager()

    init(container: AppContainer) {
        self._cartViewModel = StateObject(
            wrappedValue: container.makeCartViewModel()
        )
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {

            // MARK: - Home Tab
            NavigationStack(path: $router.homePath) {
                HomeScreen(container: container)
                    .navigationDestination(for: Screen.self) {
                        router.destination(for: $0)
                    }
                    .topBar(manager: topBarManager)
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
                CartScreen(container: container)
                    .navigationDestination(for: Screen.self) {
                        router.destination(for: $0)
                    }
            }
            .tabItem {
                Label("Cart", systemImage: "cart.fill")
            }
            .badge(cartViewModel.state.count)
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
        .onAppear {
            cartViewModel.load()
            topBarManager.container = container
            topBarManager.router = router
        }
        .sheet(isPresented: $router.showLoginSheet) {
            NavigationStack {
                LoginScreen { username, password in
                    router.showLoginSheet = false
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            router.showLoginSheet = false
                        } label: {
                            Image(systemName: "xmark")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                    }
                }
            }
        }
    }
}
