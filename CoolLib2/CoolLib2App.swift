//
//  CoolLib2App.swift
//  CoolLib2
//
//  Created by susui on 2026/3/18.
//

import SwiftUI
import SwiftData

@main
struct CoolLib2App: App {
    
    @StateObject private var container: AppContainer
    @StateObject private var router: AppRouter
    
    private let modelContainer: ModelContainer

    init() {
        // 1. 初始化持久化层
        let mc = ModelContainerFactory.create()
        self.modelContainer = mc
        
        // 2. 初始化依赖注入容器
        let appContainer = AppContainer(modelContext: mc.mainContext)
        self._container = StateObject(wrappedValue: appContainer)
        
        // 3. 将容器注入路由系统
        self._router = StateObject(wrappedValue: AppRouter(container: appContainer))
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(container: container)
                .environmentObject(router)
                .environmentObject(container)
                // 如果你使用了 SwiftData，别忘了注入 modelContainer
                .modelContainer(modelContainer)
        }
    }
}
