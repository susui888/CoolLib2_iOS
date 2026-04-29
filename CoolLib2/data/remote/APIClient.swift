//
//  APIClient.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/21.
//

import Alamofire
import Foundation

final class APIClient {
    private let session: Session

    init(sessionManager: SessionManager) {
        let interceptor = AuthInterceptor(sessionManager: sessionManager)
        self.session = Session(interceptor: interceptor)
    }

    func request<T: Decodable, B: Encodable>(
        _ urlString: String,
        method: HTTPMethod = .get,
        body: B? = nil
    ) async throws -> T {

        let dataRequest = session.request(
            urlString,
            method: method,
            parameters: body,
            encoder: JSONParameterEncoder.default
        )
        .validate(statusCode: 200..<300)

        let response =
            await dataRequest
            .serializingDecodable(T.self, decoder: Self.makeDecoder())
            .response

        switch response.result {
        case .success(let value):
            return value
        case .failure(let afError):
            throw afError
        }
    }

    func request<T: Decodable>(_ urlString: String) async throws -> T {
        let noBody: String? = nil
        return try await request(urlString, method: .get, body: noBody)
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let isoFormatter = ISO8601DateFormatter()
            let formats: [ISO8601DateFormatter.Options] = [
                [.withInternetDateTime, .withFractionalSeconds],
                [.withInternetDateTime],
            ]

            for options in formats {
                isoFormatter.formatOptions = options
                if let date = isoFormatter.date(from: dateString) {
                    return date
                }
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = dateFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to parse date format: \(dateString)"
            )
        }

        return decoder
    }

}

final class AuthInterceptor: RequestInterceptor {
    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        if let token = sessionManager.getToken(), !token.isEmpty {
            request.addValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }
        completion(.success(request))
    }
}
