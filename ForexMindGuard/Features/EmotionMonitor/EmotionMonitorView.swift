// EmotionMonitorView.swift
// ForexMindGuard – Features/EmotionMonitor
//
// Full emotion monitoring screen with real-time gauges, stress score, and history chart.

import SwiftUI
import Charts

struct EmotionMonitorView: View {

    @EnvironmentObject var vm: EmotionMonitorViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.deepNavy.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // Top row: Heart rate + Emotion
                        HStack(spacing: 16) {
                            HeartRateGaugeView(bpm: vm.heartRate, isElevated: vm.isHeartRateElevated)
                                .frame(maxWidth: .infinity)
                            emotionCard
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: 160)

                        // Stress score
                        StressScoreView(score: vm.currentSnapshot.stressScore)
                            .frame(height: 120)
                            .padding(16)
                            .background(AppColors.darkCharcoal)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Face tracking status
                        faceTrackingCard

                        // Behavioral flags
                        if !vm.behavioralFlags.isEmpty {
                            behaviouralFlagsCard
                        }

                        // History chart
                        if vm.stressHistory.count > 1 {
                            StressHistoryView(snapshots: vm.stressHistory)
                                .frame(height: 200)
                                .padding(16)
                                .background(AppColors.darkCharcoal)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Emotion Monitor")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { vm.startMonitoring() }
            .onDisappear { vm.stopMonitoring() }
        }
    }

    // MARK: - Emotion card
    private var emotionCard: some View {
        VStack(spacing: 8) {
            Image(systemName: vm.detectedEmotion.symbol)
                .font(.system(size: 36))
                .foregroundStyle(vm.detectedEmotion.color)

            Text(vm.detectedEmotion.rawValue)
                .font(.headline)
                .foregroundStyle(.white)

            Text("Detected")
                .font(.caption)
                .foregroundStyle(AppColors.mutedText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Detected emotion: \(vm.detectedEmotion.rawValue)")
    }

    // MARK: - Face tracking card
    private var faceTrackingCard: some View {
        HStack {
            Image(systemName: vm.isFaceTrackingActive ? "camera.fill" : "camera.slash")
                .foregroundStyle(vm.isFaceTrackingActive ? AppColors.electricBlue : AppColors.mutedText)
            Text(vm.isFaceTrackingActive ? "Face tracking active" : "Face tracking inactive")
                .font(.subheadline)
                .foregroundStyle(vm.isFaceTrackingActive ? AppColors.electricBlue : AppColors.mutedText)
            Spacer()
            Circle()
                .fill(vm.isFaceTrackingActive ? AppColors.electricBlue : AppColors.mutedText)
                .frame(width: 8)
        }
        .padding(14)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Behavioral flags
    private var behaviouralFlagsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Behaviour Alerts")
                .font(.headline)
                .foregroundStyle(.white)
            ForEach(vm.behavioralFlags, id: \.self) { flag in
                Text(flag)
                    .font(.caption)
                    .foregroundStyle(AppColors.warmGold)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.warmGold.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.warmGold.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Preview
#Preview {
    EmotionMonitorView()
        .environmentObject(EmotionMonitorViewModel())
        .preferredColorScheme(.dark)
}
