import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var container: AppContainer

    @StateObject private var cartViewModel: CartViewModel

    @State private var topBarManager: TopBarManager

    init(container: AppContainer, router: AppRouter) {
        self._cartViewModel = StateObject(
            wrappedValue: container.makeCartViewModel()
        )
        self._topBarManager = State(
            wrappedValue: TopBarManager(container: container, router: router)
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
                    .topBar(manager: topBarManager)
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
                    .topBar(manager: topBarManager)
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
                    .topBar(manager: topBarManager)
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
                    .topBar(manager: topBarManager)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)
        }
        .onAppear {
            cartViewModel.load()
        }
        .sheet(isPresented: $router.showLoginSheet) {
            NavigationStack {
                LoginScreen(container: container)
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
