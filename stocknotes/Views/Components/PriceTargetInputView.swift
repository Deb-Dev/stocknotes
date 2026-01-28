//
//  PriceTargetInputView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct PriceTargetInputView: View {
    @Binding var targetPrice: String
    @Binding var targetDate: Date?
    @Binding var thesisRationale: String
    @Binding var hasTarget: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Add Price Target", isOn: $hasTarget)
            
            if hasTarget {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Price")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter target price", text: $targetPrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    
                    DatePicker(
                        "Target Date (Optional)",
                        selection: Binding(
                            get: { targetDate ?? Date() },
                            set: { targetDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    
                    Text("Thesis Rationale")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $thesisRationale)
                        .frame(minHeight: 60)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
    }
}

#Preview {
    PriceTargetInputView(
        targetPrice: .constant("150.00"),
        targetDate: .constant(Date()),
        thesisRationale: .constant("Based on technical analysis"),
        hasTarget: .constant(true)
    )
    .padding()
}
