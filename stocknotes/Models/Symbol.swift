//
//  Symbol.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData

@Model
final class Symbol {
    @Attribute(.unique) var ticker: String
    var companyName: String
    var currentPrice: Double?
    var lastPriceUpdate: Date?
    
    @Relationship(deleteRule: .cascade)
    var notes: [Note]?
    
    init(
        ticker: String,
        companyName: String = "",
        currentPrice: Double? = nil,
        lastPriceUpdate: Date? = nil,
        notes: [Note]? = nil
    ) {
        self.ticker = ticker
        self.companyName = companyName
        self.currentPrice = currentPrice
        self.lastPriceUpdate = lastPriceUpdate
        self.notes = notes ?? []
    }
    
    // Helper to update price
    func updatePrice(_ price: Double?) {
        self.currentPrice = price
        self.lastPriceUpdate = Date()
    }
    
    // Helper to get note count
    var noteCount: Int {
        notes?.count ?? 0
    }
    
    // Helper to get latest note date
    var latestNoteDate: Date? {
        notes?.max(by: { $0.createdDate < $1.createdDate })?.createdDate
    }
}
