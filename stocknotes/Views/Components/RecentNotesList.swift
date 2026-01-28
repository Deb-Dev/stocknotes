//
//  RecentNotesList.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct RecentNotesList: View {
    let notes: [Note]
    let onNoteTap: (Note) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Notes")
                .font(.headline)
                .padding(.horizontal)
            
            if notes.isEmpty {
                Text("No notes yet. Create your first note!")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(notes.prefix(10)) { note in
                    NotePreviewRow(note: note)
                        .onTapGesture {
                            onNoteTap(note)
                        }
                }
            }
        }
    }
}

struct NotePreviewRow: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let symbol = note.symbol {
                    Text(symbol.ticker)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                Text(note.createdDate, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(note.content.prefix(50))
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            if let tags = note.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(tags.prefix(3)) { tag in
                            Text("#\(tag.name)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#Preview {
    RecentNotesList(notes: []) { _ in }
}
