//
//  SettingsView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var isExportingBackup = false
    @State private var isImportingBackup = false
    @State private var backupURL: URL?
    @State private var showingShareSheet = false
    @State private var showingDocumentPicker = false
    @State private var importError: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Backup & Restore") {
                    Button(action: exportBackup) {
                        HStack {
                            if isExportingBackup {
                                ProgressView()
                            } else {
                                Image(systemName: "square.and.arrow.up")
                            }
                            Text("Export Backup")
                        }
                    }
                    .disabled(isExportingBackup)
                    
                    Button(action: { showingDocumentPicker = true }) {
                        HStack {
                            if isImportingBackup {
                                ProgressView()
                            } else {
                                Image(systemName: "square.and.arrow.down")
                            }
                            Text("Import Backup")
                        }
                    }
                    .disabled(isImportingBackup)
                }
                
                Section("Export") {
                    NavigationLink(destination: ExportView()) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Export Notes as PDF")
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingShareSheet) {
                if let url = backupURL {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker { url in
                    importBackup(from: url)
                }
            }
            .alert("Import Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = importError {
                    Text(error)
                }
            }
        }
    }
    
    private func exportBackup() {
        isExportingBackup = true
        
        if let backupData = BackupService.shared.exportBackup(modelContext: modelContext),
           let url = BackupService.shared.saveBackupToFile(data: backupData) {
            backupURL = url
            isExportingBackup = false
            showingShareSheet = true
        } else {
            importError = "Failed to create backup"
            showingError = true
            isExportingBackup = false
        }
    }
    
    private func importBackup(from url: URL) {
        isImportingBackup = true
        
        do {
            let data = try Data(contentsOf: url)
            try BackupService.shared.importBackup(data: data, modelContext: modelContext)
            isImportingBackup = false
        } catch {
            importError = "Failed to import backup: \(error.localizedDescription)"
            showingError = true
            isImportingBackup = false
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentPicked: (URL) -> Void
        
        init(onDocumentPicked: @escaping (URL) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onDocumentPicked(url)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(AppDataModel.sharedModelContainer)
}
