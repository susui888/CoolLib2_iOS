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
        static let scanner = "SCANNER_SCREEN"
        static let about = "ABOUT_SCREEN"
        static let statics = "STATICS_SCREEN"
        static let loan = "LOAN_SCREEN"
    }
    
    struct Actions {
        // (Cart Actions)
        static let bookAddCart = "BOOK_ADD_CART"
        static let bookRemoveCart = "BOOK_REMOVE_CART"
        
        // (Wishlist Actions)
        static let bookAddWishlist = "BOOK_ADD_WISHLIST"
        static let bookRemoveWishlist = "BOOK_REMOVE_WISHLIST"
        
        // (Core Business Actions)
        static let bookRentAction = "BOOK_RENT_ACTION"
        static let authLoginSuccess = "AUTH_LOGIN_SUCCESS"
        static let bookSearch = "BOOK_SEARCH"
        static let bookPostReviewSuccess = "BOOK_POST_REVIEW_SUCCESS"
        static let bookDeleteReviewSuccess = "BOOK_DELETE_REVIEW_SUCCESS"
        
        // (Load State Actions)
        static let homeDataLoadSuccess = "HOME_DATA_LOAD_SUCCESS"
        
        // (Failure Tracks)
        static let homeDataLoadFailure = "HOME_DATA_LOAD_FAILURE"
        static let borrowActionFailure = "BORROW_ACTION_FAILURE"
        static let wishlistActionFailure = "WISHLIST_ACTION_FAILURE"
        static let bookDetailLoadFailure = "BOOK_DETAIL_LOAD_FAILURE"
    }
}
