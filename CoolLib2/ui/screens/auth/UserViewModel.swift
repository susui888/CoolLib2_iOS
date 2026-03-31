//
//  UserViewModel.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/31.
//

import Combine
import Foundation

enum AuthUIState<T: Equatable>: Equatable {
    case idle
    case loading
    case success(T)
    case error(String)
}

@MainActor
final class UserViewModel: ObservableObject {

    private let userUseCase: UserUseCase
    private let sessionManager: SessionManager

    // MARK: - Published State (Equivalent to StateFlow)
    @Published var loginState: AuthUIState<LoginResponse> = .idle
    @Published var registerState: AuthUIState<String> = .idle

    private let tag = "UserViewModel"

    init(userUseCase: UserUseCase, sessionManager: SessionManager) {
        self.userUseCase = userUseCase
        self.sessionManager = sessionManager
    }

    // MARK: - Actions

    func login(username: String, password: String) {
        Task {
            loginState = .loading

            do {
                let response = try await userUseCase.login(
                    username: username,
                    password: password
                )

                print("[\(tag)] Login Successful: \(response.username)")
                            
                loginState = .success(response)
            }catch let error as APIError {
                loginState = .error("Error Code: \(error.code)")
            }catch {
                let errorMsg =
                    (error as? APIError)?.localizedDescription
                    ?? error.localizedDescription
                
                loginState = .error(errorMsg)
            }
        }
    }

    func register(username: String, password: String, email: String) {
        Task {
            // 1. Set to loading state
            registerState = .loading

            do {
                let message = try await userUseCase.register(
                    username: username,
                    password: password,
                    email: email
                )
                // 2. Success state
                self.registerState = .success(message)
                print("[\(tag)] Register Success: \(message)")

            } catch {
                // 3. Error state with localized message
                let errorMsg =
                    (error as? APIError)?.localizedDescription
                    ?? error.localizedDescription
                print("[\(tag)] Register Error: \(errorMsg)")
                self.registerState = .error(errorMsg)
            }
        }
    }

    func resetStates() {
        loginState = .idle
        registerState = .idle
    }
}
