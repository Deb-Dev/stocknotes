//
//  NoteService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData
import Combine

@MainActor
class NoteService: ObservableObject {
    private let modelContext: ModelContext
    private var saveTask: Task<Void, Never>?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Create a new note
    func createNote(
        content: String = "",
        symbol: Symbol? = nil,
        tags: [Tag]? = nil,
        isSnap: Bool = false
    ) -> Note {
        let note = Note(
            content: content,
            symbol: symbol,
            tags: tags,
            isSnap: isSnap
        )
        
        modelContext.insert(note)
        save()
        return note
    }
    
    // Update note content with auto-save (debounced)
    func updateNote(_ note: Note, content: String) {
        note.updateContent(content)
        
        // Cancel previous save task
        saveTask?.cancel()
        
        // Create new debounced save task
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            if !Task.isCancelled {
                save()
            }
        }
    }
    
    // Save note immediately
    func saveNote(_ note: Note) {
        note.lastEditedDate = Date()
        save()
    }
    
    // Get all notes
    func getAllNotes() -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching notes: \(error)")
            return []
        }
    }
    
    // Get notes for a symbol
    func getNotes(for symbol: Symbol) -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            let allNotes = try modelContext.fetch(descriptor)
            return allNotes.filter { $0.symbol?.ticker == symbol.ticker }
        } catch {
            print("Error fetching notes for symbol: \(error)")
            return []
        }
    }
    
    // Get recent notes (last N)
    func getRecentNotes(limit: Int = 10) -> [Note] {
        var descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching recent notes: \(error)")
            return []
        }
    }
    
    // Get notes for a tag
    func getNotes(for tag: Tag) -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            let allNotes = try modelContext.fetch(descriptor)
            return allNotes.filter { note in
                note.tags?.contains(where: { $0.name == tag.name }) ?? false
            }
        } catch {
            print("Error fetching notes for tag: \(error)")
            return []
        }
    }
    
    // Delete note
    func deleteNote(_ note: Note) {
        modelContext.delete(note)
        save()
    }
    
    // Search notes by content
    func searchNotes(query: String) -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            let allNotes = try modelContext.fetch(descriptor)
            let lowercasedQuery = query.lowercased()
            return allNotes.filter { note in
                note.content.lowercased().contains(lowercasedQuery) ||
                note.symbol?.ticker.lowercased().contains(lowercasedQuery) ?? false ||
                note.symbol?.companyName.lowercased().contains(lowercasedQuery) ?? false
            }
        } catch {
            print("Error searching notes: \(error)")
            return []
        }
    }
    
    // Get notes count
    func getNotesCount() -> Int {
        let descriptor = FetchDescriptor<Note>()
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            print("Error counting notes: \(error)")
            return 0
        }
    }
    
    // Get notes count for this month
    func getNotesCountThisMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return 0
        }
        
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { $0.createdDate >= startOfMonth }
        )
        
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            print("Error counting notes this month: \(error)")
            return 0
        }
    }
    
    // Private save helper
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving note: \(error)")
        }
    }
}
