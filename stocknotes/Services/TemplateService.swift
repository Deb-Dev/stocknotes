//
//  TemplateService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData
import Combine

@MainActor
class TemplateService: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Get all available template types
    func getAvailableTemplates() -> [TemplateType] {
        return TemplateType.allCases
    }
    
    // Get fields for a template type
    func getFields(for templateType: TemplateType) -> [TemplateField] {
        return templateType.fields
    }
    
    // Create template data from field values
    func createTemplateData(
        templateType: TemplateType,
        fieldValues: [String: Any],
        note: Note
    ) -> TemplateData {
        let templateData = TemplateData(
            templateType: templateType,
            fieldData: fieldValues,
            note: note
        )
        
        modelContext.insert(templateData)
        save()
        return templateData
    }
    
    // Update template data
    func updateTemplateData(
        _ templateData: TemplateData,
        fieldValues: [String: Any]
    ) {
        // Recreate with new field values
        if let jsonData = try? JSONSerialization.data(withJSONObject: fieldValues) {
            templateData.fieldData = jsonData
            save()
        }
    }
    
    // Get template data for a note
    func getTemplateData(for note: Note) -> TemplateData? {
        return note.templateData
    }
    
    // Delete template data
    func deleteTemplateData(_ templateData: TemplateData) {
        modelContext.delete(templateData)
        save()
    }
    
    // Generate content from template data (for display/export)
    func generateContent(from templateData: TemplateData) -> String {
        guard let type = templateData.type,
              let fieldData = templateData.decodedFieldData else {
            return ""
        }
        
        var content = "**\(type.displayName)**\n\n"
        
        for field in type.fields {
            if let value = fieldData[field.name] {
                let displayValue: String
                if let stringValue = value as? String {
                    displayValue = stringValue.isEmpty ? "N/A" : stringValue
                } else {
                    displayValue = "\(value)"
                }
                content += "**\(field.label):** \(displayValue)\n"
            }
        }
        
        return content
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving template data: \(error)")
        }
    }
}
