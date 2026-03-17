// StressAlertView.swift
// ForexMindGuardWatch
//
// Alert view shown on Apple Watch when stress threshold is crossed.

import SwiftUI
import WatchKit

struct StressAlertView: View {

    @EnvironmentObject var connectivity: WatchConnectivityService
    @State private var didPlayHaptic = false

    var body: some View {
        VStack(spacing: 8) {
            if connectivity.isTradingLocked {
                lockedView
            } else if connectivity.stressScore > 70 {
                warningView
            } else {
                safeView
            }
        }
        .onChange(of: connectivity.isTradingLocked) { _, locked in
            if locked && !didPlayHaptic {
                WKInterfaceDevice.current().play(.failure)
                didPlayHaptic = true
            } else if !locked {
                didPlayHaptic = false
                WKInterfaceDevice.current().play(.success)
            }
        }
        .onChange(of: connectivity.stressScore) { _, score in
            if score > 70 && !connectivity.isTradingLocked {
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }

    // MARK: - States

    private var safeView: some View {
        VStack(spacing: 6) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 30))
                .foregroundStyle(.green)
            Text("All Clear")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Trading safe")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var warningView: some View {
        VStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28))
                .foregroundStyle(.yellow)
                .symbolEffect(.bounce, isActive: true)
            Text("⚠️ Warning")
                .font(.headline)
                .foregroundStyle(.yellow)
            Text("Stress: \(Int(connectivity.stressScore))%")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
            Text("Trade carefully")
                .font(.caption2)
                .foregroundStyle(.yellow)
        }
    }

    private var lockedView: some View {
        VStack(spacing: 6) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 28))
                .foregroundStyle(.red)
            Text("LOCKED")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(.red)
            Text("Step away & breathe")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if connectivity.cooldownRemaining > 0 {
                Text(Date.countdownString(from: connectivity.cooldownRemaining))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    StressAlertView()
        .environmentObject(WatchConnectivityService.shared)
}
