import Combine
import SafariServices
import SwiftUI

final class AppRouter: ObservableObject {
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    @Published var selectedTab: Tab = .home
    @Published var homePath: [Screen] = []
    @Published var bookPath: [Screen] = []
    @Published var cartPath: [Screen] = []
    @Published var statsPath: [Screen] = []
    @Published var searchPath: [Screen] = []
    @Published var showLoginSheet: Bool = false

    func showLogin(_ isShown: Bool) {
        showLoginSheet = isShown
    }

    // MARK: - Navigation Methods

    func pop() {
        updatePath(for: selectedTab) { path in
            if !path.isEmpty {
                path.removeLast()
            }
        }
    }

    func popToRoot() {
        updatePath(for: selectedTab) { path in
            path.removeAll()
        }
    }

    func push(_ screen: Screen) {
        updatePath(for: selectedTab) { path in
            path.append(screen)
        }
    }

    func switchTo(tab: Tab) {
        selectedTab = tab
    }

    func push(_ screen: Screen, on tab: Tab) {
        selectedTab = tab
        updatePath(for: tab) { path in
            path.append(screen)
        }
    }

    // MARK: - Private Helpers

    private func updatePath(for tab: Tab, action: (inout [Screen]) -> Void) {
        switch tab {
        case .home: action(&homePath)
        case .book: action(&bookPath)
        case .cart: action(&cartPath)
        case .stats: action(&statsPath)
        case .search: action(&searchPath)
        }
    }

    // MARK: - Screen to View Mapping
    @ViewBuilder
    func destination(for screen: Screen) -> some View {
        switch screen {
        case .bookDetails(let id):
            BookDetailScreen(container: container, bookId: id)

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

        case .loans(let loanType):
            LoanScreen(container: container, loanType: loanType)

        case .about:
            AboutScreen(
                onUrlClick: { urlString in
                    self.openSafari(with: urlString)
                }
            )
        }

    }

    func navigate(fromMenu option: MenuOption) {
        switch option {
        case .login:
            showLogin(true)
        case .loans:
            push(.loans(loanType: .loans))
        case .history:
            push(.loans(loanType: .history))
        case .reservations, .profile, .settings:
            showLogin(true)
        case .about:
            push(.about)
        }
    }

    private func openSafari(with urlString: String) {
        guard let url = URL(string: urlString) else { return }

        if let windowScene = UIApplication.shared.connectedScenes.first
            as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        {
            let safariVC = SFSafariViewController(url: url)
            safariVC.dismissButtonStyle = .done
            rootVC.present(safariVC, animated: true)
        } else {
            UIApplication.shared.open(url)
        }
    }
}
