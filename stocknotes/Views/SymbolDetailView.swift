//
//  SymbolDetailView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import SwiftData

struct SymbolDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    let symbol: Symbol
    @Query(sort: \Note.createdDate, order: .reverse) private var allNotes: [Note]
    
    @State private var noteService: NoteService?
    @State private var symbolService: SymbolService?
    @State private var snapService: SnapService?
    @State private var priceTargetService: PriceTargetService?
    
    @State private var showingNewNote = false
    @State private var selectedNote: Note?
    @State private var isRefreshingPrice = false
    @State private var showingPriceTargets = false
    @Query(sort: \PriceTarget.createdDate, order: .reverse) private var allPriceTargets: [PriceTarget]
    
    private var notes: [Note] {
        allNotes.filter { $0.symbol?.ticker == symbol.ticker }
    }
    
    private var priceTargets: [PriceTarget] {
        allPriceTargets.filter { $0.symbol?.ticker == symbol.ticker }
    }
    
    init(symbol: Symbol) {
        self.symbol = symbol
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Symbol Info Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(symbol.ticker)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                if !symbol.companyName.isEmpty {
                                    Text(symbol.companyName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if let price = symbol.currentPrice {
                                VStack(alignment: .trailing) {
                                    Text(String(format: "$%.2f", price))
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    if let updateTime = symbol.lastPriceUpdate {
                                        Text("Updated \(updateTime, style: .relative)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else {
                                Text("N/A")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: refreshPrice) {
                            HStack {
                                if isRefreshingPrice {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                }
                                Text("Refresh Price")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .disabled(isRefreshingPrice)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Quick Actions
                    HStack(spacing: 12) {
                        Button(action: { showingNewNote = true }) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                Text("New Note")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: createSnap) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Quick Snap")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Price Targets Section
                    if !priceTargets.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Price Targets (\(priceTargets.count))")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("View All") {
                                    showingPriceTargets = true
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(priceTargets.prefix(3)) { target in
                                        PriceTargetCard(
                                            priceTarget: target,
                                            currentPrice: symbol.currentPrice
                                        )
                                        .frame(width: 280)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Analytics Section
                    if !notes.isEmpty || !priceTargets.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Analytics")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            // Conviction Chart
                            if notes.contains(where: { $0.conviction != nil }) {
                                ConvictionChartView(notes: notes)
                                    .padding(.horizontal)
                            }
                            
                            // Price Target Comparison
                            if !priceTargets.isEmpty, symbol.currentPrice != nil {
                                PriceTargetComparisonView(
                                    priceTargets: priceTargets,
                                    currentPrice: symbol.currentPrice
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Notes List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes (\(notes.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if notes.isEmpty {
                            ContentUnavailableView(
                                "No Notes",
                                systemImage: "note.text",
                                description: Text("Create your first note for this symbol")
                            )
                            .frame(height: 200)
                        } else {
                            ForEach(notes) { note in
                                NotePreviewRow(note: note)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        selectedNote = note
                                    }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(symbol.ticker)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewNote = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNewNote) {
                NoteEditorView(initialSymbol: symbol)
            }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
            }
            .sheet(isPresented: $showingPriceTargets) {
                PriceTargetsView(symbol: symbol)
            }
            .onAppear {
                initializeServices()
            }
        }
    }
    
    private func initializeServices() {
        if noteService == nil {
            noteService = NoteService(modelContext: modelContext)
            symbolService = SymbolService(modelContext: modelContext)
            snapService = SnapService(modelContext: modelContext)
            priceTargetService = PriceTargetService(modelContext: modelContext)
        }
    }
    
    private func refreshPrice() {
        guard let symbolService = symbolService else { return }
        
        isRefreshingPrice = true
        Task {
            await symbolService.fetchPrice(for: symbol)
            isRefreshingPrice = false
        }
    }
    
    private func createSnap() {
        guard let snapService = snapService else { return }
        
        Task {
            await snapService.createSnap(for: symbol)
        }
    }
}

#Preview {
    let container = AppDataModel.sharedModelContainer
    let symbol = Symbol(ticker: "AAPL", companyName: "Apple Inc.", currentPrice: 175.50)
    
    return SymbolDetailView(symbol: symbol)
        .modelContainer(container)
}
