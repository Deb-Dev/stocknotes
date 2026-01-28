//
//  SentimentAnalysisService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation

class SentimentAnalysisService {
    static let shared = SentimentAnalysisService()
    
    private let bullishKeywords = [
        "bullish", "buy", "long", "positive", "upside", "growth", "opportunity",
        "undervalued", "strong", "momentum", "breakout", "rally", "surge",
        "outperform", "upgrade", "target", "price target", "recommendation"
    ]
    
    private let bearishKeywords = [
        "bearish", "sell", "short", "negative", "downside", "decline", "risk",
        "overvalued", "weak", "breakdown", "crash", "drop", "fall",
        "underperform", "downgrade", "avoid", "concern", "warning"
    ]
    
    private init() {}
    
    // Analyze text and return suggested sentiment
    func analyzeSentiment(from text: String) -> Sentiment? {
        let lowercasedText = text.lowercased()
        
        var bullishCount = 0
        var bearishCount = 0
        
        for keyword in bullishKeywords {
            if lowercasedText.contains(keyword) {
                bullishCount += 1
            }
        }
        
        for keyword in bearishKeywords {
            if lowercasedText.contains(keyword) {
                bearishCount += 1
            }
        }
        
        if bullishCount > bearishCount && bullishCount > 0 {
            return .bullish
        } else if bearishCount > bullishCount && bearishCount > 0 {
            return .bearish
        } else if bullishCount == bearishCount && bullishCount > 0 {
            return .neutral
        }
        
        return nil // No clear sentiment detected
    }
}
