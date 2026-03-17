// StressHistoryView.swift
// ForexMindGuard – Features/EmotionMonitor
//
// Line chart showing the stress score over the last 5 minutes using Swift Charts.

import SwiftUI
import Charts

struct StressHistoryView: View {

    let snapshots: [EmotionSnapshot]

    // Show last 60 data points for performance
    private var displaySnapshots: [EmotionSnapshot] {
        Array(snapshots.suffix(60))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stress History")
                .font(.headline)
                .foregroundStyle(.white)

            Chart(displaySnapshots) { snapshot in
                LineMark(
                    x: .value("Time", snapshot.timestamp),
                    y: .value("Stress", snapshot.stressScore)
                )
                .foregroundStyle(AppColors.electricBlue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Time", snapshot.timestamp),
                    yStart: .value("Min", 0),
                    yEnd: .value("Stress", snapshot.stressScore)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.electricBlue.opacity(0.3), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                // Warning threshold line
                RuleMark(y: .value("Warning", StressThresholds.warning))
                    .foregroundStyle(AppColors.warmGold.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("⚠️ 70")
                            .font(.system(size: 8))
                            .foregroundStyle(AppColors.warmGold)
                    }

                // Lock threshold line
                RuleMark(y: .value("Lock", StressThresholds.lock))
                    .foregroundStyle(AppColors.dangerRed.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("🔒 85")
                            .font(.system(size: 8))
                            .foregroundStyle(AppColors.dangerRed)
                    }
            }
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(preset: .automatic, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine().foregroundStyle(AppColors.cardBorder)
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.timeString)
                                .font(.system(size: 9))
                                .foregroundStyle(AppColors.mutedText)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 25, 50, 70, 85, 100]) { value in
                    AxisGridLine().foregroundStyle(AppColors.cardBorder)
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v))")
                                .font(.system(size: 9))
                                .foregroundStyle(AppColors.mutedText)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel("Stress score history chart")
    }
}

// MARK: - Preview
#Preview {
    let snapshots = (0..<30).map { i in
        EmotionSnapshot(
            timestamp: Date().addingTimeInterval(Double(i - 30) * 10),
            dominantEmotion: .stressed,
            stressScore: Double.random(in: 20...90),
            heartRateFactor: 0.5,
            facialFactor: 0.4,
            behavioralFactor: 0.3,
            timeOfDayFactor: 0.5,
            rawHeartRate: 85
        )
    }
    return StressHistoryView(snapshots: snapshots)
        .padding(16)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(AppColors.deepNavy)
        .preferredColorScheme(.dark)
}
