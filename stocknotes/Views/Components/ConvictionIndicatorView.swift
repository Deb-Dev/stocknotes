//
//  ConvictionIndicatorView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct ConvictionIndicatorView: View {
    let conviction: Int?
    let size: IndicatorSize
    
    enum IndicatorSize {
        case small
        case medium
        case large
        
        var circleSize: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var barHeight: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }
    
    var body: some View {
        if let conviction = conviction {
            HStack(spacing: 4) {
                Circle()
                    .fill(convictionColor(conviction))
                    .frame(width: size.circleSize, height: size.circleSize)
                
                if size != .small {
                    Text("\(conviction)")
                        .font(size == .large ? .caption : .caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(convictionColor(conviction))
                }
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

struct ConvictionBarView: View {
    let conviction: Int?
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...10, id: \.self) { value in
                Rectangle()
                    .fill(value <= (conviction ?? 0) ? convictionColor(value) : Color.gray.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
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
    VStack {
        ConvictionIndicatorView(conviction: 3, size: .small)
        ConvictionIndicatorView(conviction: 7, size: .medium)
        ConvictionIndicatorView(conviction: 9, size: .large)
        ConvictionBarView(conviction: 7)
    }
    .padding()
}
