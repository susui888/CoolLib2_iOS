//
//  APIConfig.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//
import Foundation

enum APIConfig {
    
    //static let serverURL = "http://192.168.2.18:9080"
    static let serverURL = "https://coollib.ryansu.uk"
    
    static let cacheTimeInterval: TimeInterval = 30 * 24 * 60 * 60
    
    private static let IMG_SERVER = "https://img.ryansu.uk"
    
    static let IMG_BOOK_COVER = "\(IMG_SERVER)/bookcover/1"
    
    static let IMG_CATEGORY = "\(IMG_SERVER)/category"
}
