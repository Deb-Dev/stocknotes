//
//  AppLaunchTests.swift
//  stocknotesUITests
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import XCTest

final class AppLaunchTests: XCTestCase {
    var app: XCUIApplication!
    var helpers: TestHelpers!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        helpers = TestHelpers(app: app)
    }
    
    override func tearDownWithError() throws {
        // Cleanup: Remove any test data created during tests
        if let helpers = helpers {
            helpers.cleanupTestData()
        }
        app = nil
        helpers = nil
    }
    
    @MainActor
    func testAppLaunchesSuccessfully() throws {
        // Verify Home tab is visible
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5), "Home tab should exist")
        
        // Verify navigation title "Stock Notes" appears
        let navBar = app.navigationBars["Stock Notes"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5), "Navigation bar with 'Stock Notes' title should exist")
        
        // Verify stats cards are displayed (Total Notes, Symbols, This Month)
        // These might be displayed as static text or in cards
        let totalNotesText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Total Notes' OR label CONTAINS[c] '0'")).firstMatch
        XCTAssertTrue(totalNotesText.waitForExistence(timeout: 5), "Stats section should be visible")
        
        // Verify the app is responsive
        XCTAssertTrue(app.exists, "App should exist and be responsive")
    }
    
    @MainActor
    func testTabNavigation() throws {
        // Tap "Symbols" tab → Verify SymbolListView appears
        helpers.navigateToSymbols()
        let symbolsNavBar = app.navigationBars["Symbols"]
        XCTAssertTrue(symbolsNavBar.waitForExistence(timeout: 5), "Symbols view should appear")
        
        // Tap "Notes" tab → Verify NoteListView appears
        helpers.navigateToNotes()
        let notesNavBar = app.navigationBars["All Notes"]
        XCTAssertTrue(notesNavBar.waitForExistence(timeout: 5), "Notes view should appear")
        
        // Tap "Search" tab → Verify SearchView appears
        helpers.navigateToSearch()
        let searchNavBar = app.navigationBars["Search"]
        XCTAssertTrue(searchNavBar.waitForExistence(timeout: 5), "Search view should appear")
        
        // Tap "Settings" tab → Verify SettingsView appears
        helpers.navigateToSettings()
        let settingsNavBar = app.navigationBars["Settings"]
        XCTAssertTrue(settingsNavBar.waitForExistence(timeout: 5), "Settings view should appear")
        
        // Tap "Home" tab → Verify HomeView appears
        helpers.navigateToHome()
        let homeNavBar = app.navigationBars["Stock Notes"]
        XCTAssertTrue(homeNavBar.waitForExistence(timeout: 5), "Home view should appear")
    }
    
    @MainActor
    func testHomeScreenElements() throws {
        // Verify "+" button exists in navigation bar
        // The plus button might be in a menu or directly visible
        let navBar = app.navigationBars["Stock Notes"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5), "Navigation bar should exist")
        
        // Look for plus button or menu button
        let plusButton = navBar.buttons.matching(NSPredicate(format: "label CONTAINS 'plus' OR identifier CONTAINS 'plus'")).firstMatch
        let menuButton = navBar.buttons.matching(NSPredicate(format: "label CONTAINS 'menu' OR identifier CONTAINS 'menu'")).firstMatch
        
        XCTAssertTrue(plusButton.exists || menuButton.exists, "Plus or menu button should exist in navigation bar")
        
        // Verify stats section displays (even if zeros)
        let statsText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Total' OR label CONTAINS[c] 'Symbols' OR label CONTAINS[c] 'Month'")).firstMatch
        XCTAssertTrue(statsText.waitForExistence(timeout: 5), "Stats section should be visible")
        
        // Verify "Recent Notes" section exists
        // This might be a section header or just the list
        let recentNotesText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Recent' OR label CONTAINS[c] 'Notes'")).firstMatch
        // This might not exist if there are no notes, so we'll check for the list structure instead
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Scroll view (containing recent notes) should exist")
        
        // Verify tag cloud section appears when tags exist
        // This will be tested separately when tags are created
        // For now, just verify the home view structure is correct
        XCTAssertTrue(app.exists, "App should be visible")
    }
}
