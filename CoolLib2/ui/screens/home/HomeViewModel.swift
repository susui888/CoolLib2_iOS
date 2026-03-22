import Combine
//
//  HomeViewModel.swift
//  CoolLib2
//
//  Created by susui on 2026/3/22.
//
import SwiftUI

enum HomeUIState {
    case idle
    case loading
    case success(
        categories: [Category],
        recent: [Book],
        favorites: [Book],
        newest: [Book]
    )
    case error(String)
}

@MainActor
class HomeViewModel: ObservableObject {

    @Published private(set) var state: HomeUIState = .idle

    private let usecase: BookUseCases

    init(usecase: BookUseCases) {
        self.usecase = usecase
    }

    func loadAllContent() {

        if case .loading = state { return }

        state = .loading

        Task {
            do {
                async let categoriesReq = try await usecase.getCategory()
                async let newestReq = try await usecase.getNewestBooks()

                async let recentReq = MockBooks.list.shuffled()
                async let favoritesReq = MockBooks.list.shuffled()

                let (categories, newest, recent, favorites) = try await (
                    categoriesReq,
                    newestReq,
                    recentReq,
                    favoritesReq
                )

                state = .success(
                    categories: categories,
                    recent: recent,
                    favorites: favorites,
                    newest: newest
                )
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
