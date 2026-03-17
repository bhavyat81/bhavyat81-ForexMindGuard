// EmotionRadarView.swift
// ForexMindGuard – Features/EmotionMonitor
//
// Spider/radar chart visualising the 4 emotion signal dimensions.

import SwiftUI

struct EmotionRadarView: View {

    let heartRateFactor: Double    // 0-1
    let facialFactor: Double       // 0-1
    let behavioralFactor: Double   // 0-1
    let timeOfDayFactor: Double    // 0-1

    private let labels = ["Heart Rate", "Facial", "Behaviour", "Time of Day"]
    private var values: [Double] { [heartRateFactor, facialFactor, behavioralFactor, timeOfDayFactor] }

    var body: some View {
        VStack(spacing: 8) {
            Text("Signal Breakdown")
                .font(.headline)
                .foregroundStyle(.white)

            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = size / 2 * 0.8
                let count = values.count

                ZStack {
                    // Grid circles
                    ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                        radarPolygon(center: center, radius: radius * scale, count: count, color: AppColors.cardBorder)
                    }

                    // Grid lines (spokes)
                    ForEach(0..<count, id: \.self) { i in
                        let angle = angle(for: i, count: count)
                        Path { path in
                            path.move(to: center)
                            path.addLine(to: point(center: center, radius: radius, angle: angle))
                        }
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                    }

                    // Data polygon
                    Path { path in
                        for (i, value) in values.enumerated() {
                            let a = angle(for: i, count: count)
                            let pt = point(center: center, radius: radius * value, angle: a)
                            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
                        }
                        path.closeSubpath()
                    }
                    .fill(AppColors.electricBlue.opacity(0.25))

                    Path { path in
                        for (i, value) in values.enumerated() {
                            let a = angle(for: i, count: count)
                            let pt = point(center: center, radius: radius * value, angle: a)
                            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
                        }
                        path.closeSubpath()
                    }
                    .stroke(AppColors.electricBlue, lineWidth: 2)

                    // Labels
                    ForEach(0..<count, id: \.self) { i in
                        let a = angle(for: i, count: count)
                        let labelPt = point(center: center, radius: radius * 1.18, angle: a)
                        Text(labels[i])
                            .font(.system(size: 10))
                            .foregroundStyle(AppColors.mutedText)
                            .position(labelPt)
                    }
                }
            }
            .frame(height: 200)
        }
        .padding(16)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers
    private func angle(for index: Int, count: Int) -> Double {
        (Double(index) / Double(count)) * 2 * .pi - .pi / 2
    }

    private func point(center: CGPoint, radius: Double, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }

    @ViewBuilder
    private func radarPolygon(center: CGPoint, radius: Double, count: Int, color: Color) -> some View {
        Path { path in
            for i in 0..<count {
                let a = angle(for: i, count: count)
                let pt = point(center: center, radius: radius, angle: a)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        }
        .stroke(color, lineWidth: 1)
    }
}

// MARK: - Preview
#Preview {
    EmotionRadarView(
        heartRateFactor: 0.72,
        facialFactor: 0.55,
        behavioralFactor: 0.40,
        timeOfDayFactor: 0.65
    )
    .padding()
    .background(AppColors.deepNavy)
    .preferredColorScheme(.dark)
}
