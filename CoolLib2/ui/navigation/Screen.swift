enum Screen: Hashable {
    case bookDetails(bookId: Int)
    case books(
        category: Int? = nil,
        author: String? = nil,
        publisher: String? = nil,
        year: Int? = nil,
        searchTerm: String? = nil
    )
    case myLoans
    case reservations
    case history
    case profile
}

enum Tab: Hashable {
    case home
    case book
    case cart
    case stats
    case search
}

enum MenuOption: CaseIterable {
    case loans
    case reservations
    case history
    case profile
    case settings
    case about
    case login
}
