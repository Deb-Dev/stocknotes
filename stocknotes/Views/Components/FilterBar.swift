//
//  FilterBar.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct FilterBar: View {
    @Binding var selectedSymbol: Symbol?
    @Binding var selectedTag: Tag?
    @Binding var sortOption: SortOption
    @Binding var dateRange: DateRange
    
    let symbols: [Symbol]
    let tags: [Tag]
    
    enum SortOption: String, CaseIterable {
        case creationDate = "Creation Date"
        case editDate = "Edit Date"
        case symbolName = "Symbol Name"
    }
    
    enum DateRange: String, CaseIterable {
        case all = "All Time"
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Symbol Filter
            if !symbols.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All Symbols",
                            isSelected: selectedSymbol == nil,
                            action: { selectedSymbol = nil }
                        )
                        
                        ForEach(symbols) { symbol in
                            FilterChip(
                                title: symbol.ticker,
                                isSelected: selectedSymbol?.ticker == symbol.ticker,
                                action: {
                                    selectedSymbol = selectedSymbol?.ticker == symbol.ticker ? nil : symbol
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Tag Filter
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All Tags",
                            isSelected: selectedTag == nil,
                            action: { selectedTag = nil }
                        )
                        
                        ForEach(tags) { tag in
                            FilterChip(
                                title: "#\(tag.name)",
                                isSelected: selectedTag?.name == tag.name,
                                action: {
                                    selectedTag = selectedTag?.name == tag.name ? nil : tag
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Sort & Date Range
            HStack {
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: { sortOption = option }) {
                            HStack {
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort: \(sortOption.rawValue)")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Menu {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Button(action: { dateRange = range }) {
                            HStack {
                                Text(range.rawValue)
                                if dateRange == range {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(dateRange.rawValue)
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

#Preview {
    FilterBar(
        selectedSymbol: .constant(nil),
        selectedTag: .constant(nil),
        sortOption: .constant(.creationDate),
        dateRange: .constant(.all),
        symbols: [],
        tags: []
    )
}
