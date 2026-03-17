// DashboardView.swift
// ForexMindGuard – Features/Dashboard
//
// Main dashboard showing stress gauge, top market pairs, and latest AI explanation.

import SwiftUI

struct DashboardView: View {

    @EnvironmentObject var vm: DashboardViewModel
    @EnvironmentObject var guardVM: TradingGuardViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.deepNavy.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        stressSection
                        marketSection
                        behaviourSection
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("ForexMindGuard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    connectionBadge
                }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good \(timeOfDayGreeting)")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedText)
                Text("Trader")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            Spacer()
            emotionBadge
        }
    }

    private var emotionBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: vm.currentEmotion.symbol)
                .foregroundStyle(vm.currentEmotion.color)
            Text(vm.currentEmotion.rawValue)
                .font(.caption.bold())
                .foregroundStyle(vm.currentEmotion.color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(vm.currentEmotion.color.opacity(0.15))
        .clipShape(Capsule())
    }

    // MARK: - Stress section
    private var stressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Stress Score")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(guardVM.lockState == .unlocked ? "✅ Trading Allowed" : "🔒 Locked")
                    .font(.caption.bold())
                    .foregroundStyle(guardVM.isLocked ? AppColors.dangerRed : AppColors.neonGreen)
            }

            StressScoreView(score: vm.currentStressScore)
                .frame(height: 120)
        }
        .padding(16)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Market section
    private var marketSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Watchlist")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                NavigationLink("See All") {
                    WatchlistView()
                }
                .font(.caption)
                .foregroundStyle(AppColors.electricBlue)
            }

            ForEach(vm.topPairs.prefix(3)) { pair in
                miniPairRow(pair: pair)
            }
        }
        .padding(16)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.cardBorder, lineWidth: 1))
    }

    private func miniPairRow(_ pair: ForexPair) -> some View {
        HStack {
            Text(pair.symbol)
                .font(.system(.body, design: .monospaced).bold())
                .foregroundStyle(.white)
            Spacer()
            Text(pair.formattedPrice)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.white)
            Text(pair.dailyChangePips.asPipsWithSign())
                .font(.caption.bold())
                .foregroundStyle(pair.isPositiveDay ? AppColors.neonGreen : AppColors.dangerRed)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Behaviour section
    private var behaviourSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Behaviour Monitor")
                .font(.headline)
                .foregroundStyle(.white)

            if vm.activeFlagCount == 0 {
                Label("No risk patterns detected", systemImage: "checkmark.shield")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.neonGreen)
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(AppColors.warmGold)
                    Text("\(vm.activeFlagCount) risk pattern\(vm.activeFlagCount > 1 ? "s" : "") detected")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.warmGold)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.cardBorder, lineWidth: 1))
    }

    // MARK: - Helpers
    private var connectionBadge: some View {
        Circle()
            .fill(vm.isMarketConnected ? AppColors.neonGreen : AppColors.dangerRed)
            .frame(width: 10, height: 10)
            .accessibilityLabel(vm.isMarketConnected ? "Connected" : "Disconnected")
    }

    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
        .environmentObject(DashboardViewModel())
        .environmentObject(TradingGuardViewModel())
        .preferredColorScheme(.dark)
}
