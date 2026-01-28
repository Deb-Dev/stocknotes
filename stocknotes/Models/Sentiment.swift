//
//  Sentiment.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation

enum Sentiment: String, Codable, CaseIterable {
    case bullish = "Bullish"
    case bearish = "Bearish"
    case neutral = "Neutral"
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .bullish:
            return "arrow.up.circle.fill"
        case .bearish:
            return "arrow.down.circle.fill"
        case .neutral:
            return "minus.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .bullish:
            return "green"
        case .bearish:
            return "red"
        case .neutral:
            return "gray"
        }
    }
}
