//
//  ConvictionSliderView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct ConvictionSliderView: View {
    @Binding var conviction: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Conviction")
                    .font(.headline)
                Spacer()
                if let conviction = conviction {
                    Text("\(conviction)/10")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(convictionColor(conviction))
                } else {
                    Text("Not set")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 12) {
                // Color-coded segments
                ForEach(1...10, id: \.self) { value in
                    Rectangle()
                        .fill(convictionColor(value))
                        .frame(height: 8)
                        .cornerRadius(4)
                        .overlay(
                            Rectangle()
                                .fill(value <= (conviction ?? 0) ? Color.clear : Color.gray.opacity(0.3))
                                .cornerRadius(4)
                        )
                }
            }
            
            Slider(
                value: Binding(
                    get: { Double(conviction ?? 5) },
                    set: { conviction = Int($0.rounded()) }
                ),
                in: 1...10,
                step: 1
            )
            .tint(convictionColor(conviction ?? 5))
            
            HStack {
                Text("Low")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("High")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func convictionColor(_ value: Int) -> Color {
        switch value {
        case 1...3:
            return .red
        case 4...7:
            return .yellow
        case 8...10:
            return .green
        default:
            return .gray
        }
    }
}

#Preview {
    ConvictionSliderView(conviction: .constant(7))
        .padding()
}
