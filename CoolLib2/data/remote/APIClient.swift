//
//  APIClient.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/21.
//

import Foundation

final class APIClient {
    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    // MARK: - Auth Interceptor Logic (Private)
    private func intercept(_ request: URLRequest) -> URLRequest {
        var requestBuilder = request
        
        // Get token from session manager
        if let token = sessionManager.getToken(), !token.isEmpty {
            requestBuilder.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return requestBuilder
    }

    // MARK: - 1. Original GET Method
    func request<T: Decodable>(_ urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        // Step 1: Create request
        let urlRequest = URLRequest(url: url)
        
        // Step 2: Apply Interceptor
        let interceptedRequest = intercept(urlRequest)
        
        // Step 3: Proceed with call
        let (data, response) = try await URLSession.shared.data(for: interceptedRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.serverError(code: httpResponse.statusCode)
        }
        
        return try decode(data: data)
    }
    
    // MARK: - 2. New POST Method
    func request<T: Decodable, B: Encodable>(
        _ urlString: String,
        method: String,
        body: B
    ) async throws -> T {
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        // Step 1: Create request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.jsonDecodingFailed
        }
        
        // Step 2: Apply Interceptor
        let interceptedRequest = intercept(urlRequest)
        
        // Step 3: Proceed with call
        let (data, response) = try await URLSession.shared.data(for: interceptedRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.serverError(code: httpResponse.statusCode)
        }
        
        return try decode(data: data)
    }
    
    // MARK: - Shared Decoding Logic
    private func decode<T: Decodable>(data: Data) throws -> T {
        if T.self == String.self {
            guard let string = String(data: data, encoding: .utf8) as? T else {
                throw APIError.stringDecodingFailed
            }
            return string
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.jsonDecodingFailed
        }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(code: Int)
    case jsonDecodingFailed
    case stringDecodingFailed
    
    var code: Int {
            switch self {
            case .serverError(let code):
                return code
            case .invalidURL:
                return -1 
            case .invalidResponse:
                return -2
            case .jsonDecodingFailed:
                return -3
            case .stringDecodingFailed:
                return -4
            }
        }
}
