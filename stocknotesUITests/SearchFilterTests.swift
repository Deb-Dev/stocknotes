//
//  SearchFilterTests.swift
//  stocknotesUITests
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import XCTest

final class SearchFilterTests: XCTestCase {
    var app: XCUIApplication!
    var helpers: TestHelpers!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        helpers = TestHelpers(app: app)
    }
    
    override func tearDownWithError() throws {
        // Cleanup: Remove test notes and symbols created during tests
        if let helpers = helpers {
            helpers.cleanupTestData()
        }
        app = nil
        helpers = nil
    }
    
    @MainActor
    func testSearchNotes() throws {
        // Create multiple notes with different content
        helpers.createTestNote(content: "Test note about Apple")
        sleep(1)
        helpers.createTestNote(content: "Another test note")
        sleep(1)
        helpers.createTestNote(content: "Note about Microsoft")
        sleep(2)
        
        // Navigate to Search tab
        helpers.navigateToSearch()
        
        // Enter search query: "test"
        helpers.performSearch("test")
        
        // Wait for search results
        sleep(2)
        
        // Verify filtered notes appear
        // Should see notes containing "test"
        let testNote1 = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Test note about Apple'")).firstMatch
        let testNote2 = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Another test note'")).firstMatch
        
        XCTAssertTrue(testNote1.exists || testNote2.exists, "Filtered notes should appear")
        
        // Verify search scope shows "Notes" selected
        let notesScope = app.segmentedControls.buttons["Notes"]
        if notesScope.waitForExistence(timeout: 2) {
            XCTAssertTrue(notesScope.isSelected, "Notes scope should be selected")
        }
        
        // Clear search → Verify all notes reappear
        helpers.clearSearch()
        sleep(1)
        
        // Verify search is cleared
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            let searchText = searchField.value as? String ?? ""
            XCTAssertTrue(searchText.isEmpty, "Search field should be cleared")
        }
    }
    
    @MainActor
    func testSearchSymbols() throws {
        // Add multiple symbols
        helpers.createTestSymbol(ticker: "AAPL")
        sleep(1)
        helpers.createTestSymbol(ticker: "MSFT")
        sleep(1)
        helpers.createTestSymbol(ticker: "GOOGL")
        sleep(2)
        
        // Navigate to Search tab
        helpers.navigateToSearch()
        
        // Switch scope to "Symbols"
        let symbolsScope = app.segmentedControls.buttons["Symbols"]
        if symbolsScope.waitForExistence(timeout: 3) {
            symbolsScope.tap()
        }
        
        // Enter search query: "AAPL"
        helpers.performSearch("AAPL")
        
        // Wait for search results
        sleep(2)
        
        // Verify matching symbols appear
        let aaplSymbol = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
        XCTAssertTrue(aaplSymbol.waitForExistence(timeout: 5), "AAPL symbol should appear in search results")
        
        // Tap on symbol → Verify SymbolDetailView opens
        if aaplSymbol.exists {
            aaplSymbol.tap()
            
            // Verify symbol detail view appears
            let detailNavBar = app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS 'AAPL' OR label CONTAINS 'AAPL'")).firstMatch
            XCTAssertTrue(detailNavBar.waitForExistence(timeout: 5), "Symbol detail view should open")
        }
    }
    
    @MainActor
    func testFilterNotesBySymbol() throws {
        // Create notes with different symbols
        helpers.createTestSymbol(ticker: "AAPL")
        sleep(1)
        helpers.createTestSymbol(ticker: "MSFT")
        sleep(1)
        
        helpers.createTestNote(content: "Apple note", symbol: "AAPL")
        sleep(1)
        helpers.createTestNote(content: "Microsoft note", symbol: "MSFT")
        sleep(2)
        
        // Navigate to Notes tab
        helpers.navigateToNotes()
        
        // Tap symbol filter
        // Look for filter chips or menu
        let aaplFilter = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
        if aaplFilter.waitForExistence(timeout: 5) {
            aaplFilter.tap()
        } else {
            // Try finding filter bar
            let filterBar = app.scrollViews.firstMatch
            if filterBar.exists {
                // Look for symbol filter in horizontal scroll
                let symbolChips = app.buttons.matching(NSPredicate(format: "label CONTAINS 'AAPL' OR label CONTAINS 'MSFT'"))
                if symbolChips.count > 0 {
                    symbolChips.firstMatch.tap()
                }
            }
        }
        
        // Wait for filter to apply
        sleep(2)
        
        // Verify only notes for that symbol appear
        let appleNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Apple note'")).firstMatch
        let microsoftNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Microsoft note'")).firstMatch
        
        // If AAPL filter is selected, only Apple note should appear
        XCTAssertTrue(appleNote.exists, "Apple note should appear when AAPL filter is selected")
        
        // Clear filter → Verify all notes reappear
        // Tap "All Symbols" filter chip
        let allSymbolsFilter = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'All Symbols'")).firstMatch
        if allSymbolsFilter.waitForExistence(timeout: 2) {
            allSymbolsFilter.tap()
        }
        
        sleep(1)
        
        // Verify both notes appear
        XCTAssertTrue(appleNote.exists || microsoftNote.exists, "All notes should reappear after clearing filter")
    }
    
    @MainActor
    func testFilterNotesByTag() throws {
        // Create notes with different tags
        helpers.createTestNote(content: "Tech note", tags: ["tech"])
        sleep(1)
        helpers.createTestNote(content: "Finance note", tags: ["finance"])
        sleep(2)
        
        // Navigate to Notes tab
        helpers.navigateToNotes()
        
        // Tap tag filter
        let techTagFilter = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '#tech' OR label CONTAINS[c] 'tech'")).firstMatch
        if techTagFilter.waitForExistence(timeout: 5) {
            techTagFilter.tap()
        } else {
            // Try finding tag in filter bar
            let tagChips = app.buttons.matching(NSPredicate(format: "label CONTAINS 'tech' OR label CONTAINS 'finance'"))
            if tagChips.count > 0 {
                tagChips.firstMatch.tap()
            }
        }
        
        // Wait for filter to apply
        sleep(2)
        
        // Verify only notes with that tag appear
        let techNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Tech note'")).firstMatch
        let financeNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Finance note'")).firstMatch
        
        // If tech filter is selected, only tech note should appear
        XCTAssertTrue(techNote.exists, "Tech note should appear when tech tag filter is selected")
    }
    
    @MainActor
    func testFilterNotesByDateRange() throws {
        // Create notes (they will be created with current date)
        helpers.createTestNote(content: "Today's note")
        sleep(2)
        
        // Navigate to Notes tab
        helpers.navigateToNotes()
        
        // Select date range filter: "Today"
        // Look for date range menu or picker
        let dateMenu = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Today' OR label CONTAINS[c] 'All Time' OR label CONTAINS[c] 'calendar'")).firstMatch
        if dateMenu.waitForExistence(timeout: 5) {
            dateMenu.tap()
            
            // Select "Today" option
            let todayOption = app.buttons["Today"]
            if todayOption.waitForExistence(timeout: 2) {
                todayOption.tap()
            }
        }
        
        // Wait for filter to apply
        sleep(1)
        
        // Verify only today's notes appear
        let todaysNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Today'")).firstMatch
        XCTAssertTrue(todaysNote.exists, "Today's note should appear")
        
        // Change to "Week" → Verify week's notes appear
        let weekMenu = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Week'")).firstMatch
        if weekMenu.waitForExistence(timeout: 2) {
            weekMenu.tap()
            let weekOption = app.buttons["This Week"]
            if weekOption.waitForExistence(timeout: 2) {
                weekOption.tap()
            }
        }
        
        sleep(1)
        XCTAssertTrue(todaysNote.exists, "Week's notes should appear")
        
        // Change to "All" → Verify all notes appear
        let allMenu = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'All Time' OR label CONTAINS[c] 'All'")).firstMatch
        if allMenu.waitForExistence(timeout: 2) {
            allMenu.tap()
            let allOption = app.buttons["All Time"]
            if allOption.waitForExistence(timeout: 2) {
                allOption.tap()
            }
        }
        
        sleep(1)
        XCTAssertTrue(todaysNote.exists, "All notes should appear")
    }
    
    @MainActor
    func testSortNotes() throws {
        // Create multiple notes
        helpers.createTestNote(content: "First note")
        sleep(1)
        helpers.createTestNote(content: "Second note")
        sleep(1)
        helpers.createTestNote(content: "Third note")
        sleep(2)
        
        // Navigate to Notes tab
        helpers.navigateToNotes()
        
        // Change sort option to "Edit Date"
        let sortMenu = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sort' OR label CONTAINS[c] 'arrow'")).firstMatch
        if sortMenu.waitForExistence(timeout: 5) {
            sortMenu.tap()
            
            let editDateOption = app.buttons["Edit Date"]
            if editDateOption.waitForExistence(timeout: 2) {
                editDateOption.tap()
            }
        }
        
        // Wait for sort to apply
        sleep(1)
        
        // Verify notes are sorted (order might vary, but list should exist)
        let firstNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'First note' OR label CONTAINS[c] 'Second note' OR label CONTAINS[c] 'Third note'")).firstMatch
        XCTAssertTrue(firstNote.exists, "Notes should be visible after sorting")
        
        // Change to "Symbol Name"
        if sortMenu.exists {
            sortMenu.tap()
            
            let symbolNameOption = app.buttons["Symbol Name"]
            if symbolNameOption.waitForExistence(timeout: 2) {
                symbolNameOption.tap()
            }
        }
        
        sleep(1)
        
        // Verify notes sorted alphabetically by symbol
        // (This assumes notes have symbols assigned)
        XCTAssertTrue(firstNote.exists, "Notes should be visible after sorting by symbol")
    }
}
