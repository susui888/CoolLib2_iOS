//
//  APIConfig.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//
import Foundation

enum APIConfig {
    
    static let serverURL = "https://coollib.ryansu.uk"
    
    static let cacheTimeInterval: TimeInterval = 30 * 24 * 60 * 60
    
    private static let IMG_SERVER = "https://img.ryansu.uk"
    
    static let IMG_BOOK_COVER = "\(IMG_SERVER)/bookcover/1"
    
    static let IMG_CATEGORY = "\(IMG_SERVER)/category"
    
    static let IMG_USER = "\(IMG_SERVER)/userimg"
    
    nonisolated static let IMG_REVIEW = "https://review.ryansu.uk"
    
    nonisolated static let teleMetryURL = "https://status.ryansu.uk"
}
