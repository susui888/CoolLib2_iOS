//
//  CoolLib2App.swift
//  CoolLib2
//
//  Created by susui on 2026/3/18.
//

import SwiftUI

@main
struct CoolLib2App: App {
    @StateObject private var router: AppRouter
    private let container: AppContainer 

    init() {
        let newContainer = AppContainer()
        self.container = newContainer
        self._router = StateObject(wrappedValue: AppRouter(container: newContainer))
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(router)
                .environmentObject(container)
        }
    }
}
