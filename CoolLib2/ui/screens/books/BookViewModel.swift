//
//  BookViewModel.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

import Combine
import SwiftUI

enum BookUIState{
    case idle
    case loading
    case success([Book])
    case error(String)
}

@MainActor
class BookViewModel: ObservableObject {

    @Published private(set) var state: BookUIState = .idle
    
    private let usecase: BookUseCases

    init(usecase: BookUseCases) {
        self.usecase = usecase
    }

    func search(query: SearchQuery) {
        Task {
            state = .loading
            do {
                let books = try await usecase.searchBooks(query: query)
                state = .success(books)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}


