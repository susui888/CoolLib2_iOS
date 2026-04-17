//
//  NewestBookRef.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/17.
//

import Foundation
import SwiftData

@Model
final class NewestBookRef{
    @Attribute(.unique) var bookId: Int
    var priority: Int
    
    var book: BookEntity?
    
    internal init(bookId: Int, priority: Int) {
        self.bookId = bookId
        self.priority = priority
    }
}
