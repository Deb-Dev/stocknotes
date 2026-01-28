//
//  PriceTargetService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData
import Combine

@MainActor
class PriceTargetService: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Create a new price target
    func createPriceTarget(
        targetPrice: Double,
        targetDate: Date? = nil,
        thesisRationale: String = "",
        symbol: Symbol? = nil,
        note: Note? = nil
    ) -> PriceTarget {
        let priceTarget = PriceTarget(
            targetPrice: targetPrice,
            targetDate: targetDate,
            thesisRationale: thesisRationale,
            symbol: symbol,
            note: note
        )
        
        modelContext.insert(priceTarget)
        save()
        return priceTarget
    }
    
    // Get all price targets for a symbol
    func getPriceTargets(for symbol: Symbol) -> [PriceTarget] {
        let descriptor = FetchDescriptor<PriceTarget>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            let allTargets = try modelContext.fetch(descriptor)
            return allTargets.filter { $0.symbol?.ticker == symbol.ticker }
        } catch {
            print("Error fetching price targets: \(error)")
            return []
        }
    }
    
    // Get all price targets
    func getAllPriceTargets() -> [PriceTarget] {
        let descriptor = FetchDescriptor<PriceTarget>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching price targets: \(error)")
            return []
        }
    }
    
    // Update price target
    func updatePriceTarget(
        _ priceTarget: PriceTarget,
        targetPrice: Double? = nil,
        targetDate: Date?? = nil,
        thesisRationale: String? = nil
    ) {
        if let price = targetPrice {
            priceTarget.targetPrice = price
        }
        if let date = targetDate {
            priceTarget.targetDate = date
        }
        if let rationale = thesisRationale {
            priceTarget.thesisRationale = rationale
        }
        save()
    }
    
    // Delete price target
    func deletePriceTarget(_ priceTarget: PriceTarget) {
        modelContext.delete(priceTarget)
        save()
    }
    
    // Calculate accuracy statistics for a symbol
    func getAccuracyStats(for symbol: Symbol, currentPrice: Double?) -> (met: Int, exceeded: Int, missed: Int, pending: Int, averageAccuracy: Double?) {
        let targets = getPriceTargets(for: symbol)
        
        var met = 0
        var exceeded = 0
        var missed = 0
        var pending = 0
        var accuracies: [Double] = []
        
        for target in targets {
            let status = target.status(currentPrice: currentPrice)
            switch status {
            case .met:
                met += 1
            case .exceeded:
                exceeded += 1
            case .missed:
                missed += 1
            case .pending:
                pending += 1
            }
            
            if let accuracy = target.accuracyPercentage(currentPrice: currentPrice) {
                accuracies.append(abs(accuracy))
            }
        }
        
        let averageAccuracy = accuracies.isEmpty ? nil : accuracies.reduce(0, +) / Double(accuracies.count)
        
        return (met, exceeded, missed, pending, averageAccuracy)
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving price target: \(error)")
        }
    }
}
