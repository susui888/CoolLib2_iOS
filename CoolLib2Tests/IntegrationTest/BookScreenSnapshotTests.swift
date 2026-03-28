//
//  BookScreenSnapshotTests.swift
//  CoolLib2Tests
//
//  Created by susui on 2026/03/27.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import CoolLib2

final class BookScreenSnapshotTests: XCTestCase {
    // NOTE: The first run will always fail to record the initial snapshot.
    // Subsequent runs will compare against the images in the __Snapshots__ folder.
    
    
    // Define a consistent device configuration to ensure same pixel density across machines
    let config = ViewImageConfig.iPhone13Pro
    
    // Test the success state with grid layout
    func test_bookScreen_success_grid() {
        let view = NavigationStack {
            BookScreenContent(
                state: .success(MockBooks.list),
                onRetryTap: {},
                onBookTap: { _ in }
            )
        }

        // Wrap the image strategy with a 2.0s mandatory wait
        // This is different from 'timeout' because it FORCES the pause
        assertSnapshot(
            of: view,
            as: .wait(for: 2.0, on: .image(layout: .device(config: .iPhone13Pro)))
        )
    }
    
    // Test the loading state
    func test_bookScreen_loading() {
        let view = NavigationStack {
            BookScreenContent(
                state: .loading,
                onRetryTap: {},
                onBookTap: { _ in }
            )
        }
        
        assertSnapshot(of: view, as: .image(layout: .device(config: config)))
    }
    
    // Test the error state with a long message to check for text wrapping
    func test_bookScreen_error() {
        let view = NavigationStack {
            BookScreenContent(
                state: .error("The server is currently undergoing maintenance. Please try again in 5 minutes."),
                onRetryTap: {},
                onBookTap: { _ in }
            )
        }
        
        assertSnapshot(of: view, as: .image(layout: .device(config: config)))
    }
    
    // Test the empty state (success with no books)
    func test_bookScreen_empty() {
        let view = NavigationStack {
            BookScreenContent(
                state: .success([]),
                onRetryTap: {},
                onBookTap: { _ in }
            )
        }
        
        assertSnapshot(of: view, as: .image(layout: .device(config: config)))
    }
}
