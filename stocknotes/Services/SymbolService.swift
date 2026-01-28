//
//  SymbolService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData
import Combine

@MainActor
class SymbolService: ObservableObject {
    let modelContext: ModelContext
    private let yahooFinanceService = YahooFinanceService.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Fetch all symbols
    func getAllSymbols() -> [Symbol] {
        let descriptor = FetchDescriptor<Symbol>(
            sortBy: [SortDescriptor(\.ticker)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching symbols: \(error)")
            return []
        }
    }
    
    // Add or get symbol
    func addOrGetSymbol(ticker: String, companyName: String? = nil) -> Symbol {
        let upperTicker = ticker.uppercased()
        let descriptor = FetchDescriptor<Symbol>(
            predicate: #Predicate<Symbol> { $0.ticker == upperTicker }
        )
        
        do {
            if let existingSymbol = try modelContext.fetch(descriptor).first {
                return existingSymbol
            }
            
            let symbol = Symbol(
                ticker: upperTicker,
                companyName: companyName ?? ""
            )
            modelContext.insert(symbol)
            try modelContext.save()
            return symbol
        } catch {
            print("Error adding symbol: \(error)")
            // Return a new symbol even if save fails (for UI purposes)
            return Symbol(ticker: upperTicker, companyName: companyName ?? "")
        }
    }
    
    // Fetch price for symbol
    func fetchPrice(for symbol: Symbol) async {
        do {
            let (price, companyName) = try await yahooFinanceService.fetchPrice(for: symbol.ticker)
            
            symbol.currentPrice = price
            symbol.lastPriceUpdate = Date()
            
            if let companyName = companyName, companyName.isEmpty == false {
                symbol.companyName = companyName
            }
            
            try modelContext.save()
        } catch {
            print("Error fetching price for \(symbol.ticker): \(error)")
        }
    }
    
    // Update prices for all symbols
    func updateAllPrices() async {
        let symbols = getAllSymbols()
        
        await withTaskGroup(of: Void.self) { group in
            for symbol in symbols {
                group.addTask {
                    await self.fetchPrice(for: symbol)
                }
            }
        }
    }
    
    // Delete symbol
    func deleteSymbol(_ symbol: Symbol) {
        modelContext.delete(symbol)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting symbol: \(error)")
        }
    }
    
    // Search symbols using Yahoo Finance
    func searchSymbols(query: String) async -> [SymbolSearchResult] {
        do {
            return try await yahooFinanceService.searchSymbols(query: query)
        } catch {
            print("Error searching symbols: \(error)")
            return []
        }
    }
}
