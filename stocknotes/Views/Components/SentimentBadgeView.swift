//
//  SentimentBadgeView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct SentimentBadgeView: View {
    let sentiment: Sentiment?
    
    var body: some View {
        if let sentiment = sentiment {
            HStack(spacing: 4) {
                Image(systemName: sentiment.icon)
                    .font(.caption2)
                Text(sentiment.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(colorForSentiment(sentiment).opacity(0.2))
            .foregroundColor(colorForSentiment(sentiment))
            .cornerRadius(6)
        }
    }
    
    private func colorForSentiment(_ sentiment: Sentiment) -> Color {
        switch sentiment {
        case .bullish:
            return .green
        case .bearish:
            return .red
        case .neutral:
            return .gray
        }
    }
}

#Preview {
    HStack {
        SentimentBadgeView(sentiment: .bullish)
        SentimentBadgeView(sentiment: .bearish)
        SentimentBadgeView(sentiment: .neutral)
    }
    .padding()
}
