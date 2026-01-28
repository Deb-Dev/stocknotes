//
//  SymbolListView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct SymbolListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Symbol.ticker) private var symbols: [Symbol]
    
    @StateObject private var symbolService: SymbolService
    @StateObject private var snapService: SnapService
    
    @State private var selectedSymbol: Symbol?
    @State private var showingAddSymbol = false
    @State private var showingSnap = false
    @State private var symbolToDelete: Symbol?
    
    init() {
        let tempContext = ModelContext(AppDataModel.sharedModelContainer)
        _symbolService = StateObject(wrappedValue: SymbolService(modelContext: tempContext))
        _snapService = StateObject(wrappedValue: SnapService(modelContext: tempContext))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if symbols.isEmpty {
                    ContentUnavailableView(
                        "No Symbols",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Add symbols to start tracking stocks")
                    )
                } else {
                    ForEach(symbols) { symbol in
                        SymbolCard(
                            symbol: symbol,
                            onTap: {
                                selectedSymbol = symbol
                            },
                            onSnap: {
                                Task {
                                    await snapService.createSnap(for: symbol)
                                }
                            },
                            onDelete: {
                                symbolToDelete = symbol
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Symbols")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSymbol = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(item: $selectedSymbol) { symbol in
                SymbolDetailView(symbol: symbol)
            }
            .sheet(isPresented: $showingAddSymbol) {
                AddSymbolView()
            }
            .alert("Delete Symbol", isPresented: .constant(symbolToDelete != nil)) {
                Button("Cancel", role: .cancel) {
                    symbolToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let symbol = symbolToDelete {
                        symbolService.deleteSymbol(symbol)
                        symbolToDelete = nil
                    }
                }
            } message: {
                if let symbol = symbolToDelete {
                    Text("Are you sure you want to delete \(symbol.ticker)? This will also delete all associated notes.")
                }
            }
            .onAppear {
                updateServices()
                // Refresh prices periodically
                Task {
                    await symbolService.updateAllPrices()
                }
            }
        }
    }
    
    private func updateServices() {
        // Services will use environment modelContext
    }
}

struct AddSymbolView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var symbolService: SymbolService
    @State private var tickerInput: String = ""
    @State private var companyNameInput: String = ""
    @State private var isSearching = false
    @State private var searchResults: [SymbolSearchResult] = []
    
    init() {
        let tempContext = ModelContext(AppDataModel.sharedModelContainer)
        _symbolService = StateObject(wrappedValue: SymbolService(modelContext: tempContext))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Symbol Ticker") {
                    TextField("e.g., AAPL or XYZ.TO", text: $tickerInput)
                        .autocapitalization(.allCharacters)
                        .onChange(of: tickerInput) { oldValue, newValue in
                            if !newValue.isEmpty {
                                searchSymbols(query: newValue)
                            } else {
                                searchResults = []
                            }
                        }
                }
                
                if !searchResults.isEmpty {
                    Section("Search Results") {
                        ForEach(searchResults, id: \.symbol) { result in
                            Button(action: {
                                selectSymbol(result)
                            }) {
                                VStack(alignment: .leading) {
                                    Text(result.symbol)
                                        .fontWeight(.semibold)
                                    Text(result.companyName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Section("Or Add Custom Symbol") {
                    TextField("Company Name (optional)", text: $companyNameInput)
                }
            }
            .navigationTitle("Add Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addSymbol()
                    }
                    .disabled(tickerInput.isEmpty)
                }
            }
        }
    }
    
    private func searchSymbols(query: String) {
        isSearching = true
        Task {
            let results = await symbolService.searchSymbols(query: query)
            await MainActor.run {
                searchResults = results
                isSearching = false
            }
        }
    }
    
    private func selectSymbol(_ result: SymbolSearchResult) {
        tickerInput = result.symbol
        companyNameInput = result.companyName
        searchResults = []
    }
    
    private func addSymbol() {
        let symbol = symbolService.addOrGetSymbol(
            ticker: tickerInput,
            companyName: companyNameInput.isEmpty ? nil : companyNameInput
        )
        
        // Fetch price for new symbol
        Task {
            await symbolService.fetchPrice(for: symbol)
        }
        
        dismiss()
    }
}

#Preview {
    SymbolListView()
        .modelContainer(AppDataModel.sharedModelContainer)
}
