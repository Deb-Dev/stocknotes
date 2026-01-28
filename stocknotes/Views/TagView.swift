//
//  TagView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct TagView: View {
    @Environment(\.modelContext) private var modelContext
    
    let tag: Tag
    @Query private var allNotes: [Note]
    
    @State private var noteService: NoteService?
    
    @State private var selectedNote: Note?
    
    private var taggedNotes: [Note] {
        allNotes.filter { note in
            note.tags?.contains(where: { $0.name == tag.name }) ?? false
        }
    }
    
    init(tag: Tag) {
        self.tag = tag
        _allNotes = Query(sort: \Note.createdDate, order: .reverse)
    }
    
    var body: some View {
        NavigationStack {
            List {
                if taggedNotes.isEmpty {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "tag",
                        description: Text("No notes tagged with #\(tag.name)")
                    )
                } else {
                    ForEach(taggedNotes) { note in
                        NotePreviewRow(note: note)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                selectedNote = note
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("#\(tag.name)")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
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
}

#Preview {
    let container = AppDataModel.sharedModelContainer
    let tag = Tag(name: "bullish")
    
    return TagView(tag: tag)
        .modelContainer(container)
}
