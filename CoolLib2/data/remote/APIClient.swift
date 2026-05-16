//
//  APIClient.swift
//  Containerized Library Ecosystem
//
//  Created by Ryan Su on 2026/3/21.
//

import Alamofire
import Foundation

final class APIClient {
    private let session: Session

    /// Initializes the client with a custom session and an authentication interceptor
    init(sessionManager: SessionManager) {
        let interceptor = AuthInterceptor(sessionManager: sessionManager)
        self.session = Session(interceptor: interceptor)
    }

    /// Performs a PUT request to upload raw data
    /// Typically used for uploading images directly to S3-compatible storage like Cloudflare R2
    func put(
        _ urlString: String,
        method: HTTPMethod = .put,
        data: Data,
        headers: [String: String] = [:]
    ) async throws {

        let httpHeaders = HTTPHeaders(
            headers.map { HTTPHeader(name: $0.key, value: $0.value) }
        )

        let uploadRequest = session.upload(
            data,
            to: urlString,
            method: method,
            headers: httpHeaders
        )
        .validate(statusCode: 200..<300)

        // Handles empty responses (200, 204, 205) which are common for successful PUT operations
        let response = await uploadRequest.serializingData(
            emptyResponseCodes: [200, 204, 205]
        ).response

        switch response.result {
        case .success:
            return
        case .failure(let afError):
            throw afError
        }
    }

    /// Generic request method for GET operations using URL query parameters
    /// Parameters are encoded into the URL string (e.g., ?key=value)
    func request<T: Decodable>(
        _ urlString: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil
    ) async throws -> T {

        let dataRequest = session.request(
            urlString,
            method: method,
            parameters: parameters,
            encoding: URLEncoding.default
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

    /// Generic request method for operations with a JSON request body (POST, PUT, PATCH)
    /// The body is encoded as JSON in the HTTP request body
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

        //        let response =
        //            await dataRequest
        //            .serializingDecodable(T.self, decoder: Self.makeDecoder())
        //            .response

        let response =
            await dataRequest
            .serializingDecodable(
                T.self,
                decoder: Self.makeDecoder(),
                emptyResponseCodes: [200, 204, 205]
            )
            .response

        switch response.result {
        case .success(let value):
            return value
        case .failure(let afError):
            throw afError
        }
    }

    /// Simple GET request convenience method that takes only a URL string
    //    func request<T: Decodable>(_ urlString: String) async throws -> T {
    //        let noBody: String? = nil
    //        return try await request(urlString, method: .get, body: noBody)
    //    }

    func request<T: Decodable>(_ urlString: String) async throws -> T {
        let dataRequest = session.request(urlString, method: .get)
            .validate(statusCode: 200..<300)

        let response =
            await dataRequest
            .serializingDecodable(
                T.self,
                decoder: Self.makeDecoder(),
                emptyResponseCodes: [200, 204, 205]
            )
            .response

        switch response.result {
        case .success(let value): return value
        case .failure(let afError): throw afError
        }
    }

    /// Creates a JSONDecoder configured to handle multiple date string formats
    /// Supports ISO8601 (with and without fractional seconds) and simple YYYY-MM-DD
    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // 1. Try ISO8601 with fractional seconds (e.g., 2026-05-02T22:18:14.123Z)
            // 2. Try standard ISO8601 (e.g., 2026-05-02T22:18:14Z)
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

            // 3. Fallback to simple date format (e.g., 2026-05-02)
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

/// Interceptor that automatically attaches an Authorization header to requests
final class AuthInterceptor: RequestInterceptor {
    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    /// Modifies the URLRequest before it is sent
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest

        // Only inject the Bearer token for internal API calls to prevent credential leaking
        if let url = request.url, let host = url.host,
            host.contains("ryansu.uk")
        {
            if let token = sessionManager.getToken(), !token.isEmpty {
                request.addValue(
                    "Bearer \(token)",
                    forHTTPHeaderField: "Authorization"
                )
            }
        }
        completion(.success(request))
    }
}
