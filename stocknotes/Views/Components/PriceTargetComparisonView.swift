//
//  PriceTargetComparisonView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import Charts

struct PriceTargetComparisonView: View {
    let priceTargets: [PriceTarget]
    let currentPrice: Double?
    
    private var chartData: [(date: Date, targetPrice: Double, status: PriceTargetStatus)] {
        priceTargets
            .map { target in
                (target.createdDate, target.targetPrice, target.status(currentPrice: currentPrice))
            }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Target Comparison")
                .font(.headline)
            
            if chartData.isEmpty {
                Text("No price targets available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else if currentPrice == nil {
                Text("Current price not available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    // Current price line
                    RuleMark(y: .value("Current Price", currentPrice!))
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Current: $\(String(format: "%.2f", currentPrice!))")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    
                    // Target prices
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                        PointMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("Target Price", data.targetPrice)
                        )
                        .foregroundStyle(colorForStatus(data.status))
                        .symbolSize(80)
                        
                        // Connect points with line
                        if index < chartData.count - 1 {
                            LineMark(
                                x: .value("Date", data.date, unit: .day),
                                y: .value("Target Price", data.targetPrice)
                            )
                            .foregroundStyle(.gray.opacity(0.3))
                            .interpolationMethod(.linear)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
                
                // Status summary
                HStack(spacing: 16) {
                    StatusItem(status: .met, count: chartData.filter { $0.status == .met }.count)
                    StatusItem(status: .exceeded, count: chartData.filter { $0.status == .exceeded }.count)
                    StatusItem(status: .missed, count: chartData.filter { $0.status == .missed }.count)
                    StatusItem(status: .pending, count: chartData.filter { $0.status == .pending }.count)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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

struct StatusItem: View {
    let status: PriceTargetStatus
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(colorForStatus(status))
                .frame(width: 8, height: 8)
            Text("\(status.rawValue): \(count)")
                .foregroundColor(.secondary)
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
    let container = AppDataModel.sharedModelContainer
    let symbol = Symbol(ticker: "AAPL", companyName: "Apple Inc.", currentPrice: 175.50)
    
    let targets = [
        PriceTarget(targetPrice: 150.0, symbol: symbol),
        PriceTarget(targetPrice: 160.0, symbol: symbol),
        PriceTarget(targetPrice: 180.0, symbol: symbol)
    ]
    
    return PriceTargetComparisonView(
        priceTargets: targets,
        currentPrice: 175.50
    )
    .padding()
}
