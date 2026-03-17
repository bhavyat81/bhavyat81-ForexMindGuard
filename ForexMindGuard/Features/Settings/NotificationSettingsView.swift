// NotificationSettingsView.swift
// ForexMindGuard – Features/Settings

import SwiftUI

struct NotificationSettingsView: View {

    @EnvironmentObject var settings: UserSettings

    var body: some View {
        ZStack {
            AppColors.deepNavy.ignoresSafeArea()

            List {
                Section {
                    Toggle("Stress Warnings", isOn: $settings.notifications.stressWarnings)
                    Toggle("Trading Lock Alerts", isOn: $settings.notifications.tradingLocks)
                    Toggle("Market Movement Alerts", isOn: $settings.notifications.marketMovements)
                    Toggle("AI Explanations Ready", isOn: $settings.notifications.aiExplanations)
                } header: {
                    Text("Alerts")
                        .foregroundStyle(AppColors.electricBlue)
                }

                Section {
                    Toggle("Sound", isOn: $settings.notifications.soundEnabled)
                    Toggle("Haptics", isOn: $settings.notifications.hapticEnabled)
                    Toggle("Apple Watch Sync", isOn: $settings.notifications.watchSyncing)
                } header: {
                    Text("Delivery")
                        .foregroundStyle(AppColors.electricBlue)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: settings.notifications.stressWarnings) { _, _ in settings.save() }
        .onChange(of: settings.notifications.soundEnabled) { _, _ in settings.save() }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environmentObject(UserSettings())
    }
    .preferredColorScheme(.dark)
}
