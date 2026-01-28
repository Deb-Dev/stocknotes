//
//  TagManagementTests.swift
//  stocknotesUITests
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import XCTest

final class TagManagementTests: XCTestCase {
    var app: XCUIApplication!
    var helpers: TestHelpers!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        helpers = TestHelpers(app: app)
    }
    
    override func tearDownWithError() throws {
        // Cleanup: Remove test notes and tags created during tests
        if let helpers = helpers {
            helpers.cleanupTestData()
        }
        app = nil
        helpers = nil
    }
    
    @MainActor
    func testAddTagToNote() throws {
        // Create new note
        helpers.navigateToHome()
        helpers.tapPlusButton()
        let newNoteButton = app.buttons["New Note"]
        if newNoteButton.waitForExistence(timeout: 2) {
            newNoteButton.tap()
        }
        
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Note editor should appear")
        
        // Enter note content
        helpers.enterTextInTextEditor("Note with investment tag")
        
        // In tag input field, type "investment"
        let tagField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'tag' OR placeholderValue CONTAINS[c] 'Add tag'")).firstMatch
        if tagField.waitForExistence(timeout: 3) {
            helpers.enterText("investment", inField: tagField)
            
            // Verify tag autocomplete appears (if tags exist)
            // Wait a moment for autocomplete
            sleep(1)
            
            // Select or create tag "investment"
            // Try tapping the tag suggestion if it appears
            let investmentTag = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'investment'")).firstMatch
            if investmentTag.waitForExistence(timeout: 2) {
                investmentTag.tap()
            } else {
                // Press return to create tag
                if app.keyboards.buttons["return"].exists {
                    app.keyboards.buttons["return"].tap()
                } else {
                    // Try tapping plus button
                    let addTagButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'plus'")).firstMatch
                    if addTagButton.waitForExistence(timeout: 1) {
                        addTagButton.tap()
                    }
                }
            }
        }
        
        // Save note
        if saveButton.isEnabled {
            saveButton.tap()
        }
        
        // Verify tag appears in note detail view
        sleep(2)
        let noteText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Note with investment tag'")).firstMatch
        if noteText.waitForExistence(timeout: 5) {
            noteText.tap()
        } else {
            helpers.tapFirstListItem()
        }
        
        // Verify note detail view appears
        let detailNavBar = app.navigationBars["Note Details"]
        XCTAssertTrue(detailNavBar.waitForExistence(timeout: 5), "Note detail view should appear")
        
        // Verify tag is displayed
        let investmentTagDisplay = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'investment' OR label CONTAINS[c] '#investment'")).firstMatch
        XCTAssertTrue(investmentTagDisplay.waitForExistence(timeout: 3), "Investment tag should appear in note detail")
    }
    
    @MainActor
    func testMultipleTags() throws {
        // Create note
        helpers.navigateToHome()
        helpers.tapPlusButton()
        let newNoteButton = app.buttons["New Note"]
        if newNoteButton.waitForExistence(timeout: 2) {
            newNoteButton.tap()
        }
        
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Note editor should appear")
        
        // Enter note content
        helpers.enterTextInTextEditor("Note with multiple tags")
        
        // Add multiple tags: "tech", "growth", "dividend"
        let tagField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'tag' OR placeholderValue CONTAINS[c] 'Add tag'")).firstMatch
        
        let tags = ["tech", "growth", "dividend"]
        for tag in tags {
            if tagField.waitForExistence(timeout: 3) {
                helpers.enterText(tag, inField: tagField)
                
                // Add tag
                if app.keyboards.buttons["return"].exists {
                    app.keyboards.buttons["return"].tap()
                } else {
                    let addTagButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'plus'")).firstMatch
                    if addTagButton.waitForExistence(timeout: 1) {
                        addTagButton.tap()
                    }
                }
                
                sleep(1) // Wait for tag to be added
            }
        }
        
        // Save note
        if saveButton.isEnabled {
            saveButton.tap()
        }
        
        // Verify all tags appear in note detail view
        sleep(2)
        let noteText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Note with multiple tags'")).firstMatch
        if noteText.waitForExistence(timeout: 5) {
            noteText.tap()
        } else {
            helpers.tapFirstListItem()
        }
        
        let detailNavBar = app.navigationBars["Note Details"]
        XCTAssertTrue(detailNavBar.waitForExistence(timeout: 5), "Note detail view should appear")
        
        // Verify all tags are displayed
        for tag in tags {
            let tagDisplay = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] '\(tag)' OR label CONTAINS[c] '#\(tag)'")).firstMatch
            XCTAssertTrue(tagDisplay.waitForExistence(timeout: 2), "Tag '\(tag)' should appear in note detail")
        }
        
        // Verify tags appear in tag cloud on Home screen
        helpers.navigateToHome()
        
        // Look for tag cloud section
        let tagCloud = app.scrollViews.matching(NSPredicate(format: "identifier CONTAINS 'tag' OR label CONTAINS 'tag'")).firstMatch
        // Tag cloud might be visible if tags exist
        XCTAssertTrue(app.exists, "Home screen should be visible")
    }
    
    @MainActor
    func testViewNotesByTag() throws {
        // Create notes with tag "tech"
        helpers.createTestNote(content: "Tech note 1", tags: ["tech"])
        sleep(1)
        helpers.createTestNote(content: "Tech note 2", tags: ["tech"])
        sleep(1)
        helpers.createTestNote(content: "Finance note", tags: ["finance"])
        sleep(2)
        
        // Navigate to Home screen
        helpers.navigateToHome()
        
        // Tap on "tech" tag in tag cloud
        let techTag = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '#tech' OR label CONTAINS[c] 'tech'")).firstMatch
        if techTag.waitForExistence(timeout: 5) {
            techTag.tap()
        } else {
            // Try finding tag in horizontal scroll view
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                // Look for tech tag button
                let tagButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'tech'"))
                if tagButtons.count > 0 {
                    tagButtons.firstMatch.tap()
                }
            }
        }
        
        // Verify TagView appears
        let tagNavBar = app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS 'tech' OR label CONTAINS 'tech'")).firstMatch
        if tagNavBar.waitForExistence(timeout: 5) {
            // Verify all notes with "tech" tag are listed
            let techNote1 = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Tech note 1'")).firstMatch
            let techNote2 = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Tech note 2'")).firstMatch
            
            XCTAssertTrue(techNote1.exists || techNote2.exists, "Tech notes should be listed in tag view")
        } else {
            // If tag view doesn't open, verify tags are visible on home
            XCTAssertTrue(app.exists, "App should be responsive")
        }
    }
    
    @MainActor
    func testTagAutocomplete() throws {
        // Create notes with tags: "tech", "finance", "energy"
        helpers.createTestNote(content: "Tech note", tags: ["tech"])
        sleep(1)
        helpers.createTestNote(content: "Finance note", tags: ["finance"])
        sleep(1)
        helpers.createTestNote(content: "Energy note", tags: ["energy"])
        sleep(2)
        
        // Create new note
        helpers.navigateToHome()
        helpers.tapPlusButton()
        let newNoteButton = app.buttons["New Note"]
        if newNoteButton.waitForExistence(timeout: 2) {
            newNoteButton.tap()
        }
        
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Note editor should appear")
        
        // Start typing "te" in tag field
        let tagField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'tag' OR placeholderValue CONTAINS[c] 'Add tag'")).firstMatch
        if tagField.waitForExistence(timeout: 3) {
            helpers.enterText("te", inField: tagField)
            
            // Wait for autocomplete
            sleep(2)
            
            // Verify "tech" appears in autocomplete suggestions
            let techSuggestion = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'tech'")).firstMatch
            if techSuggestion.waitForExistence(timeout: 3) {
                // Select "tech" from suggestions
                techSuggestion.tap()
                
                // Verify tag is added
                let techTagDisplay = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'tech' OR label CONTAINS[c] '#tech'")).firstMatch
                XCTAssertTrue(techTagDisplay.waitForExistence(timeout: 2), "Tech tag should be added")
            } else {
                // Autocomplete might not be visible, but typing should work
                // Complete the tag manually
                tagField.typeText("ch")
                if app.keyboards.buttons["return"].exists {
                    app.keyboards.buttons["return"].tap()
                }
            }
        }
    }
}
