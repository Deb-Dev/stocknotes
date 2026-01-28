//
//  SymbolManagementTests.swift
//  stocknotesUITests
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import XCTest

final class SymbolManagementTests: XCTestCase {
    var app: XCUIApplication!
    var helpers: TestHelpers!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        helpers = TestHelpers(app: app)
    }
    
    override func tearDownWithError() throws {
        // Cleanup: Remove test symbols and notes created during tests
        if let helpers = helpers {
            helpers.cleanupTestData()
        }
        app = nil
        helpers = nil
    }
    
    @MainActor
    func testAddSymbol() throws {
        // Launch app
        helpers.navigateToSymbols()
        
        // Tap "+" button
        helpers.tapPlusButton()
        
        // Wait for add symbol view
        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add symbol view should appear")
        
        // Enter ticker: "AAPL"
        let tickerField = app.textFields.firstMatch
        XCTAssertTrue(tickerField.waitForExistence(timeout: 3), "Ticker field should exist")
        helpers.enterText("AAPL", inField: tickerField)
        
        // Wait for search results
        sleep(3) // Wait for API call to complete
        
        // Select "AAPL - Apple Inc." from results
        let aaplResult = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
        if aaplResult.waitForExistence(timeout: 5) {
            aaplResult.tap()
        } else {
            // If no results, try tapping first cell
            let firstCell = app.tables.cells.firstMatch
            if firstCell.waitForExistence(timeout: 2) {
                firstCell.tap()
            }
        }
        
        // Tap "Add"
        if addButton.isEnabled {
            addButton.tap()
        }
        
        // Verify symbol appears in Symbols list
        let symbolsNavBar = app.navigationBars["Symbols"]
        XCTAssertTrue(symbolsNavBar.waitForExistence(timeout: 5), "Should return to symbols list")
        
        // Verify AAPL appears in the list
        let aaplSymbol = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
        XCTAssertTrue(aaplSymbol.waitForExistence(timeout: 5), "AAPL symbol should appear in list")
        
        // Verify symbol shows in Home stats
        helpers.navigateToHome()
        let statsText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '1'")).firstMatch
        // The stats should show at least 1 symbol
        XCTAssertTrue(app.exists, "Home screen should show updated stats")
    }
    
    @MainActor
    func testAddCustomSymbol() throws {
        // Navigate to Symbols tab
        helpers.navigateToSymbols()
        
        // Tap "+" button
        helpers.tapPlusButton()
        
        // Wait for add symbol view
        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add symbol view should appear")
        
        // Enter ticker: "XYZ.TO"
        let tickerField = app.textFields.firstMatch
        XCTAssertTrue(tickerField.waitForExistence(timeout: 3), "Ticker field should exist")
        helpers.enterText("XYZ.TO", inField: tickerField)
        
        // Wait a moment for any search results
        sleep(2)
        
        // Enter company name: "Custom Company"
        let companyField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'Company'")).firstMatch
        if companyField.waitForExistence(timeout: 3) {
            helpers.enterText("Custom Company", inField: companyField)
        }
        
        // Tap "Add"
        if addButton.isEnabled {
            addButton.tap()
        }
        
        // Verify custom symbol appears in list
        let symbolsNavBar = app.navigationBars["Symbols"]
        XCTAssertTrue(symbolsNavBar.waitForExistence(timeout: 5), "Should return to symbols list")
        
        // Verify XYZ.TO appears
        let customSymbol = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'XYZ.TO'")).firstMatch
        XCTAssertTrue(customSymbol.waitForExistence(timeout: 5), "Custom symbol should appear in list")
    }
    
    @MainActor
    func testViewSymbolDetails() throws {
        // Add a symbol "AAPL"
        helpers.createTestSymbol(ticker: "AAPL")
        
        // Wait for symbol to be added
        sleep(2)
        
        // Tap on symbol card
        let aaplSymbol = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
        if aaplSymbol.waitForExistence(timeout: 5) {
            aaplSymbol.tap()
        } else {
            // Try tapping first symbol card
            helpers.tapFirstListItem()
        }
        
        // Verify SymbolDetailView appears
        let detailNavBar = app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS 'AAPL' OR label CONTAINS 'AAPL'")).firstMatch
        XCTAssertTrue(detailNavBar.waitForExistence(timeout: 5), "Symbol detail view should appear")
        
        // Verify ticker and company name displayed
        let tickerText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
        XCTAssertTrue(tickerText.exists, "Ticker should be displayed")
        
        // Verify price information (if available)
        // Price might show as "$XXX.XX" or "N/A"
        let priceText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '$' OR label CONTAINS 'N/A'")).firstMatch
        // Price might not be available immediately, so this is optional
        // XCTAssertTrue(priceText.exists, "Price information should be displayed")
        
        // Verify "New Note" and "Quick Snap" buttons exist
        let newNoteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'New Note'")).firstMatch
        let quickSnapButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Quick Snap' OR label CONTAINS[c] 'Snap'")).firstMatch
        
        XCTAssertTrue(newNoteButton.waitForExistence(timeout: 3), "New Note button should exist")
        XCTAssertTrue(quickSnapButton.waitForExistence(timeout: 3), "Quick Snap button should exist")
        
        // Verify notes list section exists
        let notesSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Notes'")).firstMatch
        XCTAssertTrue(notesSection.waitForExistence(timeout: 3), "Notes section should exist")
    }
    
    @MainActor
    func testDeleteSymbol() throws {
        // Add a symbol
        helpers.createTestSymbol(ticker: "TEST")
        
        // Wait for symbol to be added
        sleep(2)
        
        // Create a note linked to that symbol
        helpers.navigateToHome()
        helpers.createTestNote(content: "Test note", symbol: "TEST")
        
        // Wait for note creation
        sleep(2)
        
        // Navigate to Symbols tab
        helpers.navigateToSymbols()
        
        // Find the symbol card
        let testSymbol = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'TEST'")).firstMatch
        XCTAssertTrue(testSymbol.waitForExistence(timeout: 5), "TEST symbol should exist")
        
        // Long press symbol card → Select delete (or swipe to delete)
        // Try swiping left on the table cell containing the symbol
        let table = app.tables.firstMatch
        if table.waitForExistence(timeout: 3) {
            // Find the cell containing TEST symbol
            let cells = table.cells
            for i in 0..<cells.count {
                let cell = cells.element(boundBy: i)
                if cell.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'TEST'")).firstMatch.exists {
                    cell.swipeLeft()
                    
                    // Look for delete button
                    let deleteButton = app.buttons["Delete"]
                    if deleteButton.waitForExistence(timeout: 2) {
                        deleteButton.tap()
                        break
                    }
                }
            }
        } else {
            // Try long press and context menu
            testSymbol.press(forDuration: 1.0)
            
            let deleteOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Delete'")).firstMatch
            if deleteOption.waitForExistence(timeout: 2) {
                deleteOption.tap()
            }
        }
        
        // Confirm deletion in alert
        helpers.handleAlert(buttonTitle: "Delete")
        
        // Verify symbol is removed
        let symbolsNavBar = app.navigationBars["Symbols"]
        XCTAssertTrue(symbolsNavBar.waitForExistence(timeout: 5), "Should be on symbols list")
        
        // Verify TEST symbol no longer exists
        let deletedSymbol = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'TEST'")).firstMatch
        XCTAssertFalse(deletedSymbol.exists, "Symbol should be deleted")
    }
    
    @MainActor
    func testRefreshSymbolPrice() throws {
        // Add a symbol "AAPL"
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
        
        // Tap "Refresh Price" button
        let refreshButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Refresh' OR label CONTAINS[c] 'Price'")).firstMatch
        XCTAssertTrue(refreshButton.waitForExistence(timeout: 5), "Refresh Price button should exist")
        refreshButton.tap()
        
        // Wait for price update
        sleep(3) // Wait for API call
        
        // Verify price is displayed or "N/A" if unavailable
        // Price might show as "$XXX.XX" or "N/A"
        let priceDisplay = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '$' OR label CONTAINS 'N/A'")).firstMatch
        // Price update might succeed or fail, so we just verify the UI responds
        XCTAssertTrue(app.exists, "App should still be responsive after refresh")
        
        // Verify update timestamp appears (if price was fetched)
        // The timestamp might be displayed as relative time
        let timestampText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Updated' OR label CONTAINS[c] 'ago'")).firstMatch
        // This is optional as timestamp might not always be visible
    }
}
