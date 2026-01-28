//
//  NoteDetailView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var noteService: NoteService?
    
    let note: Note
    @State private var isEditing = false
    
    init(note: Note) {
        self.note = note
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Symbol info
                    if let symbol = note.symbol {
                        HStack {
                            Text(symbol.ticker)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if !symbol.companyName.isEmpty {
                                Text("• \(symbol.companyName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Tags
                    if let tags = note.tags, !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tags) { tag in
                                    Text("#\(tag.name)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Content
                    Text(note.content)
                        .font(.body)
                        .padding()
                    
                    // Timestamps
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Created: \(note.createdDate, style: .date) \(note.createdDate, style: .time)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if note.lastEditedDate != note.createdDate {
                            Text("Last edited: \(note.lastEditedDate, style: .date) \(note.lastEditedDate, style: .time)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Images
                    if let images = note.images, !images.isEmpty {
                        ImageAttachmentView(images: images)
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Note Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { isEditing = true }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: deleteNote) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                NoteEditorView(note: note)
            }
            .onAppear {
                initializeService()
            }
        }
    }
    
    private func initializeService() {
        if noteService == nil {
            noteService = NoteService(modelContext: modelContext)
        }
    }
    
    private func deleteNote() {
        guard let noteService = noteService else { return }
        noteService.deleteNote(note)
        dismiss()
    }
}

#Preview {
    let container = AppDataModel.sharedModelContainer
    let context = ModelContext(container)
    
    let symbol = Symbol(ticker: "AAPL", companyName: "Apple Inc.")
    let note = Note(content: "This is a sample note about Apple stock.", symbol: symbol)
    
    return NoteDetailView(note: note)
        .modelContainer(container)
}
