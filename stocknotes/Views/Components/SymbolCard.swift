//
//  SymbolCard.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct SymbolCard: View {
    let symbol: Symbol
    let onTap: () -> Void
    let onSnap: () -> Void
    let onDelete: () -> Void
    
    private var averageConviction: Int? {
        guard let notes = symbol.notes, !notes.isEmpty else { return nil }
        let convictions = notes.compactMap { $0.conviction }
        guard !convictions.isEmpty else { return nil }
        let sum = convictions.reduce(0, +)
        return Int(Double(sum) / Double(convictions.count).rounded())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(symbol.ticker)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if !symbol.companyName.isEmpty {
                        Text(symbol.companyName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(action: onSnap) {
                        Label("Quick Snap", systemImage: "camera.fill")
                    }
                    
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
            
            HStack {
                if let price = symbol.currentPrice {
                    Text(String(format: "$%.2f", price))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                } else {
                    Text("N/A")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let avgConviction = averageConviction {
                        ConvictionIndicatorView(conviction: avgConviction, size: .medium)
                    }
                    
                    Text("\(symbol.noteCount) notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let latestDate = symbol.latestNoteDate {
                        Text(latestDate, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    let symbol = Symbol(ticker: "AAPL", companyName: "Apple Inc.", currentPrice: 175.50)
    return SymbolCard(
        symbol: symbol,
        onTap: {},
        onSnap: {},
        onDelete: {}
    )
    .padding()
}
