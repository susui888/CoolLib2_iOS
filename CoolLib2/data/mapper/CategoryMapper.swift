//
//  CategoryMapper.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/22.
//

extension CategoryDTO {
    func toDomain() -> Category {
        Category(id: id, name: name, description: description)
    }
}

extension CategoryDTO {
    func toEntity() -> CategoryEntity {
        CategoryEntity(id: id, name: name, desc: description)
    }
}

extension CategoryEntity {
    func toDomain() -> Category {
        Category(id: id, name: name, description: desc)
    }
}
