//
//  UserUseCases.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/31.
//

import Foundation

final class UserUseCase {

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func login(username: String, password: String) async throws -> LoginResponse
    {
        return try await userRepository.login(
            username: username,
            password: password
        )
    }

    func register(username: String, password: String, email: String)
        async throws -> String
    {
        return try await userRepository.register(
            username: username,
            password: password,
            email: email
        )
    }
}
