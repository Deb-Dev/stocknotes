//
//  AppDataModel.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData

struct AppDataModel {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
            Symbol.self,
            Tag.self,
            TemplateData.self,
            PriceTarget.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
