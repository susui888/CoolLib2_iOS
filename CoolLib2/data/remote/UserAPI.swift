//
//  UserAPI.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/31.
//

struct LoginResponse: Codable,Equatable {
    let token: String
    let username: String
}


protocol UserAPI {
    /// 对应 @POST("auth/login")
    func login(request: UserDTO) async throws -> LoginResponse
    
    /// 对应 @POST("auth/register")
    func register(request: UserDTO) async throws -> String
}
