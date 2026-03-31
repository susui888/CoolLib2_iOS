//
//  UserRepository.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/31.
//

protocol UserRepository {
    
    func login(username: String, password: String) async throws -> LoginResponse

    func register(username: String, password: String, email: String) async throws -> String
}
