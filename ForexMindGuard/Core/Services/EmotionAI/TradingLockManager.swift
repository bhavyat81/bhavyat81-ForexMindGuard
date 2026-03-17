// TradingLockManager.swift
// ForexMindGuard – Core/Services/EmotionAI
//
// Monitors StressCalculator output and manages the trading lock lifecycle:
//   1. When stress > warning threshold → sends warning notification
//   2. When stress > lock threshold → activates trading lock + starts cooldown
//   3. Cooldown counts down; lock releases automatically when timer expires
//   4. User can override with double confirmation (logged for session review)

import Foundation
import Combine
import SwiftUI

// MARK: - Lock state
enum TradingLockState: Equatable {
    case unlocked
    case warning(score: Double)          // Above warning threshold
    case locked(cooldownRemaining: TimeInterval)  // Full lock with countdown
    case cooldownComplete                 // Lock lifted, resume trading
}

// MARK: - TradingLockManager
final class TradingLockManager: ObservableObject {

    // MARK: Published
    @Published private(set) var lockState: TradingLockState = .unlocked
    @Published private(set) var isLocked: Bool = false
    @Published private(set) var cooldownRemaining: TimeInterval = 0
    @Published private(set) var lockHistory: [LockEvent] = []
    @Published var showOverrideConfirmation: Bool = false

    // MARK: Dependencies
    private let alertService: AlertService
    private var stressSubscription: AnyCancellable?
    private var cooldownTimer: Timer?
    private var pendingLockEvent: LockEvent?

    // MARK: Settings
    var cooldownDuration: TimeInterval = DefaultThresholds.cooldownSeconds
    var warningThreshold: Double       = DefaultThresholds.warningStress
    var lockThreshold: Double          = DefaultThresholds.lockStress

    init(alertService: AlertService = AlertService()) {
        self.alertService = alertService
    }

    // MARK: - Subscribe to stress calculator
    func observe(stressCalculator: StressCalculator) {
        stressSubscription = stressCalculator.$currentScore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] score in
                self?.handleScore(score, emotion: stressCalculator.currentEmotion)
            }
    }

    // MARK: - Score handling
    private func handleScore(_ score: Double, emotion: EmotionState) {
        guard !isLocked else { return }  // Already locked, ignore further changes

        if score > lockThreshold {
            activateLock(score: score, emotion: emotion)
        } else if score > warningThreshold {
            if case .warning = lockState { return }  // Already in warning state
            lockState = .warning(score: score)
            alertService.sendStressWarning(score: score, emotion: emotion)
        } else {
            if case .unlocked = lockState { return }
            lockState = .unlocked
        }
    }

    // MARK: - Activate lock
    private func activateLock(score: Double, emotion: EmotionState) {
        isLocked = true
        cooldownRemaining = cooldownDuration

        let event = LockEvent(
            stressScoreAtTrigger: score,
            emotion: emotion,
            cooldownDuration: cooldownDuration
        )
        pendingLockEvent = event
        lockHistory.append(event)

        lockState = .locked(cooldownRemaining: cooldownRemaining)
        alertService.sendTradingLocked(score: score, emotion: emotion, cooldown: cooldownDuration)
        HapticFeedbackService.shared.playLockPattern()
        startCooldownTimer()
    }

    // MARK: - Cooldown timer
    private func startCooldownTimer() {
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.cooldownRemaining -= 1
            self.lockState = .locked(cooldownRemaining: self.cooldownRemaining)
            if self.cooldownRemaining <= 0 {
                self.releaseLock(wasOverridden: false)
            }
        }
    }

    // MARK: - Release lock
    private func releaseLock(wasOverridden: Bool) {
        cooldownTimer?.invalidate()
        cooldownTimer = nil
        isLocked = false
        cooldownRemaining = 0
        lockState = .cooldownComplete

        // Update lock event record
        if var event = pendingLockEvent {
            event.wasOverridden = wasOverridden
            event.overriddenAt  = wasOverridden ? Date() : nil
            // Replace in history
            if let idx = lockHistory.firstIndex(where: { $0.id == event.id }) {
                lockHistory[idx] = event
            }
            pendingLockEvent = nil
        }

        HapticFeedbackService.shared.playUnlockPattern()

        // Auto-reset to unlocked after showing "cooldown complete" for 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.lockState = .unlocked
        }
    }

    // MARK: - Override (user-initiated)
    func requestOverride() {
        showOverrideConfirmation = true
    }

    func confirmOverride() {
        showOverrideConfirmation = false
        releaseLock(wasOverridden: true)
    }

    func cancelOverride() {
        showOverrideConfirmation = false
    }
}
