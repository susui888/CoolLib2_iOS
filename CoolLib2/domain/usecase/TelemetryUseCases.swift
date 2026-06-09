//
//  TelemetryUseCase.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/06/08.
//

import Foundation

final class TelemetryUseCase {
    private let telemetryRepository: TelemetryRepository

    init(telemetryRepository: TelemetryRepository) {
        self.telemetryRepository = telemetryRepository
    }

    func trackScreenView(screenName: String, referrer: String? = nil) async {
        var attrs: [String: String] = [:]
        if let referrer = referrer { attrs["referrer_source"] = referrer }
        
        try? await telemetryRepository.pipeEvent(
            type: .screenView,
            name: screenName,
            errorMessage: nil,
            attributes: attrs
        )
    }

    func trackCustomAction(actionName: String, attributes: [String: String]? = nil) async {
        try? await telemetryRepository.pipeEvent(
            type: .customEvent,
            name: actionName,
            errorMessage: nil,
            attributes: attributes
        )
    }
}
