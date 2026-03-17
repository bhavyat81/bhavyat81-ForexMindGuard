// AppDelegate.swift
// ForexMindGuard
//
// UIApplicationDelegate bridged into SwiftUI via @UIApplicationDelegateAdaptor.
// Handles:
//  • Push notification registration & routing
//  • Background fetch / silent push for market alerts
//  • HealthKit background delivery authorisation

import UIKit
import UserNotifications
import HealthKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureNotifications(application)
        configureHealthKitBackgroundDelivery()
        return true
    }

    // MARK: - Push notifications
    private func configureNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        let options: UNAuthorizationOptions = [.alert, .badge, .sound, .criticalAlert]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if granted {
                DispatchQueue.main.async { application.registerForRemoteNotifications() }
            }
            if let error { print("[AppDelegate] Notification auth error: \(error)") }
        }

        // Define notification categories for quick-action buttons
        let overrideAction = UNNotificationAction(
            identifier: NotificationConstants.overrideActionID,
            title: "Override Lock",
            options: [.destructive, .authenticationRequired]
        )
        let viewAction = UNNotificationAction(
            identifier: NotificationConstants.viewExplanationActionID,
            title: "View Explanation",
            options: .foreground
        )
        let stressCategory = UNNotificationCategory(
            identifier: NotificationConstants.stressCategoryID,
            actions: [overrideAction],
            intentIdentifiers: []
        )
        let marketCategory = UNNotificationCategory(
            identifier: NotificationConstants.marketCategoryID,
            actions: [viewAction],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current()
            .setNotificationCategories([stressCategory, marketCategory])
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[AppDelegate] Device token: \(token)")
        // TODO: Send token to your backend / Firebase / Supabase
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[AppDelegate] Failed to register for remote notifications: \(error)")
    }

    // MARK: - HealthKit background delivery
    private func configureHealthKitBackgroundDelivery() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let store = HKHealthStore()
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        // Request background delivery for heart rate updates even when app is suspended
        store.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
            if let error { print("[AppDelegate] HK background delivery error: \(error)") }
        }
    }

    // MARK: - Background fetch (for market data)
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // TODO: trigger a lightweight market data refresh and complete
        completionHandler(.newData)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Show notifications even when app is in the foreground (e.g. trading lock alerts)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap / action button
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case NotificationConstants.overrideActionID:
            NotificationCenter.default.post(name: .userRequestedLockOverride, object: nil)
        case NotificationConstants.viewExplanationActionID:
            NotificationCenter.default.post(name: .userRequestedExplanationView, object: nil)
        default:
            break
        }
        completionHandler()
    }
}

// MARK: - NSNotification.Name extensions
extension Notification.Name {
    static let userRequestedLockOverride    = Notification.Name("userRequestedLockOverride")
    static let userRequestedExplanationView = Notification.Name("userRequestedExplanationView")
}
