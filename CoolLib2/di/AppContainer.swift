//
//  AppContainer.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class AppContainer: ObservableObject {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - API
    private lazy var apiClient = APIClient()

    private lazy var bookAPI: BookAPI = BookAPIImpl(client: apiClient)

    // MARK: - Repository
    private lazy var bookRepository: BookRepository = BookRepositoryImpl(
        bookApi: bookAPI,
        modelContext: modelContext
    )

    private lazy var cartRepository: CartRepository = CartRepositoryImpl(
        modelContext: modelContext
    )

    // MARK: - UseCases
    private lazy var bookUseCases = BookUseCases(repository: bookRepository)

    private lazy var cartUseCases = CartUseCases(repository: cartRepository)

    // MARK: - ViewModels
    func makeBookViewModel() -> BookViewModel {
        BookViewModel(usecase: bookUseCases)
    }

    func makeBookDetailViewModel() -> BookDetailViewModel {
        BookDetailViewModel(usecase: bookUseCases)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(usecase: bookUseCases)
    }

    func makeCartViewModel() -> CartViewModel {
        return sharedCartViewModel
    }
    
    private(set) lazy var sharedCartViewModel: CartViewModel = {
        CartViewModel(usecase: cartUseCases)
    }()
}
