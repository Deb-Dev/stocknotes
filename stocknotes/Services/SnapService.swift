//
//  SnapService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData
import Combine

@MainActor
class SnapService: ObservableObject {
    private let modelContext: ModelContext
    private let noteService: NoteService
    private let symbolService: SymbolService
    private let yahooFinanceService = YahooFinanceService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.noteService = NoteService(modelContext: modelContext)
        self.symbolService = SymbolService(modelContext: modelContext)
    }
    
    // Create a quick snap note for a symbol
    func createSnap(for symbol: Symbol, additionalNote: String? = nil) async -> Note {
        // Fetch current price
        do {
            let (price, companyName) = try await yahooFinanceService.fetchPrice(for: symbol.ticker)
            
            // Update symbol with latest price
            symbol.currentPrice = price
            symbol.lastPriceUpdate = Date()
            
            if let companyName = companyName, !companyName.isEmpty {
                symbol.companyName = companyName
            }
            
            // Create snap note content
            let priceString = price != nil ? String(format: "$%.2f", price!) : "N/A"
            let timestamp = DateFormatter.snapFormatter.string(from: Date())
            
            var content = "Snap: \(symbol.ticker) @ \(priceString) - \(timestamp)"
            
            if let additionalNote = additionalNote, !additionalNote.isEmpty {
                content += "\n\n\(additionalNote)"
            }
            
            // Create note
            let note = noteService.createNote(
                content: content,
                symbol: symbol,
                isSnap: true
            )
            
            try modelContext.save()
            return note
        } catch {
            print("Error creating snap: \(error)")
            // Create note even if price fetch fails
            let timestamp = DateFormatter.snapFormatter.string(from: Date())
            let content = "Snap: \(symbol.ticker) @ N/A - \(timestamp)"
            
            return noteService.createNote(
                content: content,
                symbol: symbol,
                isSnap: true
            )
        }
    }
    
    // Create snap from ticker string
    func createSnap(for ticker: String, additionalNote: String? = nil) async -> Note? {
        let symbol = symbolService.addOrGetSymbol(ticker: ticker)
        return await createSnap(for: symbol, additionalNote: additionalNote)
    }
}

extension DateFormatter {
    static let snapFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
