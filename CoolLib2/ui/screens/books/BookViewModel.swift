//
//  BookViewModel.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

import Combine
import SwiftUI

@MainActor
class BookViewModel: ObservableObject {

    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let usecase: BookUseCases

    init(usecase: BookUseCases) {
        self.usecase = usecase
    }

    func search(query: SearchQuery) {
        execute {
            self.books = try await self.usecase.searchBooks(query: query)
            
            print("bookViewModel")
            print(self.books.count)
        }
    }

    private func execute(_ block: @escaping () async throws -> Void) {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                try await block()
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
