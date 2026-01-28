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
    
    @State private var noteService: NoteService?
    @State private var tagService: TagService?
    @State private var templateService: TemplateService?
    @State private var priceTargetService: PriceTargetService?
    
    @State private var content: String = ""
    @State private var selectedSymbol: Symbol?
    @State private var selectedTags: [Tag] = []
    @State private var characterCount: Int = 0
    @State private var isSaving = false
    @State private var selectedImages: [UIImage] = []
    @State private var imageData: [Data] = []
    
    // Template-related state
    @State private var selectedTemplate: TemplateType? = nil
    @State private var templateFieldValues: [String: Any] = [:]
    @State private var useTemplateContent: Bool = false
    
    // Conviction and sentiment state
    @State private var conviction: Int? = nil
    @State private var sentiment: Sentiment? = nil
    @State private var autoDetectedSentiment: Sentiment? = nil
    
    // Price target state
    @State private var hasPriceTarget: Bool = false
    @State private var targetPrice: String = ""
    @State private var targetDate: Date? = nil
    @State private var thesisRationale: String = ""
    
    let note: Note?
    let initialSymbol: Symbol?
    let maxCharacters = 5000
    
    init(note: Note? = nil, initialSymbol: Symbol? = nil) {
        self.note = note
        self.initialSymbol = initialSymbol
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Template") {
                    TemplateSelectorView(
                        selectedTemplate: $selectedTemplate,
                        availableTemplates: templateService?.getAvailableTemplates() ?? []
                    )
                    .onChange(of: selectedTemplate) { oldValue, newValue in
                        if newValue != nil {
                            templateFieldValues = [:]
                            useTemplateContent = false
                        }
                    }
                    
                    if let template = selectedTemplate {
                        TemplateFormView(
                            templateType: template,
                            fieldValues: $templateFieldValues
                        )
                        
                        Toggle("Use template content in note", isOn: $useTemplateContent)
                            .onChange(of: useTemplateContent) { oldValue, newValue in
                                if newValue, let templateService = templateService {
                                    let generatedContent = templateService.generateContent(
                                        from: TemplateData(
                                            templateType: template,
                                            fieldData: templateFieldValues
                                        )
                                    )
                                    if !generatedContent.isEmpty {
                                        content = generatedContent
                                        characterCount = content.count
                                    }
                                }
                            }
                    }
                }
                
                Section("Symbol") {
                    SymbolAutocompleteView(selectedSymbol: $selectedSymbol)
                }
                
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .onChange(of: content) { oldValue, newValue in
                            characterCount = newValue.count
                            if let note = note, let noteService = noteService {
                                noteService.updateNote(note, content: newValue)
                            }
                            
                            // Auto-detect sentiment
                            autoDetectedSentiment = SentimentAnalysisService.shared.analyzeSentiment(from: newValue)
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
                
                Section("Conviction & Sentiment") {
                    ConvictionSliderView(conviction: $conviction)
                    
                    SentimentSelectorView(
                        sentiment: $sentiment,
                        autoDetectedSentiment: autoDetectedSentiment
                    )
                }
                
                Section("Price Target") {
                    PriceTargetInputView(
                        targetPrice: $targetPrice,
                        targetDate: $targetDate,
                        thesisRationale: $thesisRationale,
                        hasTarget: $hasPriceTarget
                    )
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
                    .disabled(content.isEmpty || characterCount > maxCharacters || noteService == nil)
                }
            }
            .onAppear {
                initializeServices()
                loadNote()
            }
        }
    }
    
    private func initializeServices() {
        if noteService == nil {
            noteService = NoteService(modelContext: modelContext)
            tagService = TagService(modelContext: modelContext)
            templateService = TemplateService(modelContext: modelContext)
            priceTargetService = PriceTargetService(modelContext: modelContext)
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
            
            // Load template data if exists
            if let templateData = note.templateData,
               let templateType = templateData.type {
                selectedTemplate = templateType
                templateFieldValues = templateData.decodedFieldData ?? [:]
            }
            
            // Load conviction and sentiment
            conviction = note.conviction
            sentiment = note.sentiment
            
            // Auto-detect sentiment from content
            autoDetectedSentiment = SentimentAnalysisService.shared.analyzeSentiment(from: content)
            
            // Load price target if exists (from note's related price target)
            // Note: Price targets are stored separately, so we check if note has one
            // For now, we'll just initialize empty state
            hasPriceTarget = false
            targetPrice = ""
            targetDate = nil
            thesisRationale = ""
        } else if let initialSymbol = initialSymbol {
            // Set initial symbol for new note
            selectedSymbol = initialSymbol
        }
    }
    
    private func saveNote() {
        guard let noteService = noteService,
              let templateService = templateService,
              let priceTargetService = priceTargetService else { return }
        
        isSaving = true
        
        if let existingNote = note {
            // Update existing note
            existingNote.updateContent(content)
            existingNote.symbol = selectedSymbol
            existingNote.tags = selectedTags.isEmpty ? nil : selectedTags
            existingNote.images = imageData.isEmpty ? nil : imageData
            existingNote.conviction = conviction
            existingNote.sentiment = sentiment
            
            // Update or create template data
            if let template = selectedTemplate, !templateFieldValues.isEmpty {
                if let existingTemplateData = existingNote.templateData {
                    templateService.updateTemplateData(existingTemplateData, fieldValues: templateFieldValues)
                } else {
                    let newTemplateData = templateService.createTemplateData(
                        templateType: template,
                        fieldValues: templateFieldValues,
                        note: existingNote
                    )
                    existingNote.templateData = newTemplateData
                }
            } else if existingNote.templateData != nil {
                // Remove template data if template is cleared
                if let templateData = existingNote.templateData {
                    templateService.deleteTemplateData(templateData)
                    existingNote.templateData = nil
                }
            }
            
            // Create or update price target if specified
            if hasPriceTarget, let price = Double(targetPrice), !price.isNaN, let symbol = selectedSymbol {
                // Check if there's an existing price target linked to this note
                let existingTargets = priceTargetService.getPriceTargets(for: symbol)
                if let existingTarget = existingTargets.first(where: { $0.note?.id == existingNote.id }) {
                    priceTargetService.updatePriceTarget(
                        existingTarget,
                        targetPrice: price,
                        targetDate: targetDate,
                        thesisRationale: thesisRationale.isEmpty ? nil : thesisRationale
                    )
                } else {
                    let newTarget = priceTargetService.createPriceTarget(
                        targetPrice: price,
                        targetDate: targetDate,
                        thesisRationale: thesisRationale,
                        symbol: symbol,
                        note: existingNote
                    )
                    if symbol.priceTargets == nil {
                        symbol.priceTargets = []
                    }
                    symbol.priceTargets?.append(newTarget)
                }
            }
            
            noteService.saveNote(existingNote)
        } else {
            // Create new note
            let newNote = noteService.createNote(
                content: content,
                symbol: selectedSymbol,
                tags: selectedTags.isEmpty ? nil : selectedTags
            )
            
            // Set conviction and sentiment
            newNote.conviction = conviction
            newNote.sentiment = sentiment
            
            // Add images
            newNote.images = imageData.isEmpty ? nil : imageData
            
            // Create template data if template is selected
            if let template = selectedTemplate, !templateFieldValues.isEmpty {
                let templateData = templateService.createTemplateData(
                    templateType: template,
                    fieldValues: templateFieldValues,
                    note: newNote
                )
                newNote.templateData = templateData
            }
            
            // Create price target if specified
            if hasPriceTarget, let price = Double(targetPrice), !price.isNaN, let symbol = selectedSymbol {
                let priceTarget = priceTargetService.createPriceTarget(
                    targetPrice: price,
                    targetDate: targetDate,
                    thesisRationale: thesisRationale,
                    symbol: symbol,
                    note: newNote
                )
                if symbol.priceTargets == nil {
                    symbol.priceTargets = []
                }
                symbol.priceTargets?.append(priceTarget)
            }
            
            // Update symbol's notes relationship
            selectedSymbol?.notes?.append(newNote)
        }
        
        isSaving = false
        dismiss()
    }
}

#Preview {
    NoteEditorView()
        .modelContainer(AppDataModel.sharedModelContainer)
}
