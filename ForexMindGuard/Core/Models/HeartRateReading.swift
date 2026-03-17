// HeartRateReading.swift
// ForexMindGuard – Core Models
//
// Represents a single heart rate sample captured from HealthKit or Apple Watch.

import Foundation
import HealthKit

// MARK: - HeartRateReading
struct HeartRateReading: Codable, Identifiable, Equatable {
    let id: UUID
    let bpm: Double            // Beats per minute
    let timestamp: Date
    let source: HeartRateSource
    let hrv: Double?           // Heart Rate Variability in ms (optional, from HKQuantityTypeIdentifier.heartRateVariabilitySDNN)

    init(
        id: UUID = UUID(),
        bpm: Double,
        timestamp: Date = Date(),
        source: HeartRateSource = .healthKit,
        hrv: Double? = nil
    ) {
        self.id = id
        self.bpm = bpm
        self.timestamp = timestamp
        self.source = source
        self.hrv = hrv
    }

    // MARK: Derived properties

    /// Returns true when BPM is above the user's elevated-heart-rate threshold.
    /// Default resting threshold is 100 BPM; a proper implementation reads from UserSettings.
    var isElevated: Bool { bpm > UserDefaults.standard.elevatedHeartRateThreshold }

    /// Normalised 0-1 factor used by StressCalculator.
    /// Maps resting (50–70 BPM) → 0, elevated (120+ BPM) → 1.
    var stressFactor: Double {
        let clamped = min(max(bpm, 50), 150)
        return (clamped - 50) / 100
    }

    /// Human-readable zone label
    var zone: HeartRateZone {
        switch bpm {
        case ..<60:  return .resting
        case 60..<80: return .normal
        case 80..<100: return .elevated
        case 100..<120: return .high
        default:      return .critical
        }
    }

    // MARK: Sample data
    static let sample = HeartRateReading(bpm: 88, source: .appleWatch)
    static let elevated = HeartRateReading(bpm: 112, source: .appleWatch)
    static let resting  = HeartRateReading(bpm: 62, source: .healthKit)
}

// MARK: - Supporting types

enum HeartRateSource: String, Codable {
    case healthKit  = "HealthKit"
    case appleWatch = "Apple Watch"
    case manual     = "Manual"
    case mock       = "Mock"
}

enum HeartRateZone: String, CaseIterable {
    case resting  = "Resting"
    case normal   = "Normal"
    case elevated = "Elevated"
    case high     = "High"
    case critical = "Critical"

    var color: String {  // Using string so we don't import SwiftUI in the model
        switch self {
        case .resting:  return "neonGreen"
        case .normal:   return "systemGreen"
        case .elevated: return "systemYellow"
        case .high:     return "systemOrange"
        case .critical: return "dangerRed"
        }
    }
}

// MARK: - UserDefaults convenience
extension UserDefaults {
    private enum Keys {
        static let elevatedHRThreshold = "elevatedHeartRateThreshold"
    }
    /// Default 100 BPM; user can customise in Settings
    var elevatedHeartRateThreshold: Double {
        get { double(forKey: Keys.elevatedHRThreshold) == 0 ? 100 : double(forKey: Keys.elevatedHRThreshold) }
        set { set(newValue, forKey: Keys.elevatedHRThreshold) }
    }
}
