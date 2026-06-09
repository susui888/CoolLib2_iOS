//
//  TelemetryEvents.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/06/08.
//

import Foundation


struct TelemetryEvents {
    
    struct Screens {
        static let home = "HOME_SCREEN"
        static let bookDetail = "BOOK_DETAIL_SCREEN"
        static let login = "LOGIN_SCREEN"
        static let register = "REGISTER_SCREEN"
        static let search = "SEARCH_SCREEN"
        static let book = "BOOK_SCREEN"
        static let cart = "CART_SCREEN"
        static let review = "REVIEW_SCREEN"
        static let scan = "SCANNER_SCREEN"
        static let about = "ABOUT_SCREEN"
        static let statics = "STATICS_SCREEN"
        static let loan = "LOAN_SCREEN"
    }
    

    struct Actions {
        static let loginSuccess = "AUTH_LOGIN_SUCCESS"
        static let addToWishlist = "BOOK_ADD_WISHLIST"
        static let removeFromWishlist = "BOOK_REMOVE_WISHLIST"
        static let rentBook = "BOOK_RENT_ACTION"
    }
}
