//
//  NoteEditorView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var noteService: NoteService
    @StateObject private var tagService: TagService
    
    @State private var content: String = ""
    @State private var selectedSymbol: Symbol?
    @State private var selectedTags: [Tag] = []
    @State private var characterCount: Int = 0
    @State private var isSaving = false
    @State private var selectedImages: [UIImage] = []
    @State private var imageData: [Data] = []
    
    let note: Note?
    let initialSymbol: Symbol?
    let maxCharacters = 5000
    
    init(note: Note? = nil, initialSymbol: Symbol? = nil) {
        self.note = note
        self.initialSymbol = initialSymbol
        let tempContext = ModelContext(AppDataModel.sharedModelContainer)
        _noteService = StateObject(wrappedValue: NoteService(modelContext: tempContext))
        _tagService = StateObject(wrappedValue: TagService(modelContext: tempContext))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Symbol") {
                    SymbolAutocompleteView(selectedSymbol: $selectedSymbol)
                }
                
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .onChange(of: content) { oldValue, newValue in
                            characterCount = newValue.count
                            if let note = note {
                                noteService.updateNote(note, content: newValue)
                            }
                        }
                    
                    HStack {
                        Spacer()
                        Text("\(characterCount)/\(maxCharacters)")
                            .font(.caption)
                            .foregroundColor(characterCount > maxCharacters ? .red : .secondary)
                    }
                }
                
                Section("Tags") {
                    TagInputView(selectedTags: $selectedTags)
                }
                
                Section("Images") {
                    ImagePickerButton(
                        selectedImages: $selectedImages,
                        maxImages: 3
                    ) { processedData in
                        imageData = processedData
                    }
                    
                    if !imageData.isEmpty {
                        ImageAttachmentView(
                            images: imageData,
                            onDelete: { index in
                                imageData.remove(at: index)
                                if index < selectedImages.count {
                                    selectedImages.remove(at: index)
                                }
                            }
                        )
                    }
                }
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(content.isEmpty || characterCount > maxCharacters)
                }
            }
            .onAppear {
                loadNote()
                updateServices()
            }
        }
    }
    
    private func loadNote() {
        if let note = note {
            content = note.content
            characterCount = note.content.count
            selectedSymbol = note.symbol
            selectedTags = note.tags ?? []
            imageData = note.images ?? []
            
            // Convert Data to UIImage for display
            selectedImages = (note.images ?? []).compactMap { UIImage(data: $0) }
        } else if let initialSymbol = initialSymbol {
            // Set initial symbol for new note
            selectedSymbol = initialSymbol
        }
    }
    
    private func saveNote() {
        isSaving = true
        
        if let existingNote = note {
            // Update existing note
            existingNote.updateContent(content)
            existingNote.symbol = selectedSymbol
            existingNote.tags = selectedTags.isEmpty ? nil : selectedTags
            existingNote.images = imageData.isEmpty ? nil : imageData
            noteService.saveNote(existingNote)
        } else {
            // Create new note
            let newNote = noteService.createNote(
                content: content,
                symbol: selectedSymbol,
                tags: selectedTags.isEmpty ? nil : selectedTags
            )
            
            // Add images
            newNote.images = imageData.isEmpty ? nil : imageData
            
            // Update symbol's notes relationship
            selectedSymbol?.notes?.append(newNote)
        }
        
        isSaving = false
        dismiss()
    }
    
    private func updateServices() {
        // Services will use the environment modelContext
    }
}

#Preview {
    NoteEditorView()
        .modelContainer(AppDataModel.sharedModelContainer)
}
