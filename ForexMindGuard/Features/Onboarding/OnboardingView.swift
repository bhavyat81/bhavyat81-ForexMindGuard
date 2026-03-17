// OnboardingView.swift
// ForexMindGuard – Features/Onboarding
//
// Multi-step onboarding flow introducing the app's two core features.

import SwiftUI

struct OnboardingView: View {

    @Binding var isOnboardingComplete: Bool
    @State private var currentPage: Int = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "brain.head.profile",
            iconColor: AppColors.electricBlue,
            title: "Emotion AI Guardian",
            subtitle: "Your mental state matters",
            description: "ForexMindGuard monitors your heart rate, facial expressions, and trading behaviour in real-time to detect stress, fear, and greed before they hurt your trades.",
            highlight: "Auto-locks trading when you're too stressed to trade safely."
        ),
        OnboardingPage(
            icon: "waveform.badge.magnifyingglass",
            iconColor: AppColors.neonGreen,
            title: "AI Market Explainer",
            subtitle: "Understand every big move",
            description: "When a currency pair moves significantly, our AI instantly explains WHY in plain English — citing real news sources and sentiment analysis.",
            highlight: "Never wonder \"why did it move?\" again."
        ),
        OnboardingPage(
            icon: "shield.lefthalf.filled.badge.checkmark",
            iconColor: AppColors.warmGold,
            title: "Smart Shield",
            subtitle: "The ultimate safety net",
            description: "When both systems activate simultaneously — high stress AND a big market move — Smart Shield pauses trading and shows you the full picture.",
            highlight: "Your emotions + the market, combined into one protective overlay."
        )
    ]

    var body: some View {
        ZStack {
            AppColors.deepNavy.ignoresSafeArea()

            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") { isOnboardingComplete = true }
                        .font(.subheadline)
                        .foregroundStyle(AppColors.mutedText)
                        .padding(.trailing, 20)
                        .padding(.top, 16)
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { idx in
                        onboardingPageView(pages[idx])
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { idx in
                        Capsule()
                            .fill(idx == currentPage ? AppColors.electricBlue : AppColors.cardBorder)
                            .frame(width: idx == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }

                // CTA button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        isOnboardingComplete = true
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.electricBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .padding(.top, 16)
            }
        }
    }

    private func onboardingPageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundStyle(page.iconColor)
                .padding(24)
                .background(page.iconColor.opacity(0.12))
                .clipShape(Circle())

            VStack(spacing: 8) {
                Text(page.subtitle)
                    .font(.caption.uppercaseSmallCaps())
                    .foregroundStyle(page.iconColor)

                Text(page.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }

            Text(page.description)
                .font(.body)
                .foregroundStyle(AppColors.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text(page.highlight)
                .font(.subheadline.bold())
                .foregroundStyle(page.iconColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(page.iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 32)

            Spacer()
        }
    }
}

// MARK: - Onboarding page model
private struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
    let highlight: String
}

// MARK: - Preview
#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
        .preferredColorScheme(.dark)
}
