// CooldownTimerView.swift
// ForexMindGuard – Features/TradingGuard
//
// Animated circular countdown timer for the trading lock cooldown period.

import SwiftUI

struct CooldownTimerView: View {

    let remaining: TimeInterval
    var totalDuration: TimeInterval = DefaultThresholds.cooldownSeconds

    private var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (remaining / totalDuration)
    }

    private var timeString: String {
        Date.countdownString(from: remaining)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(AppColors.cardBorder, lineWidth: 8)
                    .frame(width: 100, height: 100)

                // Progress arc (clockwise fill as time passes)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AppColors.electricBlue,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                // Time text
                VStack(spacing: 0) {
                    Text(timeString)
                        .font(.system(.headline, design: .monospaced).bold())
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.5), value: timeString)
                    Text("remaining")
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.mutedText)
                }
            }

            Text("Cooldown")
                .font(.caption)
                .foregroundStyle(AppColors.mutedText)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cooldown timer: \(timeString) remaining")
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 30) {
        CooldownTimerView(remaining: 750, totalDuration: 900)
        CooldownTimerView(remaining: 300, totalDuration: 900)
        CooldownTimerView(remaining: 45,  totalDuration: 900)
    }
    .padding()
    .background(AppColors.deepNavy)
    .preferredColorScheme(.dark)
}
