//
//  Tag.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData

@Model
final class Tag {
    @Attribute(.unique) var name: String
    
    @Relationship(deleteRule: .nullify)
    var notes: [Note]?
    
    init(name: String, notes: [Note]? = nil) {
        self.name = name.lowercased() // Normalize to lowercase
        self.notes = notes ?? []
    }
    
    // Helper to get note count
    var noteCount: Int {
        notes?.count ?? 0
    }
}
