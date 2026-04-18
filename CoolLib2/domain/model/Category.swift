//
//  Category.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/20.
//

struct Category: Identifiable, Sendable {
    internal init(id: Int, name: String, description: String, coverUrl: String? = nil)
    {
        self.id = id
        self.name = name
        self.description = description
        self.coverUrl = coverUrl ?? "\(APIConfig.IMG_CATEGORY)/\(id).webp"
    }

    let id: Int
    let name: String
    let description: String
    let coverUrl: String

}
