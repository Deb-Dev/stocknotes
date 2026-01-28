//
//  TagInputView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct TagInputView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var tagService: TagService
    
    @Binding var selectedTags: [Tag]
    @State private var tagInput: String = ""
    @State private var searchResults: [Tag] = []
    @State private var suggestedTags: [Tag] = []
    
    init(selectedTags: Binding<[Tag]>) {
        _selectedTags = selectedTags
        let tempContext = ModelContext(AppDataModel.sharedModelContainer)
        _tagService = StateObject(wrappedValue: TagService(modelContext: tempContext))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Selected Tags
            if !selectedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedTags) { tag in
                            HStack(spacing: 4) {
                                Text("#\(tag.name)")
                                    .font(.caption)
                                Button(action: {
                                    removeTag(tag)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption2)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Tag Input Field
            HStack {
                TextField("Add tag...", text: $tagInput)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: tagInput) { oldValue, newValue in
                        searchTags(query: newValue)
                    }
                    .onSubmit {
                        addTagFromInput()
                    }
                
                if !tagInput.isEmpty {
                    Button(action: addTagFromInput) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Suggested Tags
            if tagInput.isEmpty && !suggestedTags.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggested Tags")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestedTags.prefix(10)) { tag in
                                Button(action: {
                                    addTag(tag)
                                }) {
                                    Text("#\(tag.name)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
            }
            
            // Search Results
            if !tagInput.isEmpty && !searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Search Results")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(searchResults) { tag in
                                Button(action: {
                                    addTag(tag)
                                }) {
                                    Text("#\(tag.name)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadSuggestedTags()
        }
    }
    
    private func addTagFromInput() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        let tag = tagService.getOrCreateTag(name: trimmed)
        if !selectedTags.contains(where: { $0.name == tag.name }) {
            selectedTags.append(tag)
        }
        
        tagInput = ""
        searchResults = []
    }
    
    private func addTag(_ tag: Tag) {
        if !selectedTags.contains(where: { $0.name == tag.name }) {
            selectedTags.append(tag)
        }
        tagInput = ""
        searchResults = []
    }
    
    private func removeTag(_ tag: Tag) {
        selectedTags.removeAll { $0.name == tag.name }
    }
    
    private func searchTags(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchResults = tagService.searchTags(query: query)
    }
    
    private func loadSuggestedTags() {
        suggestedTags = tagService.getSuggestedTags(limit: 10)
    }
}

#Preview {
    TagInputView(selectedTags: .constant([]))
        .padding()
        .modelContainer(AppDataModel.sharedModelContainer)
}
