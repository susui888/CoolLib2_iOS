//
//  UserDTO.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/31.
//

struct UserDTO: Codable, Sendable {
    let username: String
    let password: String
    var email: String = ""
}

