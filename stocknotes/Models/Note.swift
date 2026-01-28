//
//  Note.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var content: String
    var createdDate: Date
    var lastEditedDate: Date
    var isSnap: Bool
    var conviction: Int? // 1-10 scale
    var sentimentRawValue: String? // Store sentiment as String for SwiftData
    
    @Relationship(deleteRule: .nullify, inverse: \Symbol.notes)
    var symbol: Symbol?
    
    @Relationship(deleteRule: .nullify)
    var tags: [Tag]?
    
    @Relationship(deleteRule: .nullify)
    var templateData: TemplateData?
    
    var images: [Data]?
    
    init(
        id: UUID = UUID(),
        content: String = "",
        symbol: Symbol? = nil,
        tags: [Tag]? = nil,
        createdDate: Date = Date(),
        lastEditedDate: Date = Date(),
        isSnap: Bool = false,
        images: [Data]? = nil,
        conviction: Int? = nil,
        sentiment: Sentiment? = nil
    ) {
        self.id = id
        self.content = content
        self.symbol = symbol
        self.tags = tags ?? []
        self.createdDate = createdDate
        self.lastEditedDate = lastEditedDate
        self.isSnap = isSnap
        self.images = images ?? []
        self.conviction = conviction
        self.sentimentRawValue = sentiment?.rawValue
    }
    
    // Convenience property for sentiment
    var sentiment: Sentiment? {
        get {
            guard let rawValue = sentimentRawValue else { return nil }
            return Sentiment(rawValue: rawValue)
        }
        set {
            sentimentRawValue = newValue?.rawValue
        }
    }
    
    // Helper to validate content length (5000 char limit)
    func updateContent(_ newContent: String) {
        let trimmed = String(newContent.prefix(5000))
        self.content = trimmed
        self.lastEditedDate = Date()
    }
    
    // Helper to add image (max 3 for free tier)
    func addImage(_ imageData: Data, maxImages: Int = 3) -> Bool {
        if images == nil {
            images = []
        }
        if let currentImages = images, currentImages.count < maxImages {
            images?.append(imageData)
            self.lastEditedDate = Date()
            return true
        }
        return false
    }
    
    // Helper to remove image
    func removeImage(at index: Int) {
        guard let currentImages = images, index < currentImages.count else { return }
        images?.remove(at: index)
        self.lastEditedDate = Date()
    }
}
