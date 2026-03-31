//
//  UserRepositoryImpl.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/31.
//


final class UserRepositoryImpl: UserRepository {
    
    private let userApi: UserAPI

    init(userApi: UserAPI) {
        self.userApi = userApi
    }
    
    func login(username: String, password: String) async throws -> LoginResponse {
        let dto = UserDTO(username: username, password: password, email: "")
        return try await userApi.login(request: dto)
    }
    
    func register(username: String, password: String, email: String) async throws -> String {
        let dto = UserDTO(username: username, password: password, email: email)
        return try await userApi.register(request: dto)
    }
}
