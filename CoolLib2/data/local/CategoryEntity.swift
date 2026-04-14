//
//  CategoryEntity.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/14.
//

import Foundation
import SwiftData

@Model
final class CategoryEntity{
    @Attribute(.unique)
    var id: Int
    
    var name: String
    var desc: String
    
    var createdAt: Date
    var updatedAt: Date
    
    internal init(
        id: Int,
        name: String,
        desc: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
    ) {
        self.id = id
        self.name = name
        self.desc = desc
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
