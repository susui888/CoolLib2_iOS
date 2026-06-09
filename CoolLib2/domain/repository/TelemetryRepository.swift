//
//  TelemetryRepository.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/6/9.
//

protocol TelemetryRepository {
    func pipeEvent(type: TelemetryEventType, name: String, errorMessage: String?, attributes: [String: String]?) async throws
    func pipeMetric(endpoint: String, method: String, statusCode: Int, latencyMs: Int) async throws
}
