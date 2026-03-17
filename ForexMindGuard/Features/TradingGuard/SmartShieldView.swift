// SmartShieldView.swift
// ForexMindGuard – Features/TradingGuard
//
// Combined "Smart Shield" overlay — activates when BOTH high stress AND a
// significant market move are detected simultaneously.

import SwiftUI

struct SmartShieldView: View {

    @EnvironmentObject var vm: TradingGuardViewModel
    @State private var showExplanation = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Dark blur backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // Shield icon with pulse
                ZStack {
                    Circle()
                        .stroke(AppColors.electricBlue.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: pulseScale
                        )

                    Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundStyle(AppColors.electricBlue)
                }
                .onAppear { pulseScale = 1.25 }

                Text("Smart Shield Active")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("High stress + significant market move\ndetected simultaneously")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedText)
                    .multilineTextAlignment(.center)

                // Stats row
                HStack(spacing: 24) {
                    statCard(
                        icon: vm.currentEmotion.symbol,
                        label: vm.currentEmotion.rawValue,
                        color: vm.currentEmotion.color
                    )
                    statCard(
                        icon: "chart.line.downtrend.xyaxis",
                        label: vm.latestMovement?.formattedPips ?? "—",
                        color: AppColors.dangerRed
                    )
                    statCard(
                        icon: "bolt.trianglebadge.exclamationmark",
                        label: "\(Int(vm.latestStressScore))%",
                        color: AppColors.stressColor(for: vm.latestStressScore)
                    )
                }

                // Cooldown timer
                if vm.isLocked {
                    CooldownTimerView(remaining: vm.cooldownRemaining)
                }

                // Recommendation
                Text("📋 Recommendation: Step away from the screen, breathe, and review the market explanation before trading again.")
                    .font(.caption)
                    .foregroundStyle(AppColors.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // Action buttons
                VStack(spacing: 12) {
                    if let explanation = vm.latestExplanation {
                        Button(action: { showExplanation = true }) {
                            Label("Read Full Explanation", systemImage: "sparkles")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.electricBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .sheet(isPresented: $showExplanation) {
                            ExplanationDetailView(explanation: explanation)
                        }
                    }

                    Button(action: { vm.requestOverride() }) {
                        Text("Override (Not Recommended)")
                            .font(.caption)
                            .foregroundStyle(AppColors.warmGold)
                    }
                    .confirmationDialog(
                        "Override Smart Shield?",
                        isPresented: $vm.lockManager.showOverrideConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Yes, Override", role: .destructive) { vm.confirmOverride() }
                        Button("Cancel", role: .cancel) { vm.cancelOverride() }
                    } message: {
                        Text("Overriding while stressed and during a volatile market move is high risk. Are you absolutely sure?")
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 40)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Smart Shield active. Trading locked due to high stress and market movement.")
    }

    private func statCard(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview
#Preview {
    SmartShieldView()
        .environmentObject(TradingGuardViewModel())
        .preferredColorScheme(.dark)
}
