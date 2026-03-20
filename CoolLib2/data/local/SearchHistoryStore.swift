//
//  SearchHistoryStore.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//

import Foundation

struct SearchHistoryStore {
    private static let key = "search_history"
    private static let limit = 20

    static func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
    
    static func save(_ history: [String]) {
        UserDefaults.standard.set(history, forKey: key)
    }
    
    static func add(_ keyword: String) {
        guard !keyword.isEmpty else { return }
        
        var history = load()
        
        history.removeAll() { $0 == keyword }
        history.insert(keyword, at: 0)
        
        history = Array(history.prefix(limit))
        
        save(history)
    }
    
    static func remove(_ keyword: String) {
        var history = load()
        history.removeAll { $0 == keyword }
        save(history)
    }
    
    static func clear() {
        save([])
    }
}
