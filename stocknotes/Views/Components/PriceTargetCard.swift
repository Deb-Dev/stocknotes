//
//  PriceTargetCard.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct PriceTargetCard: View {
    let priceTarget: PriceTarget
    let currentPrice: Double?
    let onDelete: (() -> Void)?
    
    init(priceTarget: PriceTarget, currentPrice: Double?, onDelete: (() -> Void)? = nil) {
        self.priceTarget = priceTarget
        self.currentPrice = currentPrice
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "$%.2f", priceTarget.targetPrice))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let targetDate = priceTarget.targetDate {
                        Text("Target Date: \(targetDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No target date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                statusBadge
            }
            
            if let currentPrice = currentPrice {
                HStack {
                    Text("Current: \(String(format: "$%.2f", currentPrice))")
                        .font(.subheadline)
                    
                    if let accuracy = priceTarget.accuracyPercentage(currentPrice: currentPrice) {
                        Text(String(format: "(%.1f%%)", accuracy))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(accuracy >= 0 ? .green : .red)
                    }
                }
            }
            
            if !priceTarget.thesisRationale.isEmpty {
                Text(priceTarget.thesisRationale)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statusBadge: some View {
        let status = priceTarget.status(currentPrice: currentPrice)
        
        return HStack(spacing: 4) {
            Image(systemName: iconForStatus(status))
            Text(status.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colorForStatus(status).opacity(0.2))
        .foregroundColor(colorForStatus(status))
        .cornerRadius(8)
    }
    
    private func iconForStatus(_ status: PriceTargetStatus) -> String {
        switch status {
        case .pending:
            return "clock.fill"
        case .met:
            return "checkmark.circle.fill"
        case .exceeded:
            return "arrow.up.circle.fill"
        case .missed:
            return "xmark.circle.fill"
        }
    }
    
    private func colorForStatus(_ status: PriceTargetStatus) -> Color {
        switch status {
        case .pending:
            return .gray
        case .met:
            return .green
        case .exceeded:
            return .blue
        case .missed:
            return .red
        }
    }
}

#Preview {
    let target = PriceTarget(
        targetPrice: 150.0,
        targetDate: Date().addingTimeInterval(86400 * 30),
        thesisRationale: "Based on technical analysis and support levels"
    )
    
    return PriceTargetCard(
        priceTarget: target,
        currentPrice: 145.50,
        onDelete: nil
    )
    .padding()
}
