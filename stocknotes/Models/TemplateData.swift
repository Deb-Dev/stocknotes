//
//  TemplateData.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import SwiftData

@Model
final class TemplateData {
    var id: UUID
    var templateType: String // Store as String for SwiftData compatibility
    var fieldData: Data // JSON encoded field values
    
    @Relationship(deleteRule: .nullify, inverse: \Note.templateData)
    var note: Note?
    
    var createdDate: Date
    
    init(
        id: UUID = UUID(),
        templateType: TemplateType,
        fieldData: [String: Any],
        note: Note? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.templateType = templateType.rawValue
        self.note = note
        self.createdDate = createdDate
        
        // Encode field data as JSON
        if let jsonData = try? JSONSerialization.data(withJSONObject: fieldData) {
            self.fieldData = jsonData
        } else {
            self.fieldData = Data()
        }
    }
    
    // Decode field data from JSON
    var decodedFieldData: [String: Any]? {
        guard let json = try? JSONSerialization.jsonObject(with: fieldData) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    // Get template type enum
    var type: TemplateType? {
        return TemplateType(rawValue: templateType)
    }
    
    // Helper to get field value
    func getFieldValue(_ fieldName: String) -> Any? {
        return decodedFieldData?[fieldName]
    }
}
