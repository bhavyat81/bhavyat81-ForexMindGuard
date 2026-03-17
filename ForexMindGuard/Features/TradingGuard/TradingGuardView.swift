// TradingGuardView.swift
// ForexMindGuard – Features/TradingGuard

import SwiftUI

struct TradingGuardView: View {

    @EnvironmentObject var vm: TradingGuardViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.deepNavy.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        guardStatusCard
                        stressIndicator
                        lockHistorySection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Trading Guard")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: .constant(vm.isLocked)) {
                LockScreenView()
                    .environmentObject(vm)
            }
        }
    }

    // MARK: - Guard status card
    private var guardStatusCard: some View {
        VStack(spacing: 16) {
            Image(systemName: vm.isLocked ? "lock.shield.fill" : "checkmark.shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(vm.isLocked ? AppColors.dangerRed : AppColors.neonGreen)
                .symbolEffect(.bounce, value: vm.isLocked)

            Text(vm.isLocked ? "Trading Locked" : "Trading Active")
                .font(.title2.bold())
                .foregroundStyle(.white)

            if vm.isLocked {
                CooldownTimerView(remaining: vm.cooldownRemaining)
                overrideButton
            } else {
                Text("All systems normal. Stay disciplined.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(vm.isLocked ? AppColors.dangerRed.opacity(0.1) : AppColors.neonGreen.opacity(0.05))
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(vm.isLocked ? AppColors.dangerRed.opacity(0.5) : AppColors.neonGreen.opacity(0.3), lineWidth: 1.5)
        )
    }

    // MARK: - Stress indicator
    private var stressIndicator: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Current Stress")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(Int(vm.latestStressScore))%")
                    .font(.system(.headline, design: .monospaced).bold())
                    .foregroundStyle(AppColors.stressColor(for: vm.latestStressScore))
            }

            ProgressView(value: vm.latestStressScore, total: 100)
                .tint(AppColors.stressColor(for: vm.latestStressScore))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(16)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Override button
    private var overrideButton: some View {
        Button(action: { vm.requestOverride() }) {
            Label("Override Lock", systemImage: "lock.open")
                .font(.subheadline.bold())
                .foregroundStyle(AppColors.warmGold)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AppColors.warmGold.opacity(0.15))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppColors.warmGold.opacity(0.4), lineWidth: 1))
        }
        .confirmationDialog(
            "Are you sure you want to override the trading lock?",
            isPresented: $vm.lockManager.showOverrideConfirmation,
            titleVisibility: .visible
        ) {
            Button("Override Lock", role: .destructive) { vm.confirmOverride() }
            Button("Cancel", role: .cancel) { vm.cancelOverride() }
        } message: {
            Text("Overriding while stressed increases the risk of poor trades. Are you certain?")
        }
    }

    // MARK: - Lock history
    private var lockHistorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lock History")
                .font(.headline)
                .foregroundStyle(.white)

            if vm.lockManager.lockHistory.isEmpty {
                Text("No locks recorded this session.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedText)
            } else {
                ForEach(vm.lockManager.lockHistory) { event in
                    lockEventRow(event)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func lockEventRow(_ event: LockEvent) -> some View {
        HStack {
            Image(systemName: event.wasOverridden ? "lock.open.fill" : "lock.fill")
                .foregroundStyle(event.wasOverridden ? AppColors.warmGold : AppColors.dangerRed)
            VStack(alignment: .leading, spacing: 2) {
                Text("Score: \(Int(event.stressScoreAtTrigger)) · \(event.emotion.rawValue)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                Text(event.triggeredAt.relativeString)
                    .font(.caption2)
                    .foregroundStyle(AppColors.mutedText)
            }
            Spacer()
            if event.wasOverridden {
                Text("Overridden")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.warmGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.warmGold.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TradingGuardView()
        .environmentObject(TradingGuardViewModel())
        .preferredColorScheme(.dark)
}
