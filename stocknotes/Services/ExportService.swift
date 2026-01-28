//
//  ExportService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import PDFKit
import SwiftUI

class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    // Export all notes as PDF
    func exportAllNotes(_ notes: [Note]) -> URL? {
        return createPDF(from: notes, title: "All Stock Notes")
    }
    
    // Export notes for a single symbol as PDF
    func exportNotesForSymbol(_ notes: [Note], symbol: Symbol) -> URL? {
        return createPDF(from: notes, title: "\(symbol.ticker) - Stock Notes")
    }
    
    // Create PDF from notes (internal method)
    func createPDF(from notes: [Note], title: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Stock Notes App",
            kCGPDFContextAuthor: "Stock Notes",
            kCGPDFContextTitle: title
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 60
            let margin: CGFloat = 72
            let contentWidth = pageWidth - (margin * 2)
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            let titleRect = CGRect(x: margin, y: yPosition, width: contentWidth, height: 30)
            titleString.draw(in: titleRect)
            yPosition += 40
            
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let dateString = "Exported: \(dateFormatter.string(from: Date()))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            let dateAttrString = NSAttributedString(string: dateString, attributes: dateAttributes)
            let dateRect = CGRect(x: margin, y: yPosition, width: contentWidth, height: 20)
            dateAttrString.draw(in: dateRect)
            yPosition += 30
            
            // Notes
            for note in notes {
                // Check if we need a new page
                if yPosition > pageHeight - 200 {
                    context.beginPage()
                    yPosition = 60
                }
                
                // Symbol and Date
                var noteHeader = ""
                if let symbol = note.symbol {
                    noteHeader = "\(symbol.ticker)"
                    if !symbol.companyName.isEmpty {
                        noteHeader += " - \(symbol.companyName)"
                    }
                }
                noteHeader += " • \(dateFormatter.string(from: note.createdDate))"
                
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.blue
                ]
                let headerString = NSAttributedString(string: noteHeader, attributes: headerAttributes)
                let headerRect = CGRect(x: margin, y: yPosition, width: contentWidth, height: 20)
                headerString.draw(in: headerRect)
                yPosition += 25
                
                // Tags
                if let tags = note.tags, !tags.isEmpty {
                    let tagNames = tags.map { "#\($0.name)" }.joined(separator: " ")
                    let tagAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 10),
                        .foregroundColor: UIColor.gray
                    ]
                    let tagString = NSAttributedString(string: tagNames, attributes: tagAttributes)
                    let tagRect = CGRect(x: margin, y: yPosition, width: contentWidth, height: 15)
                    tagString.draw(in: tagRect)
                    yPosition += 20
                }
                
                // Content
                let contentAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]
                let contentString = NSAttributedString(string: note.content, attributes: contentAttributes)
                let contentRect = CGRect(x: margin, y: yPosition, width: contentWidth, height: 200)
                let boundingRect = contentString.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )
                contentString.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: boundingRect.height))
                yPosition += boundingRect.height + 30
                
                // Separator
                yPosition += 10
            }
        }
        
        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(title.replacingOccurrences(of: " ", with: "_")).pdf")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }
}
