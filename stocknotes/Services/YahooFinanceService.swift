//
//  YahooFinanceService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation

struct StockQuote: Codable {
    let symbol: String
    let shortName: String?
    let regularMarketPrice: Double?
    let regularMarketTime: Date?
}

struct YahooFinanceResponse: Codable {
    let quoteResponse: QuoteResponse?
}

struct QuoteResponse: Codable {
    let result: [StockQuote]?
    let error: [String]?
}

class YahooFinanceService {
    static let shared = YahooFinanceService()
    
    private init() {}
    
    // Fetch current price for a symbol
    func fetchPrice(for symbol: String) async throws -> (price: Double?, companyName: String?) {
        let urlString = "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol.uppercased())?interval=1d&range=1d"
        
        guard let url = URL(string: urlString) else {
            throw YahooFinanceError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Parse JSON response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let chart = json["chart"] as? [String: Any],
               let result = chart["result"] as? [[String: Any]],
               let firstResult = result.first,
               let meta = firstResult["meta"] as? [String: Any] {
                
                let price = meta["regularMarketPrice"] as? Double
                let companyName = meta["longName"] as? String ?? meta["shortName"] as? String
                
                return (price, companyName)
            }
            
            throw YahooFinanceError.invalidResponse
        } catch {
            throw YahooFinanceError.networkError(error)
        }
    }
    
    // Search for symbols (autocomplete)
    func searchSymbols(query: String) async throws -> [SymbolSearchResult] {
        let urlString = "https://query1.finance.yahoo.com/v1/finance/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&quotesCount=10"
        
        guard let url = URL(string: urlString) else {
            throw YahooFinanceError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let quotes = json["quotes"] as? [[String: Any]] {
                
                return quotes.compactMap { quote in
                    guard let symbol = quote["symbol"] as? String,
                          let shortname = quote["shortname"] as? String else {
                        return nil
                    }
                    return SymbolSearchResult(symbol: symbol, companyName: shortname)
                }
            }
            
            return []
        } catch {
            throw YahooFinanceError.networkError(error)
        }
    }
}

struct SymbolSearchResult {
    let symbol: String
    let companyName: String
}

enum YahooFinanceError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from Yahoo Finance"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
