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

    // MARK: - Private Logic
    private func performLogin(username: String, password: String) async -> AuthUIState<LoginResponse> {
        do {
            let response = try await userUseCase.login(username: username, password: password)
            
            sessionManager.saveSession(token: response.token, username: response.username)
            
            print("[\(tag)] Token Saved. username: \(response.username), token: \(response.token)")
            return .success(response)
        } catch {
            let errorMsg = error.localizedDescription
            print("[\(tag)] Login Failed: \(errorMsg)")
            return .error(errorMsg)
        }
    }

    // MARK: - Actions

    func login(username: String, password: String) {
        Task {
            loginState = .loading
            loginState = await performLogin(username: username, password: password)
        }
    }

    func register(username: String, password: String, email: String) {
        Task {
            registerState = .loading

            do {
                let result = try await userUseCase.register(
                    username: username,
                    password: password,
                    email: email
                )
                
                
                self.registerState = .success(result.message)
                print("[\(tag)] Register Success: \(result.message)")

                // 注册成功后尝试自动登录 (匹配 Kotlin 逻辑)
                print("[\(tag)] Attempting auto-login for: \(username)")
                loginState = .loading
                loginState = await performLogin(username: username, password: password)

            } catch {
                let errorMsg = error.localizedDescription
                print("[\(tag)] Register Error: \(errorMsg)")
                registerState = .error(errorMsg)
            }
        }
    }

    func clearLoginResult() {
        loginState = .idle
    }

    func clearRegisterResult() {
        registerState = .idle
    }
    
    func resetStates() {
        loginState = .idle
        registerState = .idle
    }
}
