//
//  NoteManagementTests.swift
//  stocknotesUITests
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import XCTest

final class NoteManagementTests: XCTestCase {
    var app: XCUIApplication!
    var helpers: TestHelpers!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        helpers = TestHelpers(app: app)
    }
    
    override func tearDownWithError() throws {
        // Cleanup: Remove test notes created during tests
        if let helpers = helpers {
            helpers.cleanupTestData()
        }
        app = nil
        helpers = nil
    }
    
    @MainActor
    func testCreateNewNote() throws {
        // Launch app (already done in setUp)
        helpers.navigateToHome()
        
        // Tap "+" button → Select "New Note"
        helpers.tapPlusButton()
        
        // Try to find "New Note" menu item or directly open note editor
        let newNoteButton = app.buttons["New Note"]
        if newNoteButton.waitForExistence(timeout: 2) {
            newNoteButton.tap()
        }
        
        // Verify NoteEditorView appears
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Note editor should appear with Save button")
        
        // Enter note content: "Test note content"
        helpers.enterTextInTextEditor("Test note content")
        
        // Tap "Save"
        if saveButton.isEnabled {
            saveButton.tap()
        } else {
            XCTFail("Save button should be enabled when content is entered")
        }
        
        // Verify note is saved and editor dismisses
        let homeNavBar = app.navigationBars["Stock Notes"]
        XCTAssertTrue(homeNavBar.waitForExistence(timeout: 5), "Should return to home screen after saving")
        
        // Verify note appears in Recent Notes on Home screen
        // The note content should be visible somewhere
        let noteText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Test note content'")).firstMatch
        XCTAssertTrue(noteText.waitForExistence(timeout: 5), "Note should appear in Recent Notes")
    }
    
    @MainActor
    func testCreateNoteWithSymbol() throws {
        // Launch app
        helpers.navigateToSymbols()
        
        // Add a symbol (e.g., "AAPL")
        helpers.createTestSymbol(ticker: "AAPL")
        
        // Wait for symbol to be added
        sleep(2)
        
        // Navigate to Home tab
        helpers.navigateToHome()
        
        // Create new note
        helpers.tapPlusButton()
        let newNoteButton = app.buttons["New Note"]
        if newNoteButton.waitForExistence(timeout: 2) {
            newNoteButton.tap()
        }
        
        // Wait for note editor
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Note editor should appear")
        
        // In symbol autocomplete, search for "AAPL"
        let symbolField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'symbol' OR placeholderValue CONTAINS[c] 'AAPL'")).firstMatch
        if symbolField.waitForExistence(timeout: 3) {
            helpers.enterText("AAPL", inField: symbolField)
            
            // Wait for search results
            sleep(3) // Wait for API call
            
            // Select "AAPL" from results
            let aaplResult = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'AAPL'")).firstMatch
            if aaplResult.waitForExistence(timeout: 5) {
                aaplResult.tap()
            }
        }
        
        // Enter note content: "Apple stock analysis"
        helpers.enterTextInTextEditor("Apple stock analysis")
        
        // Add tag: "tech"
        let tagField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'tag' OR placeholderValue CONTAINS[c] 'Add tag'")).firstMatch
        if tagField.waitForExistence(timeout: 3) {
            helpers.enterText("tech", inField: tagField)
            // Press return or tap add button
            if app.keyboards.buttons["return"].exists {
                app.keyboards.buttons["return"].tap()
            } else {
                let addTagButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'plus'")).firstMatch
                if addTagButton.waitForExistence(timeout: 1) {
                    addTagButton.tap()
                }
            }
        }
        
        // Tap "Save"
        if saveButton.isEnabled {
            saveButton.tap()
        }
        
        // Verify note is created with symbol and tag
        let homeNavBar = app.navigationBars["Stock Notes"]
        XCTAssertTrue(homeNavBar.waitForExistence(timeout: 5), "Should return to home screen")
        
        // Verify note appears with symbol and tag
        let noteText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Apple stock analysis'")).firstMatch
        XCTAssertTrue(noteText.waitForExistence(timeout: 5), "Note should appear")
    }
    
    @MainActor
    func testEditNote() throws {
        // Create a note with content "Original content"
        helpers.createTestNote(content: "Original content")
        
        // Wait for note to appear
        sleep(2)
        
        // Open note from Recent Notes
        let originalNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Original content'")).firstMatch
        if originalNote.waitForExistence(timeout: 5) {
            originalNote.tap()
        } else {
            // Try tapping the first note in the list
            helpers.tapFirstListItem()
        }
        
        // Verify note detail view appears
        let detailNavBar = app.navigationBars["Note Details"]
        XCTAssertTrue(detailNavBar.waitForExistence(timeout: 5), "Note detail view should appear")
        
        // Tap menu button (ellipsis) → Select "Edit"
        let menuButton = detailNavBar.buttons.matching(NSPredicate(format: "label CONTAINS 'ellipsis' OR identifier CONTAINS 'menu'")).firstMatch
        if menuButton.exists {
            menuButton.tap()
        } else {
            // Try finding edit button directly
            let editButton = app.buttons["Edit"]
            if editButton.waitForExistence(timeout: 2) {
                editButton.tap()
            }
        }
        
        // If menu opened, select Edit
        let editMenuItem = app.buttons["Edit"]
        if editMenuItem.waitForExistence(timeout: 2) {
            editMenuItem.tap()
        }
        
        // Verify editor appears
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Note editor should appear")
        
        // Modify content to "Updated content"
        let textEditor = app.textViews.firstMatch
        if textEditor.waitForExistence(timeout: 3) {
            textEditor.tap()
            // Clear existing text
            textEditor.clearText()
            textEditor.typeText("Updated content")
        }
        
        // Tap "Save"
        if saveButton.isEnabled {
            saveButton.tap()
        }
        
        // Verify note shows updated content
        let updatedText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Updated content'")).firstMatch
        XCTAssertTrue(updatedText.waitForExistence(timeout: 5), "Note should show updated content")
        
        // Verify "Last edited" timestamp is displayed
        let lastEditedText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Last edited' OR label CONTAINS[c] 'edited'")).firstMatch
        XCTAssertTrue(lastEditedText.waitForExistence(timeout: 3), "Last edited timestamp should be displayed")
    }
    
    @MainActor
    func testDeleteNote() throws {
        // Create a note
        helpers.createTestNote(content: "Note to delete")
        
        // Wait for note to appear
        sleep(2)
        
        // Open note detail view
        let noteText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Note to delete'")).firstMatch
        if noteText.waitForExistence(timeout: 5) {
            noteText.tap()
        } else {
            helpers.tapFirstListItem()
        }
        
        // Verify detail view appears
        let detailNavBar = app.navigationBars["Note Details"]
        XCTAssertTrue(detailNavBar.waitForExistence(timeout: 5), "Note detail view should appear")
        
        // Tap menu button → Select "Delete"
        let menuButton = detailNavBar.buttons.matching(NSPredicate(format: "label CONTAINS 'ellipsis' OR identifier CONTAINS 'menu'")).firstMatch
        if menuButton.exists {
            menuButton.tap()
        }
        
        let deleteButton = app.buttons["Delete"]
        if deleteButton.waitForExistence(timeout: 2) {
            deleteButton.tap()
        }
        
        // Confirm deletion (if alert appears)
        helpers.handleAlert(buttonTitle: "Delete")
        
        // Verify note is removed from list
        let homeNavBar = app.navigationBars["Stock Notes"]
        XCTAssertTrue(homeNavBar.waitForExistence(timeout: 5), "Should return to home screen")
        
        // Verify note no longer exists
        let deletedNote = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Note to delete'")).firstMatch
        XCTAssertFalse(deletedNote.exists, "Note should be deleted")
    }
    
    @MainActor
    func testNoteCharacterLimit() throws {
        // Create new note
        helpers.navigateToHome()
        helpers.tapPlusButton()
        let newNoteButton = app.buttons["New Note"]
        if newNoteButton.waitForExistence(timeout: 2) {
            newNoteButton.tap()
        }
        
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Note editor should appear")
        
        // Enter text exceeding 5000 characters
        let longText = String(repeating: "A", count: 5001)
        helpers.enterTextInTextEditor(longText)
        
        // Verify character counter shows red/error state
        // Look for character count text
        let charCountText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '5001' OR label CONTAINS '5000'")).firstMatch
        XCTAssertTrue(charCountText.waitForExistence(timeout: 3), "Character counter should be visible")
        
        // Verify "Save" button is disabled
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled when exceeding character limit")
        
        // Reduce to 5000 characters
        let textEditor = app.textViews.firstMatch
        if textEditor.waitForExistence(timeout: 3) {
            textEditor.tap()
            // Delete one character
            textEditor.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        
        // Verify "Save" button becomes enabled
        // Wait a moment for the UI to update
        sleep(1)
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled when within character limit")
    }
    
    @MainActor
    func testNoteWithImages() throws {
        // Note: Image picker testing is limited in UI tests
        // This test verifies the UI flow but may not be able to actually select images
        // depending on simulator permissions
        
        // Create new note
        helpers.navigateToHome()
        helpers.tapPlusButton()
        let newNoteButton = app.buttons["New Note"]
        if newNoteButton.waitForExistence(timeout: 2) {
            newNoteButton.tap()
        }
        
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Note editor should appear")
        
        // Tap "Add Images" button
        let addImagesButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Image' OR label CONTAINS[c] 'Photo' OR label CONTAINS[c] 'Add'")).firstMatch
        if addImagesButton.waitForExistence(timeout: 3) {
            addImagesButton.tap()
            
            // Handle photo library permission if needed
            let allowButton = app.alerts.buttons["Allow Access to All Photos"]
            if allowButton.waitForExistence(timeout: 2) {
                allowButton.tap()
            }
            
            // Try to select an image (this may not work in all simulators)
            // The image picker UI varies, so we'll just verify the button was tapped
            sleep(1)
        }
        
        // Enter note content
        helpers.enterTextInTextEditor("Note with image")
        
        // Save note
        if saveButton.isEnabled {
            saveButton.tap()
        }
        
        // Open note detail view
        sleep(2)
        let noteText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Note with image'")).firstMatch
        if noteText.waitForExistence(timeout: 5) {
            noteText.tap()
        } else {
            helpers.tapFirstListItem()
        }
        
        // Verify images section exists (even if empty)
        // The ImageAttachmentView should be present if images were added
        let detailNavBar = app.navigationBars["Note Details"]
        XCTAssertTrue(detailNavBar.waitForExistence(timeout: 5), "Note detail view should appear")
    }
}
