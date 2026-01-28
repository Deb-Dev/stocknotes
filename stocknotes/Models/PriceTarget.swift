//
//  PriceTarget.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData

enum PriceTargetStatus: String, Codable {
    case pending = "Pending"
    case met = "Met"
    case exceeded = "Exceeded"
    case missed = "Missed"
}

@Model
final class PriceTarget {
    var id: UUID
    var targetPrice: Double
    var targetDate: Date?
    var thesisRationale: String
    var createdDate: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Symbol.priceTargets)
    var symbol: Symbol?
    
    @Relationship(deleteRule: .nullify)
    var note: Note?
    
    init(
        id: UUID = UUID(),
        targetPrice: Double,
        targetDate: Date? = nil,
        thesisRationale: String = "",
        symbol: Symbol? = nil,
        note: Note? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.targetPrice = targetPrice
        self.targetDate = targetDate
        self.thesisRationale = thesisRationale
        self.symbol = symbol
        self.note = note
        self.createdDate = createdDate
    }
    
    // Calculate status based on current price and target date
    func status(currentPrice: Double?) -> PriceTargetStatus {
        guard let currentPrice = currentPrice else {
            return .pending
        }
        
        let isDateReached = targetDate == nil || Date() >= targetDate!
        
        if !isDateReached {
            return .pending
        }
        
        let difference = currentPrice - targetPrice
        let percentDifference = abs(difference / targetPrice) * 100
        
        // Consider "met" if within 2% of target
        if percentDifference <= 2.0 {
            return .met
        } else if currentPrice > targetPrice {
            return .exceeded
        } else {
            return .missed
        }
    }
    
    // Calculate accuracy percentage
    func accuracyPercentage(currentPrice: Double?) -> Double? {
        guard let currentPrice = currentPrice else {
            return nil
        }
        
        let difference = currentPrice - targetPrice
        return (difference / targetPrice) * 100
    }
}
