// WatchContentView.swift
// ForexMindGuardWatch – Main watch navigation
//
// Root view for the Apple Watch app.

import SwiftUI

struct WatchContentView: View {

    @EnvironmentObject var connectivity: WatchConnectivityService

    var body: some View {
        TabView {
            HeartRateMonitorView()
                .tag(0)
            QuickEmotionView()
                .tag(1)
            StressAlertView()
                .tag(2)
        }
        .tabViewStyle(.page)
    }
}

// MARK: - Preview
#Preview {
    WatchContentView()
        .environmentObject(WatchConnectivityService.shared)
}
