// PriceMovementCard.swift
// ForexMindGuard – Features/MarketExplainer
//
// Card UI component showing a price movement with sentiment badge.

import SwiftUI

struct PriceMovementCard: View {

    let explanation: NewsExplanation

    private var sentimentColor: Color {
        switch explanation.sentiment {
        case .bullish: return AppColors.neonGreen
        case .bearish: return AppColors.dangerRed
        case .neutral: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack {
                Text(explanation.pairSymbol)
                    .font(.system(.headline, design: .monospaced).bold())
                    .foregroundStyle(.white)

                Spacer()

                // Sentiment badge
                HStack(spacing: 4) {
                    Text(explanation.sentiment.emoji)
                    Text(explanation.sentiment.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(sentimentColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(sentimentColor.opacity(0.15))
                .clipShape(Capsule())

                Text(explanation.timestamp.relativeString)
                    .font(.caption)
                    .foregroundStyle(AppColors.mutedText)
            }

            // Headline
            if explanation.isLoading {
                ProgressView()
                    .tint(AppColors.electricBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(explanation.headline)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(explanation.summary)
                    .font(.caption)
                    .foregroundStyle(AppColors.mutedText)
                    .lineLimit(3)
            }

            // Footer
            HStack {
                Image(systemName: "newspaper")
                    .font(.caption2)
                    .foregroundStyle(AppColors.mutedText)
                Text("\(explanation.sources.count) source\(explanation.sources.count != 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundStyle(AppColors.mutedText)

                Spacer()

                HStack(spacing: 3) {
                    Text("Confidence:")
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedText)
                    Text(explanation.formattedConfidence)
                        .font(.caption.bold())
                        .foregroundStyle(AppColors.electricBlue)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColors.mutedText)
            }
        }
        .padding(16)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(sentimentColor.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(explanation.pairSymbol), \(explanation.sentiment.rawValue), \(explanation.headline)")
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        PriceMovementCard(explanation: .sample)
        PriceMovementCard(explanation: .loading)
    }
    .padding()
    .background(AppColors.deepNavy)
    .preferredColorScheme(.dark)
}
