//
//  CoolLib2App.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/18.
//

import SwiftUI
import SwiftData
import Kingfisher

@main
struct CoolLib2App: App {
    
    @StateObject private var container: AppContainer
    @StateObject private var router: AppRouter
    
    private let modelContainer: ModelContainer

    init() {
        let mc = ModelContainerFactory.create()
        self.modelContainer = mc
        

        let appContainer = AppContainer(modelContext: mc.mainContext)
        self._container = StateObject(wrappedValue: appContainer)

        self._router = StateObject(wrappedValue: AppRouter(container: appContainer))
        
        setupKingfisherCache()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(container: container, router: router)
                .environmentObject(router)
                .environmentObject(container)
                .modelContainer(modelContainer)
        }
    }
}
