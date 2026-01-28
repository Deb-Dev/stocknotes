//
//  HomeView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdDate, order: .reverse) private var allNotes: [Note]
    @Query(sort: \Symbol.ticker) private var allSymbols: [Symbol]
    @Query(sort: \Tag.name) private var allTags: [Tag]
    
    @State private var noteService: NoteService?
    @State private var symbolService: SymbolService?
    @State private var snapService: SnapService?
    
    @State private var showingNewNote = false
    @State private var showingQuickSnap = false
    @State private var selectedNote: Note?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Section
                    statsSection
                    
                    // Tag Cloud
                    if !allTags.isEmpty {
                        tagCloudSection
                    }
                    
                    // Recent Notes
                    RecentNotesList(notes: Array(allNotes.prefix(10))) { note in
                        selectedNote = note
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Stock Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingNewNote = true }) {
                            Label("New Note", systemImage: "square.and.pencil")
                        }
                        Button(action: { showingQuickSnap = true }) {
                            Label("Quick Snap", systemImage: "camera.fill")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingNewNote) {
                NoteEditorView()
            }
            .sheet(isPresented: $showingQuickSnap) {
                QuickSnapView()
            }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
            }
            .onAppear {
                // Update services with actual modelContext
                updateServices()
            }
        }
    }
    
    private var statsSection: some View {
        let totalNotes = allNotes.count
        let totalSymbols = allSymbols.count
        let notesThisMonth = allNotes.filter { note in
            Calendar.current.isDate(note.createdDate, equalTo: Date(), toGranularity: .month)
        }.count
        
        return HStack(spacing: 12) {
            StatsCard(
                title: "Total Notes",
                value: "\(totalNotes)",
                icon: "note.text"
            )
            
            StatsCard(
                title: "Symbols",
                value: "\(totalSymbols)",
                icon: "chart.line.uptrend.xyaxis"
            )
            
            StatsCard(
                title: "This Month",
                value: "\(notesThisMonth)",
                icon: "calendar"
            )
        }
        .padding(.horizontal)
    }
    
    private var tagCloudSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Tags")
                .font(.headline)
                .padding(.horizontal)
            
            let popularTags = allTags.sorted { ($0.noteCount) > ($1.noteCount) }.prefix(10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(popularTags), id: \.id) { tag in
                        NavigationLink(destination: TagView(tag: tag)) {
                            VStack(spacing: 4) {
                                Text("#\(tag.name)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("\(tag.noteCount)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func updateServices() {
        // Initialize services with actual modelContext
        if noteService == nil {
            noteService = NoteService(modelContext: modelContext)
            symbolService = SymbolService(modelContext: modelContext)
            snapService = SnapService(modelContext: modelContext)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(AppDataModel.sharedModelContainer)
}
