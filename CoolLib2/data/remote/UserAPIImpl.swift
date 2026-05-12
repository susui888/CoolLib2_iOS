//
//  UserAPIImpl.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/31.
//
import Alamofire

final class UserAPIImpl: UserAPI {
    
    private let client: APIClient
    private let sessionManager: SessionManager

    init(client: APIClient, sessionManager: SessionManager) {
        self.client = client
        self.sessionManager = sessionManager
    }
    
    func login(request: UserDTO) async throws -> LoginResponse {
        let urlString = "\(APIConfig.serverURL)/api/auth/login"
        
        let response: LoginResponse = try await client.request(
            urlString,
            method: .post,
            body: request
        )
        
        sessionManager.saveSession(token: response.token, username: response.username)
        
        return response
    }
    
    func register(request: UserDTO) async throws -> MessageResponse {
        let urlString = "\(APIConfig.serverURL)/api/auth/register"
        
        return try await client.request(
            urlString,
            method: .post,
            body: request
        )
    }
}
