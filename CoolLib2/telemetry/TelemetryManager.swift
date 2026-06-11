//
//  TelemetryManager.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/06/10.
//

import Foundation

final class TelemetryManager: @unchecked Sendable {
    static let shared = TelemetryManager()
    
    // 允许外部直接赋值
    var useCase: TelemetryUseCase?
    
    private init() {}
    
    /// 异步追踪方法
    func track(_ actionName: String, bookId: Int? = nil, attributes: (() -> [String: Any])? = nil) async {
        var finalAttrs: [String: String] = [:]
        
        if let bookId = bookId { finalAttrs["book_id"] = String(bookId) }
        
        if let customAttrs = attributes?() {
            for (key, value) in customAttrs {
                finalAttrs[key] = String(describing: value)
            }
        }
        
        await useCase?.trackCustomAction(actionName: actionName, attributes: finalAttrs.isEmpty ? nil : finalAttrs)
    }
    
    /// 异常监控方法
    func error(_ actionName: String, message: String? = nil) async {
        var finalAttrs: [String: String]? = nil
        if let message = message { finalAttrs = ["error_message": message] }
        await useCase?.trackCustomAction(actionName: actionName, attributes: finalAttrs)
    }
}

// MARK: - Swift Fire-and-Forget Extension
extension TelemetryManager {
    func fire(_ actionName: String, bookId: Int? = nil, attributes: (() -> [String: Any])? = nil) {
        Task(priority: .background) {
            await track(actionName, bookId: bookId, attributes: attributes)
        }
    }
    
    func fireError(_ actionName: String, message: String? = nil) {
        Task(priority: .background) {
            await error(actionName, message: message)
        }
    }
}
