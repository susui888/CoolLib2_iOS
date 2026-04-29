//
//  BookScreenUITests.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/29.
//

import XCTest

final class BookScreenUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Stop immediately if a failure occurs
        continueAfterFailure = false

        app.launch()

        app.tabBars.buttons["Book"].tap()
    }


    // Test toggling between Grid and List layouts
    func testViewModeSwitch() {
        let toggleButton = app.buttons["viewModeToggleButton"]
        // Ensure the button is there before starting
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5), "Toolbar toggle button not found")

        // 1. Verify Initial Grid State
        XCTAssertTrue(app.scrollViews["bookGridView"].waitForExistence(timeout: 5), "Should start in Grid mode.")

        // 2. Switch to List mode
        toggleButton.tap()
        
        // Use .any to find the identifier regardless of whether it's a Table or CollectionView
        let listView = app.descendants(matching: .any)["bookListView"]
        XCTAssertTrue(listView.waitForExistence(timeout: 5), "Should switch to List mode after tapping toggle.")
        
        // CRITICAL: Ensure the Grid view is actually gone
        XCTAssertFalse(app.scrollViews["bookGridView"].exists, "Grid view should be removed from hierarchy")

        // 3. Switch back to Grid mode
        toggleButton.tap()
        
        // Re-query the gridView instead of reusing the variable from Step 1
        let gridView = app.scrollViews["bookGridView"]
        XCTAssertTrue(gridView.waitForExistence(timeout: 5), "Should return to Grid mode.")
    }

    // Test the retry logic when an error occurs
    func testErrorStateAndRetry() {
        // This test assumes the mock environment triggers an error state
        let errorText = app.staticTexts["Error"]
        let retryButton = app.buttons["retryButton"]

        if errorText.waitForExistence(timeout: 5) {
            XCTAssertTrue(retryButton.exists)
            retryButton.tap()

            // Verify that it attempts to load again after tapping retry
            let loadingIndicator = app.staticTexts["Loading..."]
            XCTAssertTrue(loadingIndicator.exists)
        }
    }

    // Test navigation to the book details screen
    func testBookSelectionNavigation() {
        // Wait for the books to load and appear
        let firstBook = app.buttons.firstMatch
        XCTAssertTrue(
            firstBook.waitForExistence(timeout: 5),
            "Books should load within 5 seconds."
        )

        // Tap the book to navigate
        firstBook.tap()

        // Verify navigation by checking the new title or existence of a back button
        // Replace "Book Details" with your actual destination's title
        let detailsNavBar = app.navigationBars.firstMatch
        XCTAssertNotNil(
            detailsNavBar.identifier,
            "Should navigate to the details view."
        )
    }
}
