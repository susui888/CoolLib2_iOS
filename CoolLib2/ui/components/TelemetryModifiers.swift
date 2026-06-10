//
//  TelemetryModifiers.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/06/08.
//

import SwiftUI

struct TrackScreenModifier: ViewModifier {
    let screenName: String
    let attributes: [String: String]?
    
    @EnvironmentObject private var container: AppContainer

    func body(content: Content) -> some View {
        content
            // 使用系统原生非阻塞异步 Task，并绑定 screenName 的唯一性
            .task(id: screenName, priority: .background) {
                
                let useCase = container.telemetryUseCase
                await useCase.trackScreenView(
                    screenName: screenName,
                    referrer: attributes?["referrer_source"]
                )
            }
    }
}

extension View {
    func trackScreen(name: String, attributes: [String: String]? = nil) -> some View {
        self.modifier(TrackScreenModifier(screenName: name, attributes: attributes))
    }
}
