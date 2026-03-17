// LockScreenView.swift
// ForexMindGuard – Features/TradingGuard
//
// Full-screen trading locked overlay shown as a .fullScreenCover.

import SwiftUI

struct LockScreenView: View {

    @EnvironmentObject var vm: TradingGuardViewModel
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        ZStack {
            AppColors.deepNavy.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Lock icon with shake animation
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.dangerRed)
                    .offset(x: shakeOffset)
                    .onAppear { triggerShake() }

                VStack(spacing: 8) {
                    Text("Trading Locked")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Your stress level exceeded the safe threshold.\nTake a break before continuing.")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.mutedText)
                        .multilineTextAlignment(.center)
                }

                // Score display
                VStack(spacing: 4) {
                    Text("Stress Score at Lock")
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedText)
                    Text("\(Int(vm.latestStressScore))%")
                        .font(.system(size: 56, weight: .heavy, design: .monospaced))
                        .foregroundStyle(AppColors.dangerRed)
                }

                // Cooldown timer
                CooldownTimerView(remaining: vm.cooldownRemaining)
                    .padding(20)
                    .background(AppColors.darkCharcoal)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Tips while waiting
                VStack(alignment: .leading, spacing: 8) {
                    Text("While you wait:")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    ForEach(waitingTips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundStyle(AppColors.electricBlue)
                            Text(tip)
                                .font(.caption)
                                .foregroundStyle(AppColors.mutedText)
                        }
                    }
                }
                .padding(16)
                .background(AppColors.darkCharcoal)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)

                // Override button
                Button(action: { vm.requestOverride() }) {
                    Text("Override Lock")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.warmGold)
                }

                Spacer()
            }
        }
        .confirmationDialog(
            "Override the trading lock?",
            isPresented: $vm.lockManager.showOverrideConfirmation,
            titleVisibility: .visible
        ) {
            Button("Override Lock", role: .destructive) { vm.confirmOverride() }
            Button("Cancel", role: .cancel) { vm.cancelOverride() }
        } message: {
            Text("Are you sure? Overriding while stressed increases your risk of bad trades significantly.")
        }
    }

    private let waitingTips = [
        "Take 5 slow deep breaths",
        "Drink some water",
        "Step away from your screen",
        "Review your trading plan",
        "Remember: missed trades are better than bad trades"
    ]

    private func triggerShake() {
        withAnimation(.interpolatingSpring(stiffness: 500, damping: 10)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interpolatingSpring(stiffness: 500, damping: 10)) {
                shakeOffset = 0
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LockScreenView()
        .environmentObject(TradingGuardViewModel())
        .preferredColorScheme(.dark)
}
