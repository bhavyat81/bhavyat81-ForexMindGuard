// UserSettings.swift
// ForexMindGuard – Core Models
//
// Stores user preferences, thresholds, and watched pairs.
// Persisted via UserDefaults (with Codable encoding for complex types).

import Foundation
import Combine

// MARK: - NotificationPreferences
struct NotificationPreferences: Codable {
    var stressWarnings: Bool      = true
    var tradingLocks: Bool        = true
    var marketMovements: Bool     = true
    var aiExplanations: Bool      = true
    var watchSyncing: Bool        = true
    var soundEnabled: Bool        = true
    var hapticEnabled: Bool       = true
    var criticalAlerts: Bool      = false  // Requires special permission
}

// MARK: - UserSettings
final class UserSettings: ObservableObject, Codable {

    // MARK: Stress thresholds
    @Published var warningStressThreshold: Double = 70.0   // % – shows warning alert
    @Published var lockStressThreshold: Double    = 85.0   // % – locks trading UI

    // MARK: Cooldown
    @Published var cooldownDuration: TimeInterval = 15 * 60  // 15 minutes default

    // MARK: Heart rate
    @Published var restingHeartRate: Double = 65.0      // BPM – user's resting baseline
    @Published var elevatedHeartRateThreshold: Double = 100.0

    // MARK: Market alerts
    @Published var watchedPairIDs: [String] = ["EURUSD", "GBPUSD", "USDJPY"]
    @Published var significantMovePipsThreshold: Double = 20.0  // pips to trigger AI explainer
    @Published var movementTimeframeMinutes: Int = 15

    // MARK: Face tracking
    @Published var faceTrackingEnabled: Bool = true

    // MARK: Notifications
    @Published var notifications = NotificationPreferences()

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case warningStressThreshold, lockStressThreshold, cooldownDuration
        case restingHeartRate, elevatedHeartRateThreshold
        case watchedPairIDs, significantMovePipsThreshold, movementTimeframeMinutes
        case faceTrackingEnabled, notifications
    }

    // MARK: - Codable
    init() {}

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        warningStressThreshold      = try c.decodeIfPresent(Double.self, forKey: .warningStressThreshold) ?? 70.0
        lockStressThreshold         = try c.decodeIfPresent(Double.self, forKey: .lockStressThreshold)    ?? 85.0
        cooldownDuration            = try c.decodeIfPresent(TimeInterval.self, forKey: .cooldownDuration) ?? 900
        restingHeartRate            = try c.decodeIfPresent(Double.self, forKey: .restingHeartRate) ?? 65.0
        elevatedHeartRateThreshold  = try c.decodeIfPresent(Double.self, forKey: .elevatedHeartRateThreshold) ?? 100.0
        watchedPairIDs              = try c.decodeIfPresent([String].self, forKey: .watchedPairIDs) ?? ["EURUSD","GBPUSD","USDJPY"]
        significantMovePipsThreshold = try c.decodeIfPresent(Double.self, forKey: .significantMovePipsThreshold) ?? 20.0
        movementTimeframeMinutes    = try c.decodeIfPresent(Int.self, forKey: .movementTimeframeMinutes) ?? 15
        faceTrackingEnabled         = try c.decodeIfPresent(Bool.self, forKey: .faceTrackingEnabled) ?? true
        notifications               = try c.decodeIfPresent(NotificationPreferences.self, forKey: .notifications) ?? NotificationPreferences()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(warningStressThreshold, forKey: .warningStressThreshold)
        try c.encode(lockStressThreshold, forKey: .lockStressThreshold)
        try c.encode(cooldownDuration, forKey: .cooldownDuration)
        try c.encode(restingHeartRate, forKey: .restingHeartRate)
        try c.encode(elevatedHeartRateThreshold, forKey: .elevatedHeartRateThreshold)
        try c.encode(watchedPairIDs, forKey: .watchedPairIDs)
        try c.encode(significantMovePipsThreshold, forKey: .significantMovePipsThreshold)
        try c.encode(movementTimeframeMinutes, forKey: .movementTimeframeMinutes)
        try c.encode(faceTrackingEnabled, forKey: .faceTrackingEnabled)
        try c.encode(notifications, forKey: .notifications)
    }

    // MARK: - Persistence
    private static let defaultsKey = "userSettings"

    static func load() -> UserSettings {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return UserSettings()
        }
        return settings
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.defaultsKey)
    }
}
