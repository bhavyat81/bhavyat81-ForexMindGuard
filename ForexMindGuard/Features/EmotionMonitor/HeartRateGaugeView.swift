// HeartRateGaugeView.swift
// ForexMindGuard – Features/EmotionMonitor
//
// Animated circular BPM gauge component.

import SwiftUI

struct HeartRateGaugeView: View {

    let bpm: Double
    let isElevated: Bool

    @State private var animatedBPM: Double = 0
    @State private var heartScale: CGFloat = 1.0

    private var gaugeColor: Color {
        isElevated ? AppColors.dangerRed : AppColors.electricBlue
    }

    private var normalizedValue: Double {
        bpm.normalized(min: 40, max: 180)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background track
                Circle()
                    .stroke(AppColors.cardBorder, lineWidth: 6)
                    .frame(width: 80, height: 80)

                // Progress arc
                Circle()
                    .trim(from: 0, to: normalizedValue)
                    .stroke(
                        gaugeColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: normalizedValue)

                // Heart icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(gaugeColor)
                    .scaleEffect(heartScale)
                    .animation(
                        Animation.easeInOut(duration: 60.0 / max(bpm, 40))
                            .repeatForever(autoreverses: true),
                        value: heartScale
                    )
                    .onAppear { heartScale = 1.15 }
            }

            Text("\(Int(bpm))")
                .font(.system(.title2, design: .monospaced).bold())
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: bpm)

            Text("BPM")
                .font(.caption)
                .foregroundStyle(AppColors.mutedText)

            if isElevated {
                Text("ELEVATED")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(AppColors.dangerRed)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColors.dangerRed.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Heart rate: \(Int(bpm)) BPM\(isElevated ? ", elevated" : "")")
    }
}

// MARK: - Preview
#Preview {
    HStack {
        HeartRateGaugeView(bpm: 88, isElevated: false)
        HeartRateGaugeView(bpm: 115, isElevated: true)
    }
    .padding()
    .background(AppColors.deepNavy)
    .preferredColorScheme(.dark)
}
