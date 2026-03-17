// HapticFeedbackService.swift
// ForexMindGuard – Core/Services/Notifications
//
// Provides distinct haptic patterns for different app events.

import UIKit

final class HapticFeedbackService {

    static let shared = HapticFeedbackService()
    private init() {}

    // MARK: - Pattern generators

    /// Played when stress warning threshold is crossed
    func playWarningPattern() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Played when trading is locked
    func playLockPattern() {
        // Three strong impacts to signal the lock
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.prepare()
        impact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { impact.impactOccurred() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) { impact.impactOccurred() }
    }

    /// Played when trading is unlocked / cooldown complete
    func playUnlockPattern() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Played when a significant market movement is detected
    func playMarketAlertPattern() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { impact.impactOccurred() }
    }

    /// Light tap for UI interactions
    func playSelectionFeedback() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// Error feedback
    func playErrorFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
