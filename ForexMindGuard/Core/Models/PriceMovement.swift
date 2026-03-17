// PriceMovement.swift
// ForexMindGuard – Core Models
//
// Captures a significant price movement event that triggers the AI explainer.

import Foundation

// MARK: - MovementDirection
enum MovementDirection: String, Codable {
    case up   = "Up"
    case down = "Down"
    case flat = "Flat"

    var symbol: String {
        switch self {
        case .up:   return "▲"
        case .down: return "▼"
        case .flat: return "━"
        }
    }
}

// MARK: - PriceMovement
/// Describes a significant price movement that warrants an AI explanation.
struct PriceMovement: Codable, Identifiable {
    let id: UUID
    let pair: String          // e.g. "EURUSD"
    let pipsChange: Double    // Absolute pip movement
    let percentChange: Double // Percentage change
    let timeframe: Int        // Minutes over which the move occurred
    let direction: MovementDirection
    let startPrice: Double
    let endPrice: Double
    let timestamp: Date       // When the move was detected
    var explanation: NewsExplanation?  // Populated after AI analysis

    init(
        id: UUID = UUID(),
        pair: String,
        pipsChange: Double,
        percentChange: Double,
        timeframe: Int,
        direction: MovementDirection,
        startPrice: Double,
        endPrice: Double,
        timestamp: Date = Date(),
        explanation: NewsExplanation? = nil
    ) {
        self.id = id
        self.pair = pair
        self.pipsChange = pipsChange
        self.percentChange = percentChange
        self.timeframe = timeframe
        self.direction = direction
        self.startPrice = startPrice
        self.endPrice = endPrice
        self.timestamp = timestamp
        self.explanation = explanation
    }

    // MARK: Derived
    var isSignificant: Bool { abs(pipsChange) >= 20 }  // 20 pip default threshold

    var formattedPips: String {
        let prefix = direction == .up ? "+" : ""
        return "\(prefix)\(Int(pipsChange)) pips"
    }

    var formattedPercent: String {
        let prefix = direction == .up ? "+" : ""
        return String(format: "\(prefix)%.3f%%", percentChange)
    }

    var timeframeLabel: String {
        timeframe < 60 ? "\(timeframe)m" : "\(timeframe / 60)h"
    }

    // MARK: Sample data
    static let sample = PriceMovement(
        pair: "EURUSD",
        pipsChange: -82.0,
        percentChange: -0.075,
        timeframe: 15,
        direction: .down,
        startPrice: 1.08540,
        endPrice: 1.07720
    )
}
