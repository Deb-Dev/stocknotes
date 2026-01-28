//
//  QuickSnapView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct QuickSnapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var symbolService: SymbolService
    @StateObject private var snapService: SnapService
    
    @State private var selectedSymbol: Symbol?
    @State private var searchText: String = ""
    @State private var searchResults: [SymbolSearchResult] = []
    @State private var additionalNote: String = ""
    @State private var isCreatingSnap = false
    
    init(initialSymbol: Symbol? = nil) {
        _selectedSymbol = State(initialValue: initialSymbol)
        let tempContext = ModelContext(AppDataModel.sharedModelContainer)
        _symbolService = StateObject(wrappedValue: SymbolService(modelContext: tempContext))
        _snapService = StateObject(wrappedValue: SnapService(modelContext: tempContext))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Symbol") {
                    if let symbol = selectedSymbol {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(symbol.ticker)
                                    .fontWeight(.semibold)
                                if !symbol.companyName.isEmpty {
                                    Text(symbol.companyName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button(action: { selectedSymbol = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        TextField("Search symbol", text: $searchText)
                            .autocapitalization(.allCharacters)
                            .onChange(of: searchText) { oldValue, newValue in
                                if !newValue.isEmpty {
                                    searchSymbols(query: newValue)
                                } else {
                                    searchResults = []
                                }
                            }
                        
                        if !searchResults.isEmpty {
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
                }
                
                Section("Additional Note (Optional)") {
                    TextEditor(text: $additionalNote)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Quick Snap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Snap") {
                        createSnap()
                    }
                    .disabled(selectedSymbol == nil || isCreatingSnap)
                }
            }
            .overlay {
                if isCreatingSnap {
                    ProgressView("Creating snap...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        }
    }
    
    private func searchSymbols(query: String) {
        Task {
            let results = await symbolService.searchSymbols(query: query)
            await MainActor.run {
                searchResults = results
            }
        }
    }
    
    private func selectSymbol(_ result: SymbolSearchResult) {
        selectedSymbol = symbolService.addOrGetSymbol(
            ticker: result.symbol,
            companyName: result.companyName
        )
        searchText = ""
        searchResults = []
    }
    
    private func createSnap() {
        guard let symbol = selectedSymbol else { return }
        
        isCreatingSnap = true
        
        Task {
            await snapService.createSnap(
                for: symbol,
                additionalNote: additionalNote.isEmpty ? nil : additionalNote
            )
            
            await MainActor.run {
                isCreatingSnap = false
                dismiss()
            }
        }
    }
}

#Preview {
    QuickSnapView()
        .modelContainer(AppDataModel.sharedModelContainer)
}
