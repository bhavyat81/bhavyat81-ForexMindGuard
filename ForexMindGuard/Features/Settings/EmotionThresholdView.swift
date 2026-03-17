// EmotionThresholdView.swift
// ForexMindGuard – Features/Settings
//
// Customise warning and lock stress thresholds + cooldown duration.

import SwiftUI

struct EmotionThresholdView: View {

    @EnvironmentObject var settings: UserSettings

    var body: some View {
        ZStack {
            AppColors.deepNavy.ignoresSafeArea()

            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Warning Threshold")
                            Spacer()
                            Text("\(Int(settings.warningStressThreshold))%")
                                .font(.system(.body, design: .monospaced).bold())
                                .foregroundStyle(AppColors.warmGold)
                        }
                        Slider(
                            value: $settings.warningStressThreshold,
                            in: 50...80,
                            step: 5
                        )
                        .tint(AppColors.warmGold)
                        Text("Shows a warning notification above this score.")
                            .font(.caption)
                            .foregroundStyle(AppColors.mutedText)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("⚠️ Warning Level")
                        .foregroundStyle(AppColors.warmGold)
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Lock Threshold")
                            Spacer()
                            Text("\(Int(settings.lockStressThreshold))%")
                                .font(.system(.body, design: .monospaced).bold())
                                .foregroundStyle(AppColors.dangerRed)
                        }
                        Slider(
                            value: $settings.lockStressThreshold,
                            in: 75...95,
                            step: 5
                        )
                        .tint(AppColors.dangerRed)
                        Text("Locks trading UI above this score.")
                            .font(.caption)
                            .foregroundStyle(AppColors.mutedText)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("🔒 Lock Level")
                        .foregroundStyle(AppColors.dangerRed)
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Cooldown Duration")
                            Spacer()
                            Text("\(Int(settings.cooldownDuration / 60)) min")
                                .font(.system(.body, design: .monospaced).bold())
                                .foregroundStyle(AppColors.electricBlue)
                        }
                        Slider(
                            value: $settings.cooldownDuration,
                            in: 5 * 60...30 * 60,
                            step: 5 * 60
                        )
                        .tint(AppColors.electricBlue)
                        Text("How long to lock trading after threshold is crossed.")
                            .font(.caption)
                            .foregroundStyle(AppColors.mutedText)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("⏱ Cooldown")
                        .foregroundStyle(AppColors.electricBlue)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Stress Thresholds")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: settings.warningStressThreshold) { _, _ in settings.save() }
        .onChange(of: settings.lockStressThreshold) { _, _ in settings.save() }
        .onChange(of: settings.cooldownDuration) { _, _ in settings.save() }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        EmotionThresholdView()
            .environmentObject(UserSettings())
    }
    .preferredColorScheme(.dark)
}
