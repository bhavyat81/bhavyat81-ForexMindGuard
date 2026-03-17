// SourcesListView.swift
// ForexMindGuard – Features/MarketExplainer
//
// Clickable list of news source links cited in an AI explanation.

import SwiftUI

struct SourcesListView: View {

    let sources: [NewsSource]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Sources", systemImage: "newspaper.fill")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(sources) { source in
                Link(destination: source.url) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "link.circle.fill")
                            .foregroundStyle(AppColors.electricBlue)
                            .font(.body)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(source.title)
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            HStack {
                                Text(source.sourceName)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.electricBlue)
                                Text("·")
                                    .foregroundStyle(AppColors.mutedText)
                                Text(source.publishedAt.relativeString)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.mutedText)
                            }
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(AppColors.mutedText)
                    }
                }
                .padding(12)
                .background(AppColors.darkCharcoal)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SourcesListView(sources: [.sample, .sample])
        .padding()
        .background(AppColors.deepNavy)
        .preferredColorScheme(.dark)
}
