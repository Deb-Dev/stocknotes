//
//  ConvictionChartView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import Charts
import SwiftData

struct ConvictionChartView: View {
    let notes: [Note]
    
    private var chartData: [(date: Date, conviction: Int)] {
        notes
            .compactMap { note -> (Date, Int)? in
                guard let conviction = note.conviction else { return nil }
                return (note.createdDate, conviction)
            }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conviction Over Time")
                .font(.headline)
            
            if chartData.isEmpty {
                Text("No conviction data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                        LineMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("Conviction", data.conviction)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("Conviction", data.conviction)
                        )
                        .foregroundStyle(convictionColor(data.conviction))
                        .symbolSize(60)
                    }
                    
                    // Add reference lines for conviction zones
                    RuleMark(y: .value("Low", 3))
                        .foregroundStyle(.red.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    RuleMark(y: .value("Medium", 7))
                        .foregroundStyle(.yellow.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    RuleMark(y: .value("High", 10))
                        .foregroundStyle(.green.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
                .chartYScale(domain: 1...10)
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
            }
            
            // Legend
            HStack(spacing: 16) {
                LegendItem(color: .red, label: "Low (1-3)")
                LegendItem(color: .yellow, label: "Medium (4-7)")
                LegendItem(color: .green, label: "High (8-10)")
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func convictionColor(_ value: Int) -> Color {
        switch value {
        case 1...3:
            return .red
        case 4...7:
            return .yellow
        case 8...10:
            return .green
        default:
            return .gray
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let container = AppDataModel.sharedModelContainer
    let context = ModelContext(container)
    
    let symbol = Symbol(ticker: "AAPL", companyName: "Apple Inc.")
    let notes = [
        Note(content: "Note 1", symbol: symbol, conviction: 5),
        Note(content: "Note 2", symbol: symbol, conviction: 7),
        Note(content: "Note 3", symbol: symbol, conviction: 9)
    ]
    
    ConvictionChartView(notes: notes)
        .padding()
}
