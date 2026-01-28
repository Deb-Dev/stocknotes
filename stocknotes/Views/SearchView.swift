//
//  SearchView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdDate, order: .reverse) private var allNotes: [Note]
    @Query(sort: \Symbol.ticker) private var allSymbols: [Symbol]
    
    @State private var noteService: NoteService?
    @State private var symbolService: SymbolService?
    @State private var snapService: SnapService?
    
    @State private var searchText: String = ""
    @State private var searchScope: SearchScope = .notes
    @State private var selectedNote: Note?
    @State private var selectedSymbol: Symbol?
    
    enum SearchScope: String, CaseIterable {
        case notes = "Notes"
        case symbols = "Symbols"
    }
    
    var filteredNotes: [Note] {
        guard !searchText.isEmpty, let noteService = noteService else { return [] }
        return noteService.searchNotes(query: searchText)
    }
    
    var filteredSymbols: [Symbol] {
        guard !searchText.isEmpty else { return [] }
        let lowercasedQuery = searchText.lowercased()
        return allSymbols.filter { symbol in
            symbol.ticker.lowercased().contains(lowercasedQuery) ||
            symbol.companyName.lowercased().contains(lowercasedQuery)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Scope Picker
                Picker("Search Scope", selection: $searchScope) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Results
                if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search",
                        systemImage: "magnifyingglass",
                        description: Text("Search for notes or symbols")
                    )
                } else {
                    List {
                        if searchScope == .notes {
                            if filteredNotes.isEmpty {
                                ContentUnavailableView(
                                    "No Results",
                                    systemImage: "note.text",
                                    description: Text("No notes found matching '\(searchText)'")
                                )
                                .listRowSeparator(.hidden)
                            } else {
                                Section {
                                    ForEach(filteredNotes) { note in
                                        NotePreviewRow(note: note)
                                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                            .listRowSeparator(.hidden)
                                            .onTapGesture {
                                                selectedNote = note
                                            }
                                    }
                                } header: {
                                    Text("\(filteredNotes.count) note\(filteredNotes.count == 1 ? "" : "s") found")
                                }
                            }
                        } else {
                            if filteredSymbols.isEmpty {
                                ContentUnavailableView(
                                    "No Results",
                                    systemImage: "chart.line.uptrend.xyaxis",
                                    description: Text("No symbols found matching '\(searchText)'")
                                )
                                .listRowSeparator(.hidden)
                            } else {
                                Section {
                                    ForEach(filteredSymbols) { symbol in
                                        SymbolCard(
                                            symbol: symbol,
                                            onTap: {
                                                selectedSymbol = symbol
                                            },
                                            onSnap: {
                                                guard let snapService = self.snapService else { return }
                                                Task {
                                                    await snapService.createSnap(for: symbol)
                                                }
                                            },
                                            onDelete: {}
                                        )
                                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                        .listRowSeparator(.hidden)
                                    }
                                } header: {
                                    Text("\(filteredSymbols.count) symbol\(filteredSymbols.count == 1 ? "" : "s") found")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search")
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
            }
            .sheet(item: $selectedSymbol) { symbol in
                SymbolDetailView(symbol: symbol)
            }
            .onAppear {
                initializeServices()
            }
        }
    }
    
    private func initializeServices() {
        if noteService == nil {
            noteService = NoteService(modelContext: modelContext)
            symbolService = SymbolService(modelContext: modelContext)
            snapService = SnapService(modelContext: modelContext)
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(AppDataModel.sharedModelContainer)
}
