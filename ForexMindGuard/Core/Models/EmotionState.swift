// EmotionState.swift
// ForexMindGuard – Core Models
//
// Represents the trader's detected emotional state at any given moment.
// The composite StressScore (0–100) is the primary signal used by
// TradingLockManager to trigger warnings and locks.

import Foundation
import SwiftUI

// MARK: - Emotion enum
/// Primary emotion detected from face tracking + heart rate analysis.
enum EmotionState: String, Codable, CaseIterable, Identifiable {
    case calm       = "Calm"
    case neutral    = "Neutral"
    case anxious    = "Anxious"
    case stressed   = "Stressed"
    case fearful    = "Fearful"
    case greedy     = "Greedy"
    case excited    = "Excited"
    case angry      = "Angry"

    var id: String { rawValue }

    /// System SF Symbol representing this emotion
    var symbol: String {
        switch self {
        case .calm:    return "face.smiling"
        case .neutral: return "minus.circle"
        case .anxious: return "exclamationmark.circle"
        case .stressed: return "bolt.trianglebadge.exclamationmark"
        case .fearful: return "eye.trianglebadge.exclamationmark"
        case .greedy:  return "dollarsign.circle"
        case .excited: return "star.circle"
        case .angry:   return "flame"
        }
    }

    /// Trading risk associated with this emotion (higher = more dangerous)
    var riskLevel: Int {
        switch self {
        case .calm:    return 0
        case .neutral: return 1
        case .anxious: return 3
        case .excited: return 4
        case .greedy:  return 5
        case .stressed: return 6
        case .fearful: return 7
        case .angry:   return 9
        }
    }

    /// Descriptive trading warning message
    var tradingWarning: String? {
        switch self {
        case .calm, .neutral:
            return nil
        case .anxious:
            return "You appear anxious. Consider reducing position sizes."
        case .stressed:
            return "High stress detected. Take a break before placing new trades."
        case .fearful:
            return "Fear detected — avoid closing positions prematurely."
        case .greedy:
            return "Greed detected — stick to your risk management rules."
        case .excited:
            return "Over-excitement can lead to FOMO trades. Slow down."
        case .angry:
            return "Anger detected — DO NOT trade. Step away immediately."
        }
    }

    /// App theme color for this emotion
    var color: Color {
        switch self {
        case .calm:    return AppColors.neonGreen
        case .neutral: return .gray
        case .anxious: return .yellow
        case .stressed: return .orange
        case .fearful: return AppColors.electricBlue
        case .greedy:  return .purple
        case .excited: return .cyan
        case .angry:   return AppColors.dangerRed
        }
    }
}

// MARK: - Composite emotion snapshot
/// A point-in-time snapshot of all emotion signals combined into a single score.
struct EmotionSnapshot: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let dominantEmotion: EmotionState
    let stressScore: Double          // 0–100
    let heartRateFactor: Double      // 0–1 component
    let facialFactor: Double         // 0–1 component
    let behavioralFactor: Double     // 0–1 component
    let timeOfDayFactor: Double      // 0–1 component
    let rawHeartRate: Double         // BPM
    let notes: String?               // Optional manual journal note

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        dominantEmotion: EmotionState,
        stressScore: Double,
        heartRateFactor: Double,
        facialFactor: Double,
        behavioralFactor: Double,
        timeOfDayFactor: Double,
        rawHeartRate: Double,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.dominantEmotion = dominantEmotion
        self.stressScore = stressScore
        self.heartRateFactor = heartRateFactor
        self.facialFactor = facialFactor
        self.behavioralFactor = behavioralFactor
        self.timeOfDayFactor = timeOfDayFactor
        self.rawHeartRate = rawHeartRate
        self.notes = notes
    }

    /// Whether this snapshot triggered a warning
    var isWarning: Bool { stressScore > StressThresholds.warning }
    /// Whether this snapshot triggered a lock
    var isLocked: Bool  { stressScore > StressThresholds.lock }

    // MARK: Sample data
    static let sample = EmotionSnapshot(
        dominantEmotion: .stressed,
        stressScore: 78.5,
        heartRateFactor: 0.72,
        facialFactor: 0.68,
        behavioralFactor: 0.55,
        timeOfDayFactor: 0.60,
        rawHeartRate: 98.0
    )

    static let calm = EmotionSnapshot(
        dominantEmotion: .calm,
        stressScore: 22.0,
        heartRateFactor: 0.20,
        facialFactor: 0.15,
        behavioralFactor: 0.10,
        timeOfDayFactor: 0.30,
        rawHeartRate: 62.0
    )
}

// MARK: - Stress thresholds (global constants for convenience)
enum StressThresholds {
    static let warning: Double = 70.0
    static let lock: Double    = 85.0
}
