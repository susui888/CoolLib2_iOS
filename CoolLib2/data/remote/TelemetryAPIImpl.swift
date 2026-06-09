//
//  TelemetryAPIImpl.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/6/8.
//

import Alamofire
import Foundation

final class TelemetryAPIImpl: TelemetryAPI {
    private let client: APIClient
    private let basePath = "\(APIConfig.teleMetryURL)/api/mobile-telemetry"

    /// ==================================================================================
    /// 🌟 核心设计：解耦双向循环依赖 & 绕过并发安全严格检查
    /// ==================================================================================
    ///
    /// 1. 为什么要用 `static var` (解决循环依赖)？
    ///    在洁净架构中，依赖关系垂直向下：AppContainer -> UseCase -> Repository -> API -> APIClient。
    ///    当我们需要 APIClient 在每次执行网络请求后自动上报耗时，就产生了双向依赖死锁：
    ///    - APIClient 的初始化需要注入 TelemetryAPI（为了上报性能指标）。
    ///    - TelemetryAPIImpl 的初始化必须注入 APIClient（为了利用 Alamofire 发送 POST 请求）。
    ///
    ///    通过在此处声明一个静态通道槽，APIClient 初始化时不再需要构造器注入遥测，
    ///    只需在每次请求结束时读取该静态槽即可。从而将强耦合链条切断为松耦合的广播通知机制。
    ///
    /// 2. 为什么要加 `nonisolated(unsafe)` (解决严格并发检查警告)？
    ///    AppContainer 被标记为 @MainActor（隔离在主线程），而 APIClient 处于 Swift Concurrency
    ///    的后台协同线程池。Swift 6 严禁在多线程之间直接读写无隔离的全局可变变量，否则报编译错误。
    ///    `nonisolated(unsafe)` 是开发者向编译器的最高信任担保：
    ///    - `nonisolated` 声明该变量不属于任何 actor，允许异构线程和后台闭包自由访问。
    ///    - `(unsafe)` 保证该变量仅在 AppContainer 初始化时被写入一次（赋值自身），
    ///      在线上运行时，所有后台线程对它只有“只读(Read-Only)”操作，绝无并行写冲突。
    ///
    nonisolated(unsafe) static var globalDispatcher: TelemetryAPI?

    init(client: APIClient) {
        self.client = client
        TelemetryAPIImpl.globalDispatcher = self
    }

    func recordEvent(request: TelemetryEventDTO) async throws -> Empty {
        let urlString = "\(basePath)/events"
        return try await client.request(urlString, method: .post, body: request)
    }

    func recordMetric(request: APIMetricDTO) async throws -> Empty {
        let urlString = "\(basePath)/metrics"
        return try await client.request(urlString, method: .post, body: request)
    }
}
