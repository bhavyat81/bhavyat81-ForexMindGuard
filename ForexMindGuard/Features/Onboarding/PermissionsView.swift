// PermissionsView.swift
// ForexMindGuard – Features/Onboarding
//
// Request HealthKit, Camera (Face ID / ARKit), and Notification permissions.

import SwiftUI
import HealthKit
import ARKit
import UserNotifications

struct PermissionsView: View {

    @State private var healthKitGranted: Bool   = false
    @State private var cameraGranted: Bool       = false
    @State private var notificationsGranted: Bool = false
    @State private var isRequesting: Bool        = false

    var allGranted: Bool { healthKitGranted && cameraGranted && notificationsGranted }

    var body: some View {
        ZStack {
            AppColors.deepNavy.ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Permissions Required")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("ForexMindGuard needs the following permissions to monitor your trading health.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                VStack(spacing: 14) {
                    permissionRow(
                        icon: "heart.fill",
                        color: .red,
                        title: "Health",
                        description: "Heart rate and HRV monitoring via Apple Watch / HealthKit",
                        isGranted: healthKitGranted,
                        action: requestHealthKit
                    )
                    permissionRow(
                        icon: "camera.fill",
                        color: AppColors.electricBlue,
                        title: "Camera & Face Tracking",
                        description: "ARKit facial expression analysis for emotion detection",
                        isGranted: cameraGranted,
                        action: requestCamera
                    )
                    permissionRow(
                        icon: "bell.fill",
                        color: AppColors.warmGold,
                        title: "Notifications",
                        description: "Real-time stress warnings and trading lock alerts",
                        isGranted: notificationsGranted,
                        action: requestNotifications
                    )
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.top, 60)
        }
    }

    // MARK: - Permission row
    private func permissionRow(
        icon: String,
        color: Color,
        title: String,
        description: String,
        isGranted: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(AppColors.mutedText)
                    .lineLimit(2)
            }

            Spacer()

            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppColors.neonGreen)
            } else {
                Button("Allow") { action() }
                    .font(.caption.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(AppColors.electricBlue)
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Permission requests
    private func requestHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let store = HKHealthStore()
        let types: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]
        store.requestAuthorization(toShare: [], read: types) { granted, _ in
            DispatchQueue.main.async { healthKitGranted = granted }
        }
    }

    private func requestCamera() {
        // ARKit face tracking requires camera access
        // Permission is implicitly requested when ARSession is run
        // We can also use AVCaptureDevice for an explicit prompt
        healthKitGranted = true  // Placeholder – ARKit handles this on first run
        cameraGranted = true
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { notificationsGranted = granted }
        }
    }
}

// MARK: - Preview
#Preview {
    PermissionsView()
        .preferredColorScheme(.dark)
}
