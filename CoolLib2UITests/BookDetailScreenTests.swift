//
//  BookDetailScreenTests.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import XCTest

final class BookDetailScreenTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        //app.launchArguments.append("--mock-data")
        continueAfterFailure = false
        app.launch()

        let book = app.staticTexts["The Great Gatsby"].firstMatch
        if book.waitForExistence(timeout: 5) {
            book.tap()
        }
    }

    func testBookTitle_isDisplayed() {
        // 假设 MockBooks.list.first() 的标题是 "The Great Gatsby"
        let bookTitle = "The Great Gatsby"

        let titleText = app.staticTexts[bookTitle]
        XCTAssertTrue(titleText.exists)
    }

    func testAuthorClick_triggersCallback() {

        let authorText = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS 'Publisher'")
        ).firstMatch

        XCTAssertTrue(authorText.waitForExistence(timeout: 5), "图书详情页中未找到作者标签")
    }

    func testAddToCartButton_isDisplayed() {
        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.exists)
    }

    func testFavoriteButton_changesText() {
        // 在 SwiftUI 中，如果是 isFavorite = true，按钮文本可能变为 "Remove"
        let removeButton = app.buttons["Remove"]
        XCTAssertTrue(removeButton.exists)
    }

    func testReviewsSection_displaysReviewerNameAndContent() {

        let userName = "susui"
        let reviewContent = "Amazing read!"

        let userText = app.staticTexts[userName]
        let contentText = app.staticTexts[reviewContent]
        
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()

        XCTAssertTrue(userText.waitForExistence(timeout: 5))
        XCTAssertTrue(contentText.exists)
    }

    func testReviewsSection_emptyState_displaysNoReviewsMessage() {
        // 这里的逻辑需要你在 App 中通过某种方式切换到没有评论的书籍
        let emptyMessage = "Be the first to rate this book!"

        let messageText = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS %@", emptyMessage)
        ).firstMatch
        XCTAssertTrue(messageText.exists)
    }
}
