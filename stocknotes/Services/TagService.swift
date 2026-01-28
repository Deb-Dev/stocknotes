//
//  TagService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData
import Combine

@MainActor
class TagService: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Get or create tag
    func getOrCreateTag(name: String) -> Tag {
        let normalizedName = name.lowercased().trimmingCharacters(in: .whitespaces)
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate<Tag> { $0.name == normalizedName }
        )
        
        do {
            if let existingTag = try modelContext.fetch(descriptor).first {
                return existingTag
            }
            
            let tag = Tag(name: normalizedName)
            modelContext.insert(tag)
            try modelContext.save()
            return tag
        } catch {
            print("Error getting/creating tag: \(error)")
            return Tag(name: normalizedName)
        }
    }
    
    // Get all tags
    func getAllTags() -> [Tag] {
        let descriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching tags: \(error)")
            return []
        }
    }
    
    // Get suggested tags (most used tags)
    func getSuggestedTags(limit: Int = 10) -> [Tag] {
        let descriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            let allTags = try modelContext.fetch(descriptor)
            return Array(allTags.sorted { ($0.noteCount) > ($1.noteCount) }.prefix(limit))
        } catch {
            print("Error fetching suggested tags: \(error)")
            return []
        }
    }
    
    // Search tags (autocomplete)
    func searchTags(query: String) -> [Tag] {
        let lowercasedQuery = query.lowercased()
        let descriptor = FetchDescriptor<Tag>()
        
        do {
            let allTags = try modelContext.fetch(descriptor)
            return allTags.filter { tag in
                tag.name.contains(lowercasedQuery)
            }.sorted { $0.noteCount > $1.noteCount }
        } catch {
            print("Error searching tags: \(error)")
            return []
        }
    }
    
    // Add tag to note
    func addTag(_ tag: Tag, to note: Note) {
        if note.tags == nil {
            note.tags = []
        }
        
        if !(note.tags?.contains(where: { $0.name == tag.name }) ?? false) {
            note.tags?.append(tag)
            note.lastEditedDate = Date()
            save()
        }
    }
    
    // Remove tag from note
    func removeTag(_ tag: Tag, from note: Note) {
        note.tags?.removeAll { $0.name == tag.name }
        note.lastEditedDate = Date()
        save()
    }
    
    // Delete tag (removes from all notes)
    func deleteTag(_ tag: Tag) {
        modelContext.delete(tag)
        save()
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving tag: \(error)")
        }
    }
}
