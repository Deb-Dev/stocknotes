//
//  TemplateType.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation

enum TemplateType: String, Codable, CaseIterable {
    case entryThesis = "Entry Thesis"
    case thesisUpdate = "Thesis Update"
    case exitDecision = "Exit Decision"
    case dividendStock = "Dividend Stock"
    case technicalAnalysis = "Technical Analysis"
    
    var displayName: String {
        return rawValue
    }
    
    var fields: [TemplateField] {
        switch self {
        case .entryThesis:
            return [
                TemplateField(name: "entryPrice", label: "Entry Price", type: .decimal),
                TemplateField(name: "thesis", label: "Thesis (Why Buy?)", type: .text),
                TemplateField(name: "catalysts", label: "Catalysts", type: .text),
                TemplateField(name: "riskFactors", label: "Risk Factors", type: .text),
                TemplateField(name: "conviction", label: "Conviction (1-10)", type: .integer)
            ]
        case .thesisUpdate:
            return [
                TemplateField(name: "previousConviction", label: "Previous Conviction", type: .integer),
                TemplateField(name: "newConviction", label: "New Conviction", type: .integer),
                TemplateField(name: "whatChanged", label: "What Changed", type: .text),
                TemplateField(name: "newPriceTarget", label: "New Price Target", type: .decimal)
            ]
        case .exitDecision:
            return [
                TemplateField(name: "exitPrice", label: "Exit Price", type: .decimal),
                TemplateField(name: "gainLossPercent", label: "Gain/Loss %", type: .decimal),
                TemplateField(name: "thesisAccuracy", label: "Thesis Accuracy Rating", type: .text),
                TemplateField(name: "lessonsLearned", label: "Lessons Learned", type: .text)
            ]
        case .dividendStock:
            return [
                TemplateField(name: "yield", label: "Yield (%)", type: .decimal),
                TemplateField(name: "growthRate", label: "Growth Rate (%)", type: .decimal),
                TemplateField(name: "divSafety", label: "Dividend Safety", type: .text),
                TemplateField(name: "rebalanceTrigger", label: "Rebalance Trigger", type: .text)
            ]
        case .technicalAnalysis:
            return [
                TemplateField(name: "chartPattern", label: "Chart Pattern", type: .text),
                TemplateField(name: "entrySignal", label: "Entry Signal", type: .text),
                TemplateField(name: "stopLoss", label: "Stop Loss", type: .decimal),
                TemplateField(name: "targetPrice", label: "Target Price", type: .decimal),
                TemplateField(name: "timeframe", label: "Timeframe", type: .text)
            ]
        }
    }
}

struct TemplateField: Codable {
    let name: String
    let label: String
    let type: FieldType
    
    enum FieldType: String, Codable {
        case text
        case integer
        case decimal
    }
}
