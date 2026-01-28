//
//  TemplateSelectorView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct TemplateSelectorView: View {
    @Binding var selectedTemplate: TemplateType?
    let availableTemplates: [TemplateType]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Template")
                    .font(.headline)
                Spacer()
                if selectedTemplate != nil {
                    Button("Clear") {
                        selectedTemplate = nil
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            Picker("Select Template", selection: $selectedTemplate) {
                Text("None").tag(nil as TemplateType?)
                ForEach(availableTemplates, id: \.self) { template in
                    Text(template.displayName).tag(template as TemplateType?)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

#Preview {
    TemplateSelectorView(
        selectedTemplate: .constant(nil),
        availableTemplates: TemplateType.allCases
    )
    .padding()
}
