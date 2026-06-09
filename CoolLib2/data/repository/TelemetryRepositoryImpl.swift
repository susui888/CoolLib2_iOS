//
//  TelemetryRepositoryImpl.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/6/9.
//

import Foundation
import Alamofire


final class TelemetryRepositoryImpl: TelemetryRepository {
    private let telemetryApi: TelemetryAPI

    init(telemetryApi: TelemetryAPI) {
        self.telemetryApi = telemetryApi
    }

    func pipeEvent(type: TelemetryEventType, name: String, errorMessage: String?, attributes: [String: String]?) async throws {
        let dto = TelemetryEventDTO(eventType: type, eventName: name, errorMessage: errorMessage, attributes: attributes)
        let _: Empty = try await telemetryApi.recordEvent(request: dto)
    }

    func pipeMetric(endpoint: String, method: String, statusCode: Int, latencyMs: Int) async throws {
        let dto = APIMetricDTO(endpoint: endpoint, method: method, statusCode: statusCode, latencyMs: latencyMs)
        let _: Empty = try await telemetryApi.recordMetric(request: dto)
    }
}
