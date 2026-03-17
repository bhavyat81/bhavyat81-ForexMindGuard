// TradingSession.swift
// ForexMindGuard – Core Models
//
// Represents a complete trading session with emotion tracking history.
// Used for post-session review and analytics.

import Foundation

// MARK: - TradeRecord
/// Lightweight record of a single trade entry (for session analytics only – not a full OMS).
struct TradeRecord: Codable, Identifiable {
    let id: UUID
    let pair: String
    let direction: MovementDirection
    let entryPrice: Double
    var exitPrice: Double?
    let lotSize: Double
    let timestamp: Date
    var closedAt: Date?
    let stressScoreAtEntry: Double   // What was the stress score when this trade was placed?

    init(
        id: UUID = UUID(),
        pair: String,
        direction: MovementDirection,
        entryPrice: Double,
        exitPrice: Double? = nil,
        lotSize: Double,
        timestamp: Date = Date(),
        closedAt: Date? = nil,
        stressScoreAtEntry: Double
    ) {
        self.id = id
        self.pair = pair
        self.direction = direction
        self.entryPrice = entryPrice
        self.exitPrice = exitPrice
        self.lotSize = lotSize
        self.timestamp = timestamp
        self.closedAt = closedAt
        self.stressScoreAtEntry = stressScoreAtEntry
    }

    var isOpen: Bool { exitPrice == nil }

    var pipResult: Double? {
        guard let exit = exitPrice else { return nil }
        let multiplier = pair.hasSuffix("JPY") ? 100.0 : 10000.0
        let raw = (exit - entryPrice) * multiplier
        return direction == .up ? raw : -raw
    }
}

// MARK: - TradingSession
struct TradingSession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var emotionSnapshots: [EmotionSnapshot]
    var trades: [TradeRecord]
    var lockEvents: [LockEvent]

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        emotionSnapshots: [EmotionSnapshot] = [],
        trades: [TradeRecord] = [],
        lockEvents: [LockEvent] = []
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.emotionSnapshots = emotionSnapshots
        self.trades = trades
        self.lockEvents = lockEvents
    }

    // MARK: Computed analytics

    var duration: TimeInterval { (endTime ?? Date()).timeIntervalSince(startTime) }

    var averageStressScore: Double {
        guard !emotionSnapshots.isEmpty else { return 0 }
        return emotionSnapshots.map(\.stressScore).reduce(0, +) / Double(emotionSnapshots.count)
    }

    var peakStressScore: Double { emotionSnapshots.map(\.stressScore).max() ?? 0 }

    var tradesAboveWarningStress: Int {
        trades.filter { $0.stressScoreAtEntry > StressThresholds.warning }.count
    }

    var winRate: Double? {
        let closed = trades.compactMap(\.pipResult)
        guard !closed.isEmpty else { return nil }
        let wins = closed.filter { $0 > 0 }.count
        return Double(wins) / Double(closed.count)
    }

    var totalPips: Double { trades.compactMap(\.pipResult).reduce(0, +) }

    var isActive: Bool { endTime == nil }

    // MARK: Sample
    static let sample: TradingSession = {
        var session = TradingSession(startTime: Date().addingTimeInterval(-7200))
        session.emotionSnapshots = [.sample, .calm, .sample]
        return session
    }()
}

// MARK: - LockEvent
/// Records when the trading lock was triggered, for session review.
struct LockEvent: Codable, Identifiable {
    let id: UUID
    let triggeredAt: Date
    let stressScoreAtTrigger: Double
    let emotion: EmotionState
    let cooldownDuration: TimeInterval
    var wasOverridden: Bool
    var overriddenAt: Date?

    init(
        id: UUID = UUID(),
        triggeredAt: Date = Date(),
        stressScoreAtTrigger: Double,
        emotion: EmotionState,
        cooldownDuration: TimeInterval,
        wasOverridden: Bool = false,
        overriddenAt: Date? = nil
    ) {
        self.id = id
        self.triggeredAt = triggeredAt
        self.stressScoreAtTrigger = stressScoreAtTrigger
        self.emotion = emotion
        self.cooldownDuration = cooldownDuration
        self.wasOverridden = wasOverridden
        self.overriddenAt = overriddenAt
    }
}
