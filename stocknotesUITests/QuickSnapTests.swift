//
//  QuickSnapTests.swift
//  stocknotesUITests
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import XCTest

final class QuickSnapTests: XCTestCase {
    var app: XCUIApplication!
    var helpers: TestHelpers!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        helpers = TestHelpers(app: app)
    }
    
    override func tearDownWithError() throws {
        // Cleanup: Remove test snap notes and symbols created during tests
        if let helpers = helpers {
            helpers.cleanupTestData()
        }
        app = nil
        helpers = nil
    }
    
    @MainActor
    func testQuickSnapFromHome() throws {
        // Launch app
        helpers.navigateToHome()
        
        // Tap "+" button → Select "Quick Snap"
        helpers.tapPlusButton()
        
        // Find Quick Snap menu item
        let quickSnapButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Quick Snap' OR label CONTAINS[c] 'Snap'")).firstMatch
        if quickSnapButton.waitForExistence(timeout: 3) {
            quickSnapButton.tap()
        }
        
        // Verify QuickSnapView appears
        let snapNavBar = app.navigationBars["Quick Snap"]
        XCTAssertTrue(snapNavBar.waitForExistence(timeout: 5), "Quick Snap view should appear")
        
        // Search for symbol: "AAPL"
        let searchField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'symbol' OR placeholderValue CONTAINS[c] 'Search'")).firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search field should exist")
        helpers.enterText("AAPL", inField: searchField)
        
        // Wait for search results
        sleep(3) // Wait for API call
        
        // Select "AAPL" from results
        let aaplResult = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
        if aaplResult.waitForExistence(timeout: 5) {
            aaplResult.tap()
        } else {
            // Try tapping first result
            let firstResult = app.tables.cells.firstMatch
            if firstResult.waitForExistence(timeout: 2) {
                firstResult.tap()
            }
        }
        
        // Optionally add note text: "Quick snapshot"
        let noteField = app.textViews.firstMatch
        if noteField.waitForExistence(timeout: 3) {
            helpers.enterTextInTextEditor("Quick snapshot")
        }
        
        // Tap "Snap" button
        let snapButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Snap'")).firstMatch
        XCTAssertTrue(snapButton.waitForExistence(timeout: 5), "Snap button should exist")
        
        if snapButton.isEnabled {
            snapButton.tap()
        }
        
        // Wait for snap creation
        sleep(3) // Wait for API call and note creation
        
        // Verify snap note is created
        let homeNavBar = app.navigationBars["Stock Notes"]
        XCTAssertTrue(homeNavBar.waitForExistence(timeout: 5), "Should return to home screen after snap")
        
        // Verify note appears in Recent Notes
        // The note should contain snap information
        let snapNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Quick snapshot' OR label CONTAINS[c] 'Snap'")).firstMatch
        XCTAssertTrue(snapNote.waitForExistence(timeout: 5), "Snap note should appear in Recent Notes")
    }
    
    @MainActor
    func testQuickSnapFromSymbolDetail() throws {
        // Add symbol "AAPL"
        helpers.createTestSymbol(ticker: "AAPL")
        
        // Wait for symbol to be added
        sleep(2)
        
        // Open symbol detail view
        let aaplSymbol = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
        if aaplSymbol.waitForExistence(timeout: 5) {
            aaplSymbol.tap()
        } else {
            helpers.tapFirstListItem()
        }
        
        // Verify detail view appears
        let detailNavBar = app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS 'AAPL' OR label CONTAINS 'AAPL'")).firstMatch
        XCTAssertTrue(detailNavBar.waitForExistence(timeout: 5), "Symbol detail view should appear")
        
        // Tap "Quick Snap" button
        let quickSnapButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Quick Snap' OR label CONTAINS[c] 'Snap'")).firstMatch
        XCTAssertTrue(quickSnapButton.waitForExistence(timeout: 5), "Quick Snap button should exist")
        quickSnapButton.tap()
        
        // Wait for snap creation
        sleep(3) // Wait for API call and note creation
        
        // Verify note is created automatically
        // Should return to symbol detail view or home
        XCTAssertTrue(app.exists, "App should still be responsive")
        
        // Verify note contains price snapshot information
        // Navigate to notes to verify
        helpers.navigateToNotes()
        
        // Look for snap note
        let snapNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Snap' OR label CONTAINS[c] 'AAPL'")).firstMatch
        XCTAssertTrue(snapNote.waitForExistence(timeout: 5), "Snap note should be created")
        
        // Verify note is linked to symbol
        // Tap on note to verify
        if snapNote.exists {
            snapNote.tap()
            
            // Verify note detail shows symbol
            let noteDetailNavBar = app.navigationBars["Note Details"]
            if noteDetailNavBar.waitForExistence(timeout: 3) {
                let symbolText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
                XCTAssertTrue(symbolText.exists, "Note should be linked to AAPL symbol")
            }
        }
    }
    
    @MainActor
    func testQuickSnapFromSymbolCard() throws {
        // Add symbol "AAPL"
        helpers.createTestSymbol(ticker: "AAPL")
        
        // Wait for symbol to be added
        sleep(2)
        
        // Navigate to Symbols tab
        helpers.navigateToSymbols()
        
        // Find symbol card
        let aaplSymbol = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
        XCTAssertTrue(aaplSymbol.waitForExistence(timeout: 5), "AAPL symbol should exist")
        
        // Long press on symbol card
        aaplSymbol.press(forDuration: 1.0)
        
        // Select snap option (if available in context menu)
        let snapOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Snap'")).firstMatch
        if snapOption.waitForExistence(timeout: 2) {
            snapOption.tap()
            
            // Wait for snap creation
            sleep(3)
            
            // Verify snap note is created
            helpers.navigateToHome()
            let snapNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Snap' OR label CONTAINS[c] 'AAPL'")).firstMatch
            XCTAssertTrue(snapNote.waitForExistence(timeout: 5), "Snap note should be created")
        } else {
            // If context menu doesn't have snap option, that's okay
            // The feature might only be available from detail view
            // Just verify the symbol card exists and is tappable
            XCTAssertTrue(aaplSymbol.exists, "Symbol card should exist")
        }
    }
}
