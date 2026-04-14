//
//  KFImage.swift
//  CoolLib2
//
//  Created by susui on 2026/4/14.
//

import SwiftUI
import Kingfisher


extension KFImage {
    func standardStyle(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 0) -> some View {
        self.placeholder { Color.gray.opacity(0.2) }
            .retry(maxCount: 3, interval: .seconds(5))
            .cacheMemoryOnly(false)
            .fade(duration: 0.25)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(cornerRadius)
    }
}

extension CoolLib2App {
    func setupKingfisherCache() {
        let cache = ImageCache.default
        
        // Configure disk cache policy
        // .never means the cache will never expire unless manually cleared (strongest caching)
        cache.diskStorage.config.expiration = .never
        
        // Set maximum disk cache size (e.g., 1GB)
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 1024
        
        // Set memory cache expiration time (e.g., 10 minutes)
        cache.memoryStorage.config.expiration = .seconds(600)
    }
}
