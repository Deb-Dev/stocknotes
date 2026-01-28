//
//  PriceTargetsView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct PriceTargetsView: View {
    @Environment(\.modelContext) private var modelContext
    
    let symbol: Symbol
    @State private var priceTargetService: PriceTargetService?
    @State private var priceTargets: [PriceTarget] = []
    @State private var isRefreshingPrice = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Current price info
                    if let currentPrice = symbol.currentPrice {
                        VStack(spacing: 8) {
                            Text("Current Price")
                                .font(.headline)
                            Text(String(format: "$%.2f", currentPrice))
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Button(action: refreshPrice) {
                                HStack {
                                    if isRefreshingPrice {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                    }
                                    Text("Refresh Price")
                                }
                            }
                            .disabled(isRefreshingPrice)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Accuracy stats
                    if let stats = getAccuracyStats() {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Accuracy Statistics")
                                .font(.headline)
                            
                            HStack {
                                StatItem(label: "Met", value: "\(stats.met)", color: .green)
                                StatItem(label: "Exceeded", value: "\(stats.exceeded)", color: .blue)
                                StatItem(label: "Missed", value: "\(stats.missed)", color: .red)
                                StatItem(label: "Pending", value: "\(stats.pending)", color: .gray)
                            }
                            
                            if let avgAccuracy = stats.averageAccuracy {
                                Text("Average Accuracy: \(String(format: "%.1f%%", avgAccuracy))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Price targets list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Price Targets (\(priceTargets.count))")
                            .font(.headline)
                        
                        if priceTargets.isEmpty {
                            ContentUnavailableView(
                                "No Price Targets",
                                systemImage: "target",
                                description: Text("Add price targets from notes or create them here")
                            )
                            .frame(height: 200)
                        } else {
                            ForEach(priceTargets) { target in
                                PriceTargetCard(
                                    priceTarget: target,
                                    currentPrice: symbol.currentPrice,
                                    onDelete: {
                                        deletePriceTarget(target)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Price Targets")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                initializeService()
                loadPriceTargets()
            }
        }
    }
    
    private func initializeService() {
        if priceTargetService == nil {
            priceTargetService = PriceTargetService(modelContext: modelContext)
        }
    }
    
    private func loadPriceTargets() {
        guard let service = priceTargetService else { return }
        priceTargets = service.getPriceTargets(for: symbol)
    }
    
    private func deletePriceTarget(_ target: PriceTarget) {
        priceTargetService?.deletePriceTarget(target)
        loadPriceTargets()
    }
    
    private func refreshPrice() {
        // This would typically refresh from Yahoo Finance
        // For now, just reload targets to update status
        loadPriceTargets()
    }
    
    private func getAccuracyStats() -> (met: Int, exceeded: Int, missed: Int, pending: Int, averageAccuracy: Double?)? {
        guard let service = priceTargetService else { return nil }
        return service.getAccuracyStats(for: symbol, currentPrice: symbol.currentPrice)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let container = AppDataModel.sharedModelContainer
    let symbol = Symbol(ticker: "AAPL", companyName: "Apple Inc.", currentPrice: 175.50)
    
    return PriceTargetsView(symbol: symbol)
        .modelContainer(container)
}
