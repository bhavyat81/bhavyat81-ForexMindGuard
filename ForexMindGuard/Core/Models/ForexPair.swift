// ForexPair.swift
// ForexMindGuard – Core Models
//
// Represents a currency pair with live price data and derived metrics.

import Foundation

// MARK: - ForexPair
struct ForexPair: Codable, Identifiable, Hashable {
    let id: String          // e.g. "EURUSD"
    let base: String        // e.g. "EUR"
    let quote: String       // e.g. "USD"
    var bid: Double
    var ask: Double
    var dailyOpen: Double
    var timestamp: Date

    init(
        base: String,
        quote: String,
        bid: Double,
        ask: Double,
        dailyOpen: Double = 0,
        timestamp: Date = Date()
    ) {
        self.id = "\(base)\(quote)"
        self.base = base
        self.quote = quote
        self.bid = bid
        self.ask = ask
        self.dailyOpen = dailyOpen == 0 ? bid : dailyOpen
        self.timestamp = timestamp
    }

    // MARK: Derived properties

    /// Mid price between bid and ask
    var midPrice: Double { (bid + ask) / 2 }

    /// Spread in pips
    var spreadPips: Double { (ask - bid) * pipMultiplier }

    /// Daily change in pips from open
    var dailyChangePips: Double { (midPrice - dailyOpen) * pipMultiplier }

    /// Daily change as percentage
    var dailyChangePercent: Double {
        guard dailyOpen != 0 else { return 0 }
        return ((midPrice - dailyOpen) / dailyOpen) * 100
    }

    var isPositiveDay: Bool { dailyChangePips >= 0 }

    /// Standard pip multiplier (JPY pairs use 0.01, others 0.0001)
    var pipMultiplier: Double { quote == "JPY" ? 100 : 10000 }

    /// Formatted symbol  e.g. "EUR/USD"
    var symbol: String { "\(base)/\(quote)" }

    /// Formatted mid price with correct decimal places
    var formattedPrice: String {
        let decimals = quote == "JPY" ? 3 : 5
        return String(format: "%.\(decimals)f", midPrice)
    }

    // MARK: Sample data
    static let eurusd = ForexPair(base: "EUR", quote: "USD", bid: 1.08540, ask: 1.08542, dailyOpen: 1.08200)
    static let gbpusd = ForexPair(base: "GBP", quote: "USD", bid: 1.27210, ask: 1.27215, dailyOpen: 1.27450)
    static let usdjpy = ForexPair(base: "USD", quote: "JPY", bid: 149.850, ask: 149.855, dailyOpen: 149.200)
    static let audusd = ForexPair(base: "AUD", quote: "USD", bid: 0.65210, ask: 0.65215, dailyOpen: 0.65100)
    static let usdchf = ForexPair(base: "USD", quote: "CHF", bid: 0.90120, ask: 0.90124, dailyOpen: 0.90000)

    static let samples: [ForexPair] = [.eurusd, .gbpusd, .usdjpy, .audusd, .usdchf]
}
