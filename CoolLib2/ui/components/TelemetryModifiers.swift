//
//  TelemetryModifiers.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/06/08.
//

import SwiftUI

/// ==================================================================================
/// 🎯 声明式埋点组件 (Declarative Tracking Component)
/// ==================================================================================
/// 核心目的：让 SwiftUI 视图能够无感、干净地触发页面浏览(Screen View)生命周期拦截，
///          且绝对不污染、不打乱 UI 业务视图本身的 body 布局逻辑。
///
struct TrackScreenModifier: ViewModifier {
    let screenName: String
    let attributes: [String: String]?
    
    /// 严格遵循 Clean Architecture 规范，UI 层不直接接触底层 Remote/Network，
    /// 而是通过注入的 Domain 层 UseCase 发送业务意图命令。
    let useCase: TelemetryUseCase

    func body(content: Content) -> some View {
        content.onAppear {
            /// 1. 拦截原生声明式 UI 生命周期：当视图渲染完成并正式挂载到屏幕上时，触发曝光点。
            /// 2. 必须开启 `Task(priority: .background)`：由于埋点和指标上报属于网络 I/O 动作，
            ///    将其显式派发至后台低优先级协同线程处理。无论埋点服务器响应多慢，
            ///    都绝对不会阻塞主线程(Main Thread)，UI 交互和动画依旧保持满帧和丝滑。
            Task(priority: .background) {
                await useCase.trackScreenView(
                    screenName: screenName,
                    referrer: attributes?["referrer_source"]
                )
            }
        }
    }
}

extension View {
    /// 对外暴露的极简 SwiftUI 链式调用语法糖
    ///
    /// 消除原生 `.modifier(TrackScreenModifier(...))` 造成的代码膨胀，
    /// 使得埋点调用能够像系统原生的 `.padding()` 或 `.background()` 一样，直接挂载在业务组件下方。
    ///
    /// 示例写法：
    /// ```swift
    /// struct BookListView: View {
    ///     var body: some View {
    ///         VStack { ... }
    ///         .trackScreen(name: "BookListView", with: container.telemetryUseCase)
    ///     }
    /// }
    /// ```
    func trackScreen(name: String, with useCase: TelemetryUseCase, attributes: [String: String]? = nil) -> some View {
        self.modifier(TrackScreenModifier(screenName: name, attributes: attributes, useCase: useCase))
    }
}
