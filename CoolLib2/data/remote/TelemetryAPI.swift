//
//  TelemetryAPI.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/6/8.
//

import Foundation
import Alamofire

protocol TelemetryAPI {
    func recordEvent(request: TelemetryEventDTO) async throws -> Empty
    func recordMetric(request: APIMetricDTO) async throws -> Empty
}
