//
//  SymbolAutocompleteView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct SymbolAutocompleteView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var symbolService: SymbolService?
    
    @Binding var selectedSymbol: Symbol?
    @State private var searchText: String = ""
    @State private var searchResults: [SymbolSearchResult] = []
    @State private var isSearching = false
    
    init(selectedSymbol: Binding<Symbol?>) {
        _selectedSymbol = selectedSymbol
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Search symbol (e.g., AAPL)", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.allCharacters)
                    .onChange(of: searchText) { oldValue, newValue in
                        performSearch(query: newValue)
                    }
                
                if let symbol = selectedSymbol {
                    Button(action: { selectedSymbol = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let symbol = selectedSymbol {
                HStack {
                    Text(symbol.ticker)
                        .fontWeight(.semibold)
                    if !symbol.companyName.isEmpty {
                        Text("• \(symbol.companyName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            if !searchText.isEmpty {
                if isSearching {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Searching...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                } else if !searchResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(searchResults, id: \.symbol) { result in
                                Button(action: {
                                    selectSymbol(result)
                                }) {
                                    HStack {
                                        Text(result.symbol)
                                            .fontWeight(.semibold)
                                        Text(result.companyName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
        .onAppear {
            initializeService()
        }
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        // Ensure service is initialized
        if symbolService == nil {
            symbolService = SymbolService(modelContext: modelContext)
        }
        
        guard let symbolService = symbolService else {
            searchResults = []
            isSearching = false
            return
        }
        
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
        // Ensure service is initialized
        if symbolService == nil {
            symbolService = SymbolService(modelContext: modelContext)
        }
        
        guard let symbolService = symbolService else { return }
        
        selectedSymbol = symbolService.addOrGetSymbol(
            ticker: result.symbol,
            companyName: result.companyName
        )
        searchText = ""
        searchResults = []
        isSearching = false
    }
    
    private func initializeService() {
        if symbolService == nil {
            symbolService = SymbolService(modelContext: modelContext)
        }
    }
}

#Preview {
    SymbolAutocompleteView(selectedSymbol: .constant(nil))
        .padding()
        .modelContainer(AppDataModel.sharedModelContainer)
}
