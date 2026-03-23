//
//  CategoryMapper.swift
//  CoolLib2
//
//  Created by susui on 2026/3/22.
//

extension CategoryDTO {
    func toDomain() -> Category {
        Category(id: id, name: name, description: description)
    }
}


