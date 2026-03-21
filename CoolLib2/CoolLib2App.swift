//
//  CoolLib2App.swift
//  CoolLib2
//
//  Created by susui on 2026/3/18.
//

import SwiftUI

@main
struct CoolLib2App: App {
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(router)
        }
    }
}
