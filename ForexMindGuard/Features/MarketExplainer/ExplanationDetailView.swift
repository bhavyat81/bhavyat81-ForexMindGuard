// ExplanationDetailView.swift
// ForexMindGuard – Features/MarketExplainer
//
// Full-screen explanation view with complete AI analysis and news sources.

import SwiftUI

struct ExplanationDetailView: View {

    let explanation: NewsExplanation
    @Environment(\.dismiss) private var dismiss

    private var sentimentColor: Color {
        switch explanation.sentiment {
        case .bullish: return AppColors.neonGreen
        case .bearish: return AppColors.dangerRed
        case .neutral: return .gray
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.deepNavy.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(explanation.pairSymbol)
                                    .font(.system(.largeTitle, design: .monospaced).bold())
                                    .foregroundStyle(.white)
                                Spacer()
                                sentimentBadge
                            }

                            Text(explanation.headline)
                                .font(.title3.bold())
                                .foregroundStyle(.white)

                            Text(explanation.timestamp.newsDateString)
                                .font(.caption)
                                .foregroundStyle(AppColors.mutedText)
                        }

                        Divider().background(AppColors.cardBorder)

                        // Summary
                        Text(explanation.summary)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(12)
                            .background(sentimentColor.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        // AI Explanation
                        VStack(alignment: .leading, spacing: 8) {
                            Label("AI Analysis", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundStyle(AppColors.electricBlue)

                            Text(explanation.aiExplanation)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.9))
                                .lineSpacing(4)
                        }

                        Divider().background(AppColors.cardBorder)

                        // Confidence
                        HStack {
                            Label("Confidence", systemImage: "gauge.with.dots.needle.bottom.50percent")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.mutedText)
                            Spacer()
                            Text(explanation.formattedConfidence)
                                .font(.subheadline.bold())
                                .foregroundStyle(AppColors.electricBlue)
                        }

                        // Sources
                        if !explanation.sources.isEmpty {
                            SourcesListView(sources: explanation.sources)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppColors.electricBlue)
                }
            }
        }
    }

    private var sentimentBadge: some View {
        HStack(spacing: 4) {
            Text(explanation.sentiment.emoji)
            Text(explanation.sentiment.rawValue)
                .font(.subheadline.bold())
                .foregroundStyle(sentimentColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(sentimentColor.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Preview
#Preview {
    ExplanationDetailView(explanation: .sample)
        .preferredColorScheme(.dark)
}
