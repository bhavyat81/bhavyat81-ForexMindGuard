// SettingsView.swift
// ForexMindGuard – Features/Settings

import SwiftUI

struct SettingsView: View {

    @StateObject private var settings = UserSettings.load()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.deepNavy.ignoresSafeArea()

                List {
                    // Emotion thresholds
                    Section {
                        NavigationLink("Stress Thresholds") {
                            EmotionThresholdView()
                                .environmentObject(settings)
                        }
                        NavigationLink("Notification Settings") {
                            NotificationSettingsView()
                                .environmentObject(settings)
                        }
                        NavigationLink("Apple Watch Setup") {
                            WatchPairingView()
                        }
                    } header: {
                        Text("Emotion Guard")
                            .foregroundStyle(AppColors.electricBlue)
                    }

                    Section {
                        HStack {
                            Text("API Keys")
                            Spacer()
                            Text("Tap to configure")
                                .font(.caption)
                                .foregroundStyle(AppColors.mutedText)
                        }
                        HStack {
                            Text("Market Provider")
                            Spacer()
                            Text("Mock (Demo)")
                                .font(.caption)
                                .foregroundStyle(AppColors.mutedText)
                        }
                    } header: {
                        Text("Market Data")
                            .foregroundStyle(AppColors.electricBlue)
                    }

                    Section {
                        Toggle("Face Tracking", isOn: $settings.faceTrackingEnabled)
                        HStack {
                            Text("Resting Heart Rate")
                            Spacer()
                            Text("\(Int(settings.restingHeartRate)) BPM")
                                .foregroundStyle(AppColors.mutedText)
                        }
                    } header: {
                        Text("Health")
                            .foregroundStyle(AppColors.electricBlue)
                    }

                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0 (Beta)")
                                .foregroundStyle(AppColors.mutedText)
                        }
                        Link("Privacy Policy", destination: URL(string: "https://forexmindguard.app/privacy")!)
                        Link("Support", destination: URL(string: "https://forexmindguard.app/support")!)
                    } header: {
                        Text("About")
                            .foregroundStyle(AppColors.electricBlue)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: settings.faceTrackingEnabled) { _, _ in settings.save() }
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
