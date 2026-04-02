//
//  AppContainer.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/21.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class AppContainer: ObservableObject {

    private let modelContext: ModelContext

    let sessionManager = SessionManager.shared

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - API
    private(set) lazy var apiClient: APIClient = {
        APIClient(sessionManager: sessionManager)
    }()

    private lazy var bookAPI: BookAPI = BookAPIImpl(client: apiClient)
    private lazy var userAPI: UserAPI = UserAPIImpl(
        client: apiClient,
        sessionManager: sessionManager
    )
    private lazy var loanAPI: LoanAPI = LoanAPIImpl(client: apiClient)

    // MARK: - Repository
    private lazy var bookRepository: BookRepository = BookRepositoryImpl(
        bookApi: bookAPI,
        modelContext: modelContext
    )

    private lazy var cartRepository: CartRepository = CartRepositoryImpl(
        modelContext: modelContext
    )

    private lazy var wishlistRepository: WishlistRepository =
        WishlistRepositoryImpl(
            modelContext: modelContext
        )

    lazy var userRepository: UserRepository = UserRepositoryImpl(
        userApi: userAPI
    )

    private lazy var loanRepository: LoanRepository = LoanRepositoryImpl(
        loanApi: loanAPI,
        bookRepository: bookRepository
    )

    // MARK: - UseCases
    private lazy var bookUseCases = BookUseCases(repository: bookRepository)

    private lazy var cartUseCases = CartUseCases(repository: cartRepository)

    private lazy var wishlistUseCases = WishlistUseCases(
        repository: wishlistRepository
    )

    private lazy var userUseCases = UserUseCase(userRepository: userRepository)

    private lazy var loanUseCases = LoanUseCases(repository: loanRepository)

    // MARK: - ViewModels
    func makeBookViewModel() -> BookViewModel {
        BookViewModel(usecase: bookUseCases)
    }

    func makeBookDetailViewModel() -> BookDetailViewModel {
        BookDetailViewModel(usecase: bookUseCases)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            bookUseCase: bookUseCases,
            wishlistUseCase: wishlistUseCases
        )
    }

    func makeCartViewModel() -> CartViewModel {
        return sharedCartViewModel
    }

    private(set) lazy var sharedCartViewModel: CartViewModel = {
        CartViewModel(usecase: cartUseCases)
    }()

    func makeWishlistViewModel() -> WishlistViewModel {
        WishlistViewModel(usecase: wishlistUseCases)
    }

    func makeUserViewModel() -> UserViewModel {
        UserViewModel(userUseCase: userUseCases, sessionManager: sessionManager)
    }

    func makeStatisticsViewModel() -> StatisticsViewModel {
        StatisticsViewModel(
            loanUseCases: loanUseCases,
            sessionManager: sessionManager
        )
    }

    func makeLoanViewModel() -> LoanViewModel {
        LoanViewModel(
            loanUseCases: loanUseCases,
            sessionManager: sessionManager
        )
    }

    func makeSessionManager() -> SessionManager {
        return sessionManager
    }
}
