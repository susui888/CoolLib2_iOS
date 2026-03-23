//
//  ModelContainerFactory.swift
//  CoolLib2
//
//  Created by susui on 2026/3/23.
//
import SwiftData

enum ModelContainerFactory {
    static func create() -> ModelContainer {
        try! ModelContainer(
            for:
                BookEntity.self,
                CartEntity.self,
        )
    }
}
