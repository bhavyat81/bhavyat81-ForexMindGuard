// BehaviorAnalyzer.swift
// ForexMindGuard – Core/Services/EmotionAI
//
// Detects dangerous trading behaviour patterns:
//  • Rapid trading (trades placed < 30 seconds apart)
//  • Revenge trading (series of trades following a losing streak)
//  • Excessive screen interaction (frantic tapping = panic)
//  • More than N trades in a rolling hour window

import Foundation
import Combine

// MARK: - Behavioral pattern flags
struct BehavioralFlags: OptionSet {
    let rawValue: Int
    static let rapidTrading      = BehavioralFlags(rawValue: 1 << 0)
    static let revengeTrading    = BehavioralFlags(rawValue: 1 << 1)
    static let excessiveTrades   = BehavioralFlags(rawValue: 1 << 2)
    static let panicInteraction  = BehavioralFlags(rawValue: 1 << 3)
}

// MARK: - BehaviorAnalyzer
final class BehaviorAnalyzer: ObservableObject {

    // MARK: Published
    @Published private(set) var behavioralFactor: Double = 0.0  // 0-1 stress contribution
    @Published private(set) var activeFlags: BehavioralFlags = []
    @Published private(set) var flagDescriptions: [String] = []

    // MARK: Combine
    private let factorSubject = PassthroughSubject<Double, Never>()
    var publisher: AnyPublisher<Double, Never> { factorSubject.eraseToAnyPublisher() }

    // MARK: Private tracking state
    private var tradeTimestamps: [Date] = []
    private var interactionTimestamps: [Date] = []
    private var recentPipResults: [Double] = []  // Negative = loss

    private let rapidTradeThreshold: TimeInterval = 30      // seconds
    private let maxTradesPerHour: Int             = 10
    private let panicInteractionThreshold: Int    = 20      // taps per 30 seconds
    private let revengeLossStreak: Int            = 3       // 3 consecutive losses

    // MARK: - Record a new trade
    func recordTrade(pipResult: Double) {
        let now = Date()
        tradeTimestamps.append(now)
        recentPipResults.append(pipResult)

        // Trim to last hour
        let hourAgo = now.addingTimeInterval(-3600)
        tradeTimestamps = tradeTimestamps.filter { $0 > hourAgo }
        // Keep last 10 for streak analysis
        if recentPipResults.count > 10 { recentPipResults.removeFirst() }

        analyse()
    }

    // MARK: - Record UI interaction (called from gesture handlers)
    func recordInteraction() {
        let now = Date()
        interactionTimestamps.append(now)
        // Trim to last 30 seconds
        interactionTimestamps = interactionTimestamps.filter { now.timeIntervalSince($0) < 30 }
        analyse()
    }

    // MARK: - Analysis
    private func analyse() {
        var flags: BehavioralFlags = []
        var descriptions: [String] = []

        // 1. Rapid trading check
        if let last = tradeTimestamps.dropLast().last,
           let current = tradeTimestamps.last,
           current.timeIntervalSince(last) < rapidTradeThreshold {
            flags.insert(.rapidTrading)
            descriptions.append("⚡ Rapid trading detected (< 30s between trades)")
        }

        // 2. Excessive trades check
        if tradeTimestamps.count > maxTradesPerHour {
            flags.insert(.excessiveTrades)
            descriptions.append("📈 Excessive trades: \(tradeTimestamps.count) in the last hour")
        }

        // 3. Revenge trading: 3+ consecutive losses
        let streak = consecutiveLossStreak()
        if streak >= revengeLossStreak {
            flags.insert(.revengeTrading)
            descriptions.append("😤 Revenge trading risk: \(streak) consecutive losses")
        }

        // 4. Panic interaction
        if interactionTimestamps.count > panicInteractionThreshold {
            flags.insert(.panicInteraction)
            descriptions.append("🖐 Panic interaction: \(interactionTimestamps.count) taps in 30s")
        }

        // Compute factor (0–1)
        var factor = 0.0
        if flags.contains(.rapidTrading)    { factor += 0.30 }
        if flags.contains(.revengeTrading)  { factor += 0.35 }
        if flags.contains(.excessiveTrades) { factor += 0.20 }
        if flags.contains(.panicInteraction) { factor += 0.15 }
        factor = min(factor, 1.0)

        DispatchQueue.main.async { [weak self] in
            self?.activeFlags = flags
            self?.flagDescriptions = descriptions
            self?.behavioralFactor = factor
            self?.factorSubject.send(factor)
        }
    }

    // MARK: - Helpers
    private func consecutiveLossStreak() -> Int {
        var streak = 0
        for result in recentPipResults.reversed() {
            if result < 0 { streak += 1 } else { break }
        }
        return streak
    }

    // MARK: - Reset
    func reset() {
        tradeTimestamps.removeAll()
        interactionTimestamps.removeAll()
        recentPipResults.removeAll()
        DispatchQueue.main.async {
            self.activeFlags = []
            self.flagDescriptions = []
            self.behavioralFactor = 0
        }
    }
}
