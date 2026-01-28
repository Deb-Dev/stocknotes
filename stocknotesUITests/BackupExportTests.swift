//
//  BackupExportTests.swift
//  stocknotesUITests
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import XCTest

final class BackupExportTests: XCTestCase {
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
    func testExportBackup() throws {
        // Create notes, symbols, and tags
        helpers.createTestSymbol(ticker: "AAPL")
        sleep(1)
        helpers.createTestNote(content: "Test note for backup", symbol: "AAPL", tags: ["test"])
        sleep(1)
        helpers.createTestNote(content: "Another note", tags: ["backup"])
        sleep(2)
        
        // Navigate to Settings tab
        helpers.navigateToSettings()
        
        // Tap "Export Backup"
        let exportBackupButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Export Backup' OR label CONTAINS[c] 'Export'")).firstMatch
        XCTAssertTrue(exportBackupButton.waitForExistence(timeout: 5), "Export Backup button should exist")
        exportBackupButton.tap()
        
        // Wait for backup creation
        sleep(3) // Wait for backup to be created
        
        // Verify share sheet appears
        // Share sheet might appear as a sheet or activity view controller
        let shareSheet = app.sheets.firstMatch
        let activityView = app.otherElements["ActivityListView"]
        
        // Either share sheet or activity view should appear
        let shareSheetExists = shareSheet.waitForExistence(timeout: 5)
        let activityViewExists = activityView.waitForExistence(timeout: 5)
        
        XCTAssertTrue(shareSheetExists || activityViewExists, "Share sheet should appear after export")
        
        // Verify backup file is generated (JSON format)
        // The share sheet should contain options to save/share the file
        // We can verify the share sheet is visible, but can't verify file contents in UI test
        
        // Dismiss share sheet
        if shareSheetExists {
            // Try tapping cancel or outside
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.waitForExistence(timeout: 2) {
                cancelButton.tap()
            } else {
                // Swipe down to dismiss
                let startPoint = shareSheet.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                let endPoint = shareSheet.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
                startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
            }
        }
    }
    
    @MainActor
    func testImportBackup() throws {
        // Note: Import backup testing is limited in UI tests because:
        // 1. We need a backup file to import
        // 2. File picker interactions are limited in UI tests
        // 3. We can't easily create test backup files
        
        // This test verifies the import UI flow exists and is accessible
        
        // Navigate to Settings tab
        helpers.navigateToSettings()
        
        // Tap "Import Backup"
        let importBackupButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Import Backup' OR label CONTAINS[c] 'Import'")).firstMatch
        XCTAssertTrue(importBackupButton.waitForExistence(timeout: 5), "Import Backup button should exist")
        
        // Verify button is enabled (might be disabled if no file picker available)
        XCTAssertTrue(importBackupButton.exists, "Import Backup button should exist")
        
        // Tap import button
        if importBackupButton.isEnabled {
            importBackupButton.tap()
            
            // Document picker might appear
            // We can't easily test file selection in UI tests
            // Just verify the button triggers some action
            sleep(1)
            
            // Try to dismiss any picker that appears
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.waitForExistence(timeout: 2) {
                cancelButton.tap()
            }
        }
        
        // Note: Full import testing would require:
        // 1. Creating a test backup file
        // 2. Selecting it in document picker
        // 3. Verifying data is imported
        // This is better suited for unit tests or manual testing
    }
    
    @MainActor
    func testExportPDF() throws {
        // Create multiple notes
        helpers.createTestNote(content: "First note for PDF")
        sleep(1)
        helpers.createTestNote(content: "Second note for PDF")
        sleep(1)
        helpers.createTestNote(content: "Third note for PDF")
        sleep(2)
        
        // Navigate to Settings tab
        helpers.navigateToSettings()
        
        // Tap "Export Notes as PDF"
        let exportPDFButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Export Notes as PDF' OR label CONTAINS[c] 'PDF'")).firstMatch
        if exportPDFButton.waitForExistence(timeout: 5) {
            exportPDFButton.tap()
        } else {
            // Try finding navigation link
            let exportLink = app.cells.matching(NSPredicate(format: "label CONTAINS[c] 'PDF'")).firstMatch
            if exportLink.waitForExistence(timeout: 3) {
                exportLink.tap()
            }
        }
        
        // Verify ExportView appears
        let exportNavBar = app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS 'Export' OR label CONTAINS 'Export'")).firstMatch
        XCTAssertTrue(exportNavBar.waitForExistence(timeout: 5), "Export view should appear")
        
        // Select export option (all notes or by symbol)
        // Look for export options
        let allNotesOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'All Notes' OR label CONTAINS[c] 'All'")).firstMatch
        if allNotesOption.waitForExistence(timeout: 3) {
            allNotesOption.tap()
        } else {
            // Try finding a generate/export button
            let generateButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Generate' OR label CONTAINS[c] 'Export' OR label CONTAINS[c] 'Create'")).firstMatch
            if generateButton.waitForExistence(timeout: 3) {
                generateButton.tap()
            }
        }
        
        // Wait for PDF generation
        sleep(3)
        
        // Verify share sheet appears with PDF
        let shareSheet = app.sheets.firstMatch
        let activityView = app.otherElements["ActivityListView"]
        
        let shareSheetExists = shareSheet.waitForExistence(timeout: 5)
        let activityViewExists = activityView.waitForExistence(timeout: 5)
        
        XCTAssertTrue(shareSheetExists || activityViewExists, "Share sheet should appear with PDF")
        
        // Dismiss share sheet
        if shareSheetExists {
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.waitForExistence(timeout: 2) {
                cancelButton.tap()
            } else {
                // Swipe down
                let startPoint = shareSheet.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                let endPoint = shareSheet.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
                startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
            }
        }
    }
}
