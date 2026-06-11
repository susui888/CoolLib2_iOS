//
//  TelemetryDTO.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/6/8.
//

import Foundation

enum TelemetryEventType: String, Codable {
    case screenView = "SCREEN_VIEW"
    case customEvent = "CUSTOM"
    case error = "ERROR"
}

struct TelemetryEventDTO: Codable, Sendable {
    let id: String
    let timestamp: Int64
    let platform: String
    let eventType: TelemetryEventType
    let eventName: String
    let appVersion: String
    let errorMessage: String?
    let attributes: [String: String]?

    init(eventType: TelemetryEventType, eventName: String, errorMessage: String? = nil, attributes: [String: String]? = nil) {
        self.id = UUID().uuidString
        self.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        self.platform = "iOS"
        self.eventType = eventType
        self.eventName = eventName
        self.errorMessage = errorMessage
        self.attributes = attributes
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

struct APIMetricDTO: Codable, Sendable {
    let id: String
    let timestamp: Int64
    let platform: String
    let endpoint: String
    let method: String
    let statusCode: Int
    let latencyMs: Int

    init(endpoint: String, method: String, statusCode: Int, latencyMs: Int) {
        self.id = UUID().uuidString
        self.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        self.platform = "iOS"
        self.endpoint = endpoint
        self.method = method
        self.statusCode = statusCode
        self.latencyMs = latencyMs
    }
}
