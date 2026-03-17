// QuickEmotionView.swift
// ForexMindGuardWatch
//
// Glanceable emotion and stress summary on Apple Watch.

import SwiftUI

struct QuickEmotionView: View {

    @EnvironmentObject var connectivity: WatchConnectivityService

    var stressColor: Color {
        let s = connectivity.stressScore
        if s < 40 { return .green }
        if s < 70 { return .yellow }
        if s < 85 { return .orange }
        return .red
    }

    var body: some View {
        VStack(spacing: 6) {
            // Stress score ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: connectivity.stressScore / 100)
                    .stroke(stressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: connectivity.stressScore)

                VStack(spacing: 0) {
                    Text("\(Int(connectivity.stressScore))")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                    Text("%")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 70, height: 70)

            Text("Stress")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(connectivity.currentEmotion)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(stressColor)

            if connectivity.isTradingLocked {
                Label("LOCKED", systemImage: "lock.fill")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.red.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .navigationTitle("Guard")
    }
}

#Preview {
    QuickEmotionView()
        .environmentObject(WatchConnectivityService.shared)
}
