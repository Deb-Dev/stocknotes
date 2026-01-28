//
//  TestHelpers.swift
//  stocknotesUITests
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import XCTest

class TestHelpers {
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Navigation Helpers
    
    func navigateToTab(_ tabName: String) {
        let tabBar = app.tabBars.firstMatch
        let tab = tabBar.buttons[tabName]
        if tab.waitForExistence(timeout: 2) {
            tab.tap()
        }
    }
    
    func navigateToHome() {
        navigateToTab("Home")
    }
    
    func navigateToSymbols() {
        navigateToTab("Symbols")
    }
    
    func navigateToNotes() {
        navigateToTab("Notes")
    }
    
    func navigateToSearch() {
        navigateToTab("Search")
    }
    
    func navigateToSettings() {
        navigateToTab("Settings")
    }
    
    // MARK: - Button Helpers
    
    func tapButton(_ label: String) {
        let button = app.buttons[label]
        if button.waitForExistence(timeout: 5) {
            button.tap()
        }
    }
    
    func tapButtonWithImage(_ imageName: String) {
        let button = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", imageName)).firstMatch
        if button.waitForExistence(timeout: 5) {
            button.tap()
        }
    }
    
    func tapPlusButton() {
        // Find the plus button in navigation bar
        let plusButton = app.navigationBars.buttons.matching(identifier: "plus.circle.fill").firstMatch
        if !plusButton.exists {
            // Try alternative ways to find plus button
            let buttons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'plus' OR label CONTAINS 'New'"))
            if buttons.count > 0 {
                buttons.firstMatch.tap()
            }
        } else {
            plusButton.tap()
        }
    }
    
    // MARK: - Text Field Helpers
    
    func enterText(_ text: String, inField field: XCUIElement) {
        field.tap()
        field.clearText()
        field.typeText(text)
    }
    
    func enterTextInTextField(_ text: String, placeholder: String? = nil) {
        let textField: XCUIElement
        if let placeholder = placeholder {
            textField = app.textFields[placeholder]
        } else {
            textField = app.textFields.firstMatch
        }
        
        if textField.waitForExistence(timeout: 5) {
            enterText(text, inField: textField)
        }
    }
    
    // MARK: - Text Editor Helpers
    
    func enterTextInTextEditor(_ text: String) {
        let textEditor = app.textViews.firstMatch
        if textEditor.waitForExistence(timeout: 5) {
            textEditor.tap()
            textEditor.typeText(text)
        }
    }
    
    // MARK: - Wait Helpers
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    func waitForText(_ text: String, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        let element = app.staticTexts.matching(predicate).firstMatch
        return element.waitForExistence(timeout: timeout)
    }
    
    func waitForNavigationTitle(_ title: String, timeout: TimeInterval = 5) -> Bool {
        let navBar = app.navigationBars[title]
        return navBar.waitForExistence(timeout: timeout)
    }
    
    // MARK: - Menu Helpers
    
    func selectMenuItem(_ menuItem: String) {
        // First try to find menu buttons
        let menuButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", menuItem)).firstMatch
        if menuButton.waitForExistence(timeout: 2) {
            menuButton.tap()
        } else {
            // Try finding in menus
            let menu = app.menus.firstMatch
            if menu.waitForExistence(timeout: 2) {
                let item = menu.buttons[menuItem]
                if item.waitForExistence(timeout: 2) {
                    item.tap()
                }
            }
        }
    }
    
    // MARK: - Alert Helpers
    
    func handleAlert(buttonTitle: String, timeout: TimeInterval = 5) {
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: timeout) {
            let button = alert.buttons[buttonTitle]
            if button.waitForExistence(timeout: 2) {
                button.tap()
            }
        }
    }
    
    // MARK: - List Helpers
    
    func tapFirstListItem() {
        let list = app.tables.firstMatch
        if list.waitForExistence(timeout: 5) {
            let firstCell = list.cells.firstMatch
            if firstCell.waitForExistence(timeout: 2) {
                firstCell.tap()
            }
        }
    }
    
    func swipeToDeleteFirstItem() {
        let list = app.tables.firstMatch
        if list.waitForExistence(timeout: 5) {
            let firstCell = list.cells.firstMatch
            if firstCell.waitForExistence(timeout: 2) {
                firstCell.swipeLeft()
                // Look for delete button
                let deleteButton = app.buttons["Delete"]
                if deleteButton.waitForExistence(timeout: 1) {
                    deleteButton.tap()
                }
            }
        }
    }
    
    // MARK: - Search Helpers
    
    func performSearch(_ query: String) {
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 5) {
            searchField.tap()
            searchField.typeText(query)
        } else {
            // Try text field if search field not found
            let textField = app.textFields.firstMatch
            if textField.waitForExistence(timeout: 5) {
                textField.tap()
                textField.typeText(query)
            }
        }
    }
    
    func clearSearch() {
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 2) {
            let clearButton = searchField.buttons["Clear text"]
            if clearButton.exists {
                clearButton.tap()
            } else {
                // Clear manually
                searchField.tap()
                let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 100)
                searchField.typeText(deleteString)
            }
        }
    }
    
    // MARK: - Sheet/Dismiss Helpers
    
    func dismissSheet() {
        // Try Cancel button
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.waitForExistence(timeout: 2) {
            cancelButton.tap()
        } else {
            // Try swipe down
            let sheet = app.sheets.firstMatch
            if sheet.exists {
                let startPoint = sheet.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                let endPoint = sheet.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
                startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
            }
        }
    }
    
    // MARK: - Verification Helpers
    
    func verifyElementExists(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    func verifyTextExists(_ text: String, timeout: TimeInterval = 5) -> Bool {
        return waitForText(text, timeout: timeout)
    }
    
    func verifyNavigationTitle(_ title: String, timeout: TimeInterval = 5) -> Bool {
        return waitForNavigationTitle(title, timeout: timeout)
    }
    
    // MARK: - Test Data Helpers
    
    func createTestNote(content: String, symbol: String? = nil, tags: [String] = []) {
        navigateToHome()
        tapPlusButton()
        
        // Wait for note editor
        let saveButton = app.buttons["Save"]
        if saveButton.waitForExistence(timeout: 5) {
            // Enter content
            enterTextInTextEditor(content)
            
            // Add symbol if provided
            if let symbol = symbol {
                // Find symbol autocomplete field
                let symbolField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'symbol'")).firstMatch
                if symbolField.waitForExistence(timeout: 2) {
                    enterText(symbol, inField: symbolField)
                    // Wait for results and tap first result
                    sleep(2) // Wait for search results
                    tapFirstListItem()
                }
            }
            
            // Add tags if provided
            for tag in tags {
                let tagField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'tag'")).firstMatch
                if tagField.waitForExistence(timeout: 2) {
                    enterText(tag, inField: tagField)
                    app.keyboards.buttons["return"].tap()
                }
            }
            
            // Save
            if saveButton.isEnabled {
                saveButton.tap()
            }
        }
    }
    
    func createTestSymbol(ticker: String, companyName: String? = nil) {
        navigateToSymbols()
        tapPlusButton()
        
        // Wait for add symbol view
        let addButton = app.buttons["Add"]
        if addButton.waitForExistence(timeout: 5) {
            // Enter ticker
            let tickerField = app.textFields.firstMatch
            if tickerField.waitForExistence(timeout: 2) {
                enterText(ticker, inField: tickerField)
                
                // Wait for search results
                sleep(2)
                
                // If results appear, tap first one, otherwise just add
                let firstResult = app.tables.cells.firstMatch
                if firstResult.waitForExistence(timeout: 2) {
                    firstResult.tap()
                } else if let companyName = companyName {
                    // Enter company name manually
                    let companyField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'Company'")).firstMatch
                    if companyField.waitForExistence(timeout: 2) {
                        enterText(companyName, inField: companyField)
                    }
                }
                
                // Tap Add button
                if addButton.isEnabled {
                    addButton.tap()
                }
            }
        }
    }
    
    // MARK: - Cleanup Helpers
    
    /// Cleanup Strategy:
    /// - Each test class should call cleanupTestData() in tearDownWithError()
    /// - cleanupTestData() removes test data matching common test patterns
    /// - For complete cleanup, use deleteAllNotes() and deleteAllSymbols() (use with caution)
    /// - Note: SwiftData persists data between app launches, so cleanup is important for test isolation
    
    /// Delete a note by its content text through the UI
    func deleteNote(containingText text: String) {
        navigateToNotes()
        
        // Find the note
        let noteText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", text)).firstMatch
        if noteText.waitForExistence(timeout: 3) {
            noteText.tap()
            
            // Wait for detail view
            let detailNavBar = app.navigationBars["Note Details"]
            if detailNavBar.waitForExistence(timeout: 3) {
                // Tap menu button
                let menuButton = detailNavBar.buttons.matching(NSPredicate(format: "label CONTAINS 'ellipsis' OR identifier CONTAINS 'menu'")).firstMatch
                if menuButton.exists {
                    menuButton.tap()
                }
                
                // Tap delete
                let deleteButton = app.buttons["Delete"]
                if deleteButton.waitForExistence(timeout: 2) {
                    deleteButton.tap()
                    
                    // Confirm deletion if alert appears
                    handleAlert(buttonTitle: "Delete", timeout: 2)
                }
            }
        }
    }
    
    /// Delete a symbol by ticker through the UI
    func deleteSymbol(ticker: String) {
        navigateToSymbols()
        
        // Find the symbol
        let symbolText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", ticker)).firstMatch
        if symbolText.waitForExistence(timeout: 3) {
            // Try swiping left to delete
            let table = app.tables.firstMatch
            if table.waitForExistence(timeout: 2) {
                let cells = table.cells
                for i in 0..<cells.count {
                    let cell = cells.element(boundBy: i)
                    if cell.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", ticker)).firstMatch.exists {
                        cell.swipeLeft()
                        
                        let deleteButton = app.buttons["Delete"]
                        if deleteButton.waitForExistence(timeout: 2) {
                            deleteButton.tap()
                            
                            // Confirm deletion if alert appears
                            handleAlert(buttonTitle: "Delete", timeout: 2)
                            break
                        }
                    }
                }
            }
        }
    }
    
    /// Clean up all test data created during tests
    /// This deletes notes and symbols that match common test patterns
    /// Returns true if cleanup was successful, false otherwise
    @discardableResult
    func cleanupTestData() -> Bool {
        var cleanupSuccessful = true
        
        // Clean up test notes
        let testNotePatterns = [
            "Test note",
            "Note to delete",
            "Original content",
            "Updated content",
            "Note with",
            "Quick snapshot",
            "Tech note",
            "Finance note",
            "Energy note",
            "Apple note",
            "Microsoft note",
            "Today's note",
            "First note",
            "Second note",
            "Third note",
            "Note for backup",
            "Note for PDF"
        ]
        
        for pattern in testNotePatterns {
            // Try to delete, but don't fail if note doesn't exist
            let noteExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", pattern)).firstMatch.exists
            if noteExists {
                deleteNote(containingText: pattern)
                sleep(1) // Small delay between deletions
            }
        }
        
        // Clean up test symbols
        let testSymbols = ["TEST", "XYZ.TO"]
        for ticker in testSymbols {
            // Try to delete, but don't fail if symbol doesn't exist
            let symbolExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", ticker)).firstMatch.exists
            if symbolExists {
                deleteSymbol(ticker: ticker)
                sleep(1)
            }
        }
        
        // Navigate back to home
        navigateToHome()
        
        return cleanupSuccessful
    }
    
    /// Delete all notes through the UI (use with caution)
    func deleteAllNotes() {
        navigateToNotes()
        
        let table = app.tables.firstMatch
        if table.waitForExistence(timeout: 3) {
            let cells = table.cells
            let cellCount = cells.count
            
            // Delete from last to first to avoid index issues
            for i in stride(from: cellCount - 1, through: 0, by: -1) {
                let cell = cells.element(boundBy: i)
                if cell.exists {
                    cell.tap()
                    
                    let detailNavBar = app.navigationBars["Note Details"]
                    if detailNavBar.waitForExistence(timeout: 2) {
                        let menuButton = detailNavBar.buttons.matching(NSPredicate(format: "label CONTAINS 'ellipsis' OR identifier CONTAINS 'menu'")).firstMatch
                        if menuButton.exists {
                            menuButton.tap()
                        }
                        
                        let deleteButton = app.buttons["Delete"]
                        if deleteButton.waitForExistence(timeout: 2) {
                            deleteButton.tap()
                            handleAlert(buttonTitle: "Delete", timeout: 2)
                        }
                    }
                    
                    sleep(1)
                }
            }
        }
    }
    
    /// Delete all symbols through the UI (use with caution)
    func deleteAllSymbols() {
        navigateToSymbols()
        
        let table = app.tables.firstMatch
        if table.waitForExistence(timeout: 3) {
            let cells = table.cells
            let cellCount = cells.count
            
            // Delete from last to first to avoid index issues
            for i in stride(from: cellCount - 1, through: 0, by: -1) {
                let cell = cells.element(boundBy: i)
                if cell.exists {
                    cell.swipeLeft()
                    
                    let deleteButton = app.buttons["Delete"]
                    if deleteButton.waitForExistence(timeout: 2) {
                        deleteButton.tap()
                        handleAlert(buttonTitle: "Delete", timeout: 2)
                    }
                    
                    sleep(1)
                }
            }
        }
    }
}

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
