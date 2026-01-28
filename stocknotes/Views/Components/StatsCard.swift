//
//  StatsCard.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    HStack {
        StatsCard(title: "Total Notes", value: "42", icon: "note.text")
        StatsCard(title: "Symbols", value: "12", icon: "chart.line.uptrend.xyaxis")
    }
    .padding()
}
