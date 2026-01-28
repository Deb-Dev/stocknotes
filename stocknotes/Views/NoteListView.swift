//
//  NoteListView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdDate, order: .reverse) private var allNotes: [Note]
    @Query(sort: \Symbol.ticker) private var allSymbols: [Symbol]
    @Query(sort: \Tag.name) private var allTags: [Tag]
    
    @StateObject private var noteService: NoteService
    
    @State private var searchText: String = ""
    @State private var selectedSymbol: Symbol?
    @State private var selectedTag: Tag?
    @State private var sortOption: FilterBar.SortOption = .creationDate
    @State private var dateRange: FilterBar.DateRange = .all
    @State private var selectedNote: Note?
    
    init() {
        let tempContext = ModelContext(AppDataModel.sharedModelContainer)
        _noteService = StateObject(wrappedValue: NoteService(modelContext: tempContext))
    }
    
    var filteredAndSortedNotes: [Note] {
        var notes = allNotes
        
        // Apply search filter
        if !searchText.isEmpty {
            notes = noteService.searchNotes(query: searchText)
        }
        
        // Apply symbol filter
        if let symbol = selectedSymbol {
            notes = notes.filter { $0.symbol?.ticker == symbol.ticker }
        }
        
        // Apply tag filter
        if let tag = selectedTag {
            notes = notes.filter { note in
                note.tags?.contains(where: { $0.name == tag.name }) ?? false
            }
        }
        
        // Apply date range filter
        notes = filterByDateRange(notes)
        
        // Apply sorting
        notes = sortNotes(notes)
        
        return notes
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Filter Bar
                FilterBar(
                    selectedSymbol: $selectedSymbol,
                    selectedTag: $selectedTag,
                    sortOption: $sortOption,
                    dateRange: $dateRange,
                    symbols: allSymbols,
                    tags: allTags
                )
                .padding(.vertical, 8)
                
                // Notes List
                if filteredAndSortedNotes.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Notes" : "No Results",
                        systemImage: searchText.isEmpty ? "note.text" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Create your first note" : "Try adjusting your filters")
                    )
                } else {
                    List {
                        ForEach(filteredAndSortedNotes) { note in
                            NotePreviewRow(note: note)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .onTapGesture {
                                    selectedNote = note
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("All Notes")
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
            }
        }
    }
    
    private func filterByDateRange(_ notes: [Note]) -> [Note] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startDate: Date = {
            switch dateRange {
            case .all:
                return nil
            case .today:
                return calendar.startOfDay(for: now)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)
            case .month:
                return calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            case .year:
                return calendar.date(from: calendar.dateComponents([.year], from: now))
            }
        }() else {
            return notes
        }
        
        return notes.filter { $0.createdDate >= startDate }
    }
    
    private func sortNotes(_ notes: [Note]) -> [Note] {
        switch sortOption {
        case .creationDate:
            return notes.sorted { $0.createdDate > $1.createdDate }
        case .editDate:
            return notes.sorted { $0.lastEditedDate > $1.lastEditedDate }
        case .symbolName:
            return notes.sorted { (note1, note2) in
                let symbol1 = note1.symbol?.ticker ?? ""
                let symbol2 = note2.symbol?.ticker ?? ""
                return symbol1 < symbol2
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search notes...", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    NoteListView()
        .modelContainer(AppDataModel.sharedModelContainer)
}
