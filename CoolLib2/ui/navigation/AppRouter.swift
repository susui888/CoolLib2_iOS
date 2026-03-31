import Combine
import SwiftUI

final class AppRouter: ObservableObject {  // The global router class managing navigation and tabs

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    // MARK: - Current Selected Tab
    @Published var selectedTab: Tab = .home  // Tracks the currently selected tab, SwiftUI updates automatically

    // MARK: - Navigation Paths for Each Tab
    @Published var homePath: [Screen] = []  // Navigation path for Home tab
    @Published var bookPath: [Screen] = []  // Navigation path for Book tab
    @Published var cartPath: [Screen] = []  // Navigation path for Cart tab
    @Published var statsPath: [Screen] = []  // Navigation path for Stats tab
    @Published var searchPath: [Screen] = []  // Navigation path for Search tab

    @Published var showLoginSheet: Bool = false

    func showLogin(_ isShown: Bool) {
        showLoginSheet = isShown
    }

    // MARK: - Push Screen to Current Tab
    func push(_ screen: Screen) {  // Push a Screen to the currently selected tab
        switch selectedTab {
        case .home:
            homePath.append(screen)
        case .book:
            bookPath.append(screen)
        case .cart:
            cartPath.append(screen)
        case .stats:
            statsPath.append(screen)
        case .search:
            searchPath.append(screen)
        }
    }

    // MARK: - Switch Tab
    func switchTo(tab: Tab) {  // Switch to a different tab
        selectedTab = tab
    }

    // MARK: - Push Screen to Specific Tab (Cross-Tab Navigation)
    func push(_ screen: Screen, on tab: Tab) {  // Push a Screen to a specific tab
        selectedTab = tab
        switch tab {
        case .home:
            homePath.append(screen)
        case .book:
            bookPath.append(screen)
        case .cart:
            cartPath.append(screen)
        case .stats:
            statsPath.append(screen)
        case .search:
            searchPath.append(screen)
        }
    }

    // MARK: - Screen to View Mapping
    @ViewBuilder
    func destination(for screen: Screen) -> some View {  // Map Screen enum to SwiftUI view
        switch screen {

        case .bookDetails(let id):
            BookDetailScreen(
                container: container,
                bookId: id
            )

        case .books(
            let category,
            let author,
            let publisher,
            let year,
            let searchTerm
        ):
            BookScreen(
                container: container,
                initialQuery: SearchQuery(
                    category: category,
                    author: author,
                    publisher: publisher,
                    year: year,
                    searchTerm: searchTerm
                )
            )

        case .myLoans:
            Text("My Loans Screen")
        case .reservations:
            Text("Reservations Screen")
        case .history:
            Text("History Screen")
        case .profile:
            Text("Profile Settings Screen")
        }
    }

    func navigate(fromMenu option: MenuOption) {
        switch option {
        case .login:
            showLogin(true)
        case .loans:
            push(.myLoans)
        case .reservations:
            push(.reservations)
        case .history:
            push(.history)
        case .profile:
            push(.profile)
        case .settings:
            push(.profile)  //Temp
        case .about:
            push(.profile)  //Temp
        }
    }
}
