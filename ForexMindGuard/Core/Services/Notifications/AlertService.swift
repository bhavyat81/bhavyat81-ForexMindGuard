// AlertService.swift
// ForexMindGuard – Core/Services/Notifications
//
// Manages local notifications for stress warnings, trading locks, and market alerts.

import Foundation
import UserNotifications

final class AlertService {

    private let center = UNUserNotificationCenter.current()

    // MARK: - Stress warning notification
    func sendStressWarning(score: Double, emotion: EmotionState) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Stress Warning"
        content.body  = "Your stress score is \(Int(score)). \(emotion.tradingWarning ?? "Consider taking a break.")"
        content.sound = .default
        content.categoryIdentifier = NotificationConstants.stressCategoryID

        schedule(content: content, identifier: NotificationConstants.stressWarningNotifID, delay: 0)
    }

    // MARK: - Trading locked notification
    func sendTradingLocked(score: Double, emotion: EmotionState, cooldown: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "🔒 Trading Locked"
        content.body  = "Stress score \(Int(score)) — trading locked for \(Int(cooldown/60)) minutes. \(emotion.tradingWarning ?? "")"
        content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName("lock_alert.aiff"), withAudioVolume: 0.8)
        content.categoryIdentifier = NotificationConstants.stressCategoryID
        content.interruptionLevel = .critical

        schedule(content: content, identifier: NotificationConstants.tradingLockedNotifID, delay: 0)
    }

    // MARK: - Market movement notification
    func sendMarketMovement(movement: PriceMovement) {
        let content = UNMutableNotificationContent()
        content.title = "\(movement.direction.symbol) \(movement.pair) — \(movement.formattedPips)"
        content.body  = "Significant move detected in \(movement.timeframeLabel). Tap to see AI explanation."
        content.sound = .default
        content.categoryIdentifier = NotificationConstants.marketCategoryID

        schedule(content: content, identifier: "\(NotificationConstants.marketMovementNotifID)_\(movement.id)", delay: 0)
    }

    // MARK: - Schedule helper
    private func schedule(content: UNMutableNotificationContent, identifier: String, delay: TimeInterval) {
        let trigger = delay > 0
            ? UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 0.1), repeats: false)
            : nil
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { error in
            if let error { print("[AlertService] Notification error: \(error)") }
        }
    }

    // MARK: - Cancel pending
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
