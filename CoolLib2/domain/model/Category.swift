//
//  Category.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//

struct Category: Identifiable, Sendable {
    internal init(id: Int, name: String, description: String, coverUrl: String? = nil)
    {
        self.id = id
        self.name = name
        self.description = description
        //self.coverUrl = coverUrl ?? "\(APIConfig.serverURL)/img/\(id).webp"
        self.coverUrl = coverUrl ?? "https://picsum.photos/240"
    }

    let id: Int
    let name: String
    let description: String
    let coverUrl: String

}
