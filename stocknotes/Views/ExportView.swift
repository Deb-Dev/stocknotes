//
//  ExportView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct ExportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Note.createdDate, order: .reverse) private var allNotes: [Note]
    @Query(sort: \Symbol.ticker) private var allSymbols: [Symbol]
    
    @StateObject private var noteService: NoteService
    
    @State private var exportOption: ExportOption = .allNotes
    @State private var selectedSymbol: Symbol?
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showingShareSheet = false
    
    enum ExportOption: String, CaseIterable {
        case allNotes = "All Notes"
        case symbolNotes = "Notes for Symbol"
    }
    
    init() {
        let tempContext = ModelContext(AppDataModel.sharedModelContainer)
        _noteService = StateObject(wrappedValue: NoteService(modelContext: tempContext))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Export Options") {
                    Picker("Export", selection: $exportOption) {
                        ForEach(ExportOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    
                    if exportOption == .symbolNotes {
                        Picker("Symbol", selection: $selectedSymbol) {
                            Text("Select Symbol").tag(nil as Symbol?)
                            ForEach(allSymbols) { symbol in
                                Text("\(symbol.ticker) - \(symbol.companyName.isEmpty ? "Unknown" : symbol.companyName)")
                                    .tag(symbol as Symbol?)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: exportPDF) {
                        HStack {
                            if isExporting {
                                ProgressView()
                            } else {
                                Image(systemName: "square.and.arrow.up")
                            }
                            Text("Export PDF")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isExporting || (exportOption == .symbolNotes && selectedSymbol == nil))
                }
            }
            .navigationTitle("Export Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func exportPDF() {
        isExporting = true
        
        let notesToExport: [Note]
        
        switch exportOption {
        case .allNotes:
            notesToExport = allNotes
        case .symbolNotes:
            guard let symbol = selectedSymbol else {
                isExporting = false
                return
            }
            notesToExport = noteService.getNotes(for: symbol)
        }
        
        guard !notesToExport.isEmpty else {
            isExporting = false
            return
        }
        
        let title: String
        if let symbol = selectedSymbol {
            title = "\(symbol.ticker) - Stock Notes"
        } else {
            title = "All Stock Notes"
        }
        
        let url: URL?
        if let symbol = selectedSymbol {
            url = ExportService.shared.exportNotesForSymbol(notesToExport, symbol: symbol)
        } else {
            url = ExportService.shared.exportAllNotes(notesToExport)
        }
        
        if let url = url {
            exportURL = url
            isExporting = false
            showingShareSheet = true
        } else {
            isExporting = false
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
        .modelContainer(AppDataModel.sharedModelContainer)
}
