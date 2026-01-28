//
//  BackupService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData

struct BackupData: Codable {
    let notes: [NoteBackup]
    let symbols: [SymbolBackup]
    let tags: [TagBackup]
    let version: String
    let exportDate: Date
}

struct NoteBackup: Codable {
    let id: UUID
    let content: String
    let symbolTicker: String?
    let tagNames: [String]
    let createdDate: Date
    let lastEditedDate: Date
    let isSnap: Bool
    let images: [Data]?
}

struct SymbolBackup: Codable {
    let ticker: String
    let companyName: String
    let currentPrice: Double?
    let lastPriceUpdate: Date?
}

struct TagBackup: Codable {
    let name: String
}

class BackupService {
    static let shared = BackupService()
    
    private init() {}
    
    // Export all data as JSON
    func exportBackup(modelContext: ModelContext) -> Data? {
        // Fetch all data
        let notesDescriptor = FetchDescriptor<Note>()
        let symbolsDescriptor = FetchDescriptor<Symbol>()
        let tagsDescriptor = FetchDescriptor<Tag>()
        
        guard let notes = try? modelContext.fetch(notesDescriptor),
              let symbols = try? modelContext.fetch(symbolsDescriptor),
              let tags = try? modelContext.fetch(tagsDescriptor) else {
            return nil
        }
        
        // Convert to backup structures
        let noteBackups = notes.map { note in
            NoteBackup(
                id: note.id,
                content: note.content,
                symbolTicker: note.symbol?.ticker,
                tagNames: note.tags?.map { $0.name } ?? [],
                createdDate: note.createdDate,
                lastEditedDate: note.lastEditedDate,
                isSnap: note.isSnap,
                images: note.images
            )
        }
        
        let symbolBackups = symbols.map { symbol in
            SymbolBackup(
                ticker: symbol.ticker,
                companyName: symbol.companyName,
                currentPrice: symbol.currentPrice,
                lastPriceUpdate: symbol.lastPriceUpdate
            )
        }
        
        let tagBackups = tags.map { tag in
            TagBackup(name: tag.name)
        }
        
        let backupData = BackupData(
            notes: noteBackups,
            symbols: symbolBackups,
            tags: tagBackups,
            version: "1.0",
            exportDate: Date()
        )
        
        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        return try? encoder.encode(backupData)
    }
    
    // Import data from JSON backup
    func importBackup(data: Data, modelContext: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backupData = try decoder.decode(BackupData.self, from: data)
        
        // Clear existing data (optional - you might want to merge instead)
        // For MVP, we'll replace all data
        
        // Create symbols first
        var symbolMap: [String: Symbol] = [:]
        for symbolBackup in backupData.symbols {
            let symbol = Symbol(
                ticker: symbolBackup.ticker,
                companyName: symbolBackup.companyName,
                currentPrice: symbolBackup.currentPrice,
                lastPriceUpdate: symbolBackup.lastPriceUpdate
            )
            modelContext.insert(symbol)
            symbolMap[symbolBackup.ticker] = symbol
        }
        
        // Create tags
        var tagMap: [String: Tag] = [:]
        for tagBackup in backupData.tags {
            let tag = Tag(name: tagBackup.name)
            modelContext.insert(tag)
            tagMap[tagBackup.name] = tag
        }
        
        // Create notes
        for noteBackup in backupData.notes {
            let symbol = noteBackup.symbolTicker != nil ? symbolMap[noteBackup.symbolTicker!] : nil
            let tags = noteBackup.tagNames.compactMap { tagMap[$0] }
            
            let note = Note(
                id: noteBackup.id,
                content: noteBackup.content,
                symbol: symbol,
                tags: tags.isEmpty ? nil : tags,
                createdDate: noteBackup.createdDate,
                lastEditedDate: noteBackup.lastEditedDate,
                isSnap: noteBackup.isSnap,
                images: noteBackup.images
            )
            
            modelContext.insert(note)
        }
        
        // Save context
        try modelContext.save()
    }
    
    // Save backup to file
    func saveBackupToFile(data: Data) -> URL? {
        let fileName = "stocknotes_backup_\(Date().timeIntervalSince1970).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving backup file: \(error)")
            return nil
        }
    }
}
