// ForexMindGuardWatchApp.swift
// ForexMindGuardWatch – Watch app entry point
//
// WatchOS companion app for ForexMindGuard.
// Handles:
//  • Live heart rate display
//  • Stress level glance
//  • Trading lock alerts on wrist

import SwiftUI
import WatchKit

@main
struct ForexMindGuardWatchApp: App {

    @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var delegate
    @StateObject private var connectivity = WatchConnectivityService.shared

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(connectivity)
        }
    }
}

// MARK: - WKApplicationDelegate
class ExtensionDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        WatchConnectivityService.shared.activate()
        WorkoutManager.shared.requestAuthorization()
    }

    func applicationWillEnterForeground() {
        WorkoutManager.shared.startHeartRateMonitoring()
    }

    func applicationDidEnterBackground() {
        // Keep heart rate monitoring active even in background
    }
}

// MARK: - WorkoutManager (triggers HealthKit heart rate)
/// Using HKWorkoutSession keeps the heart rate sensor active on Apple Watch
final class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()
    private let healthStore = HKHealthStore()

    func requestAuthorization() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        healthStore.requestAuthorization(toShare: [heartRateType], read: [heartRateType]) { _, _ in }
    }

    func startHeartRateMonitoring() {
        // On watchOS, heart rate is typically accessed via a workout session
        // TODO: Start an HKWorkoutSession to enable continuous heart rate monitoring
    }
}
