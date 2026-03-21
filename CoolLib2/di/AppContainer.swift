//
//  AppContainer.swift
//  CoolLib2
//
//  Created by susui on 2026/3/21.
//

import SwiftUI
import Combine

@MainActor
final class AppContainer: ObservableObject {
    
    // MARK: - API
    private lazy var apiClient = APIClient()
    
    private lazy var bookAPI: BookAPI = BookAPIImpl(client: apiClient)
    
    // MARK: - Repository
    private lazy var bookRepository: BookRepository = BookRepositoryImpl(bookApi: bookAPI)
    
    // MARK: - UseCases
    private lazy var bookUseCases = BookUseCases(repo: bookRepository)
    
    // MARK: - ViewModels
    func makeBookViewModel() -> BookViewModel {
        BookViewModel(usecase: bookUseCases)
    }
}
