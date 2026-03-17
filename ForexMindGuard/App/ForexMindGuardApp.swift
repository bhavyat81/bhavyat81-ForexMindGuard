// ForexMindGuardApp.swift
// ForexMindGuard – iOS 17+ SwiftUI entry point
//
// This is the @main application struct.  It wires together the root
// environment objects so every view in the hierarchy can access shared
// services without prop-drilling.

import SwiftUI
import HealthKit

@main
struct ForexMindGuardApp: App {

    // MARK: - App-level state
    @StateObject private var emotionViewModel = EmotionMonitorViewModel()
    @StateObject private var marketViewModel  = MarketExplainerViewModel()
    @StateObject private var guardViewModel   = TradingGuardViewModel()
    @StateObject private var dashboardViewModel = DashboardViewModel()

    // Delegate handles push notification registration, background tasks, etc.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            ContentRootView()
                .environmentObject(emotionViewModel)
                .environmentObject(marketViewModel)
                .environmentObject(guardViewModel)
                .environmentObject(dashboardViewModel)
                .preferredColorScheme(.dark)   // Trading apps live in the dark
        }
    }
}

// MARK: - Root navigation container
/// Decides whether to show Onboarding or the main tab bar on first launch.
struct ContentRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject var guardVM: TradingGuardViewModel

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
            }

            // SmartShield overlay sits above everything when active
            if guardVM.isSmartShieldActive {
                SmartShieldView()
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: guardVM.isSmartShieldActive)
    }
}

// MARK: - Main tab view
struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "gauge.with.dots.needle.bottom.50percent")
                }

            EmotionMonitorView()
                .tabItem {
                    Label("Emotions", systemImage: "brain.head.profile")
                }

            MarketExplainerView()
                .tabItem {
                    Label("Explainer", systemImage: "waveform.badge.magnifyingglass")
                }

            WatchlistView()
                .tabItem {
                    Label("Watchlist", systemImage: "list.bullet.rectangle")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.2")
                }
        }
        .tint(AppColors.electricBlue)
    }
}
