//
//  SentimentSelectorView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct SentimentSelectorView: View {
    @Binding var sentiment: Sentiment?
    let autoDetectedSentiment: Sentiment?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Sentiment")
                    .font(.headline)
                Spacer()
                if let autoDetected = autoDetectedSentiment, sentiment == nil {
                    Button("Use: \(autoDetected.displayName)") {
                        sentiment = autoDetected
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            Picker("Sentiment", selection: $sentiment) {
                Text("None").tag(nil as Sentiment?)
                ForEach(Sentiment.allCases, id: \.self) { sentimentOption in
                    HStack {
                        Image(systemName: sentimentOption.icon)
                        Text(sentimentOption.displayName)
                    }
                    .tag(sentimentOption as Sentiment?)
                }
            }
            .pickerStyle(.segmented)
            
            if let selectedSentiment = sentiment {
                HStack {
                    Image(systemName: selectedSentiment.icon)
                        .foregroundColor(colorForSentiment(selectedSentiment))
                    Text(selectedSentiment.displayName)
                        .font(.subheadline)
                        .foregroundColor(colorForSentiment(selectedSentiment))
                }
                .padding(.top, 4)
            }
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
    SentimentSelectorView(
        sentiment: .constant(.bullish),
        autoDetectedSentiment: .bullish
    )
    .padding()
}
