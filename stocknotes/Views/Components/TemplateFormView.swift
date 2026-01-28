//
//  TemplateFormView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct TemplateFormView: View {
    let templateType: TemplateType
    @Binding var fieldValues: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Template: \(templateType.displayName)")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(templateType.fields, id: \.name) { field in
                FieldInputView(
                    field: field,
                    value: Binding(
                        get: { getFieldValue(field.name) },
                        set: { setFieldValue(field.name, value: $0) }
                    )
                )
            }
        }
    }
    
    private func getFieldValue(_ fieldName: String) -> String {
        if let value = fieldValues[fieldName] {
            return "\(value)"
        }
        return ""
    }
    
    private func setFieldValue(_ fieldName: String, value: String) {
        let field = templateType.fields.first { $0.name == fieldName }
        
        switch field?.type {
        case .integer:
            if let intValue = Int(value) {
                fieldValues[fieldName] = intValue
            } else if value.isEmpty {
                fieldValues.removeValue(forKey: fieldName)
            }
        case .decimal:
            if let doubleValue = Double(value) {
                fieldValues[fieldName] = doubleValue
            } else if value.isEmpty {
                fieldValues.removeValue(forKey: fieldName)
            }
        case .text, .none:
            if value.isEmpty {
                fieldValues.removeValue(forKey: fieldName)
            } else {
                fieldValues[fieldName] = value
            }
        }
    }
}

struct FieldInputView: View {
    let field: TemplateField
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(field.label)
                .font(.subheadline)
                .fontWeight(.medium)
            
            switch field.type {
            case .text:
                TextEditor(text: $value)
                    .frame(minHeight: 80)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            case .integer, .decimal:
                TextField(field.type == .integer ? "Enter number" : "Enter decimal", text: $value)
                    .keyboardType(field.type == .integer ? .numberPad : .decimalPad)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

#Preview {
    TemplateFormView(
        templateType: .entryThesis,
        fieldValues: .constant([:])
    )
    .padding()
}
