//
//  APIClient.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/21.
//

import Foundation

final class APIClient {
    
    func request<T: Decodable>(_ urlString: String) async throws -> T{
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.serverError(code: httpResponse.statusCode)
        }
        
        if T.self == String.self{
            guard let string = String(data:data, encoding: .utf8) as? T else{
                throw APIError.stringDecodingFailed
            }
            return string
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        }catch{
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
}
