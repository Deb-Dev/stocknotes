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
    
    @State private var symbolService: SymbolService?
    @State private var snapService: SnapService?
    
    @State private var selectedSymbol: Symbol?
    @State private var showingAddSymbol = false
    @State private var showingSnap = false
    @State private var symbolToDelete: Symbol?
    
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
                                guard let snapService = snapService else { return }
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
                    if let symbol = symbolToDelete, let symbolService = symbolService {
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
                initializeServices()
                // Refresh prices periodically
                Task {
                    guard let symbolService = symbolService else { return }
                    await symbolService.updateAllPrices()
                }
            }
        }
    }
    
    private func initializeServices() {
        if symbolService == nil {
            symbolService = SymbolService(modelContext: modelContext)
            snapService = SnapService(modelContext: modelContext)
        }
    }
}

struct AddSymbolView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var symbolService: SymbolService?
    @State private var tickerInput: String = ""
    @State private var companyNameInput: String = ""
    @State private var isSearching = false
    @State private var searchResults: [SymbolSearchResult] = []
    
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
                    .disabled(tickerInput.isEmpty || symbolService == nil)
                }
            }
            .onAppear {
                initializeService()
            }
        }
    }
    
    private func initializeService() {
        if symbolService == nil {
            symbolService = SymbolService(modelContext: modelContext)
        }
    }
    
    private func searchSymbols(query: String) {
        guard let symbolService = symbolService else { return }
        
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
        guard let symbolService = symbolService else { return }
        
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
