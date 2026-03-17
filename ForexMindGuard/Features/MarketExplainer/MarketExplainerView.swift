// MarketExplainerView.swift
// ForexMindGuard – Features/MarketExplainer
//
// Scrollable feed of AI-generated market movement explanations.

import SwiftUI

struct MarketExplainerView: View {

    @EnvironmentObject var vm: MarketExplainerViewModel
    @State private var selectedExplanation: NewsExplanation?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.deepNavy.ignoresSafeArea()

                if vm.explanations.isEmpty && !vm.isLoading {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if vm.isLoading {
                                loadingCard
                            }
                            ForEach(vm.explanations) { explanation in
                                PriceMovementCard(explanation: explanation)
                                    .onTapGesture { selectedExplanation = explanation }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .refreshable { vm.refresh() }
                }
            }
            .navigationTitle("AI Explainer")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedExplanation) { explanation in
                ExplanationDetailView(explanation: explanation)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.badge.magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(AppColors.electricBlue)
            Text("Watching for Market Moves")
                .font(.headline)
                .foregroundStyle(.white)
            Text("When a currency pair moves significantly,\nthe AI will explain why here.")
                .font(.subheadline)
                .foregroundStyle(AppColors.mutedText)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
    }

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(AppColors.electricBlue)
            Text("Analysing market movement…")
                .font(.subheadline)
                .foregroundStyle(AppColors.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview
#Preview {
    MarketExplainerView()
        .environmentObject(MarketExplainerViewModel())
        .preferredColorScheme(.dark)
}
