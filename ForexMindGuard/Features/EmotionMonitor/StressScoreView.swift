// StressScoreView.swift
// ForexMindGuard – Features/EmotionMonitor
//
// Large stress score display with colour gradient that transitions from
// neon green (calm) through orange to danger red (high stress).

import SwiftUI

struct StressScoreView: View {

    let score: Double  // 0-100

    @State private var animatedScore: Double = 0

    private var scoreColor: Color { AppColors.stressColor(for: score) }
    private var statusLabel: String {
        switch score {
        case ..<40:   return "LOW"
        case 40..<70: return "MODERATE"
        case 70..<85: return "HIGH ⚠️"
        default:      return "CRITICAL 🔒"
        }
    }

    var body: some View {
        HStack(spacing: 20) {
            // Circular score gauge
            ZStack {
                Circle()
                    .stroke(AppColors.cardBorder, lineWidth: 8)
                    .frame(width: 90, height: 90)

                Circle()
                    .trim(from: 0, to: animatedScore / 100)
                    .stroke(
                        AngularGradient(
                            colors: [AppColors.neonGreen, AppColors.warmGold, AppColors.dangerRed],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.6), value: animatedScore)

                VStack(spacing: 0) {
                    Text(score.asStressPercent)
                        .font(.system(.title2, design: .monospaced).bold())
                        .foregroundStyle(scoreColor)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.4), value: score)
                    Text("%")
                        .font(.caption2)
                        .foregroundStyle(AppColors.mutedText)
                }
            }

            // Status text
            VStack(alignment: .leading, spacing: 6) {
                Text("Stress Level")
                    .font(.caption)
                    .foregroundStyle(AppColors.mutedText)

                Text(statusLabel)
                    .font(.headline.bold())
                    .foregroundStyle(scoreColor)

                // Mini threshold markers
                HStack(spacing: 4) {
                    thresholdBar(value: 70, label: "⚠️ 70")
                    thresholdBar(value: 85, label: "🔒 85")
                }
            }

            Spacer()
        }
        .onAppear { animatedScore = score }
        .onChange(of: score) { _, new in animatedScore = new }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Stress score: \(Int(score)) percent, \(statusLabel)")
    }

    private func thresholdBar(value: Double, label: String) -> some View {
        HStack(spacing: 3) {
            Rectangle()
                .fill(score >= value ? AppColors.dangerRed : AppColors.cardBorder)
                .frame(width: 3, height: 12)
                .clipShape(Capsule())
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(score >= value ? AppColors.dangerRed : AppColors.mutedText)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        StressScoreView(score: 22).padding().background(AppColors.darkCharcoal).clipShape(RoundedRectangle(cornerRadius: 16))
        StressScoreView(score: 72).padding().background(AppColors.darkCharcoal).clipShape(RoundedRectangle(cornerRadius: 16))
        StressScoreView(score: 91).padding().background(AppColors.darkCharcoal).clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .padding()
    .background(AppColors.deepNavy)
    .preferredColorScheme(.dark)
}
