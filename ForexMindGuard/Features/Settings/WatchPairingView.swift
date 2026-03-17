// WatchPairingView.swift
// ForexMindGuard – Features/Settings
//
// Guides the user through pairing their Apple Watch.

import SwiftUI
import WatchConnectivity

struct WatchPairingView: View {

    @State private var isWatchReachable: Bool = WCSession.default.isReachable
    @State private var isSessionActivated: Bool = WCSession.default.activationState == .activated

    var body: some View {
        ZStack {
            AppColors.deepNavy.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Watch status
                    watchStatusCard

                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Setup Instructions")
                            .font(.headline)
                            .foregroundStyle(.white)

                        ForEach(instructions.indices, id: \.self) { idx in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(idx + 1)")
                                    .font(.system(.caption, design: .monospaced).bold())
                                    .foregroundStyle(.black)
                                    .frame(width: 24, height: 24)
                                    .background(AppColors.electricBlue)
                                    .clipShape(Circle())

                                Text(instructions[idx])
                                    .font(.subheadline)
                                    .foregroundStyle(AppColors.mutedText)
                            }
                        }
                    }
                    .padding(16)
                    .background(AppColors.darkCharcoal)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
            }
        }
        .navigationTitle("Apple Watch Setup")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var watchStatusCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "applewatch")
                .font(.system(size: 40))
                .foregroundStyle(isWatchReachable ? AppColors.neonGreen : AppColors.mutedText)

            VStack(alignment: .leading, spacing: 4) {
                Text("Apple Watch")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(isWatchReachable ? "Connected and reachable" : isSessionActivated ? "Paired but not reachable" : "Not paired")
                    .font(.subheadline)
                    .foregroundStyle(isWatchReachable ? AppColors.neonGreen : AppColors.mutedText)
            }
            Spacer()
        }
        .padding(16)
        .background(AppColors.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private let instructions = [
        "Ensure your Apple Watch is paired and on your wrist.",
        "Install the ForexMindGuardWatch app from the Watch App on your iPhone.",
        "Open the ForexMindGuard Watch app on your watch.",
        "Tap 'Start Heart Rate Monitoring' on the watch.",
        "Heart rate data will now sync automatically."
    ]
}

// MARK: - Preview
#Preview {
    NavigationStack {
        WatchPairingView()
    }
    .preferredColorScheme(.dark)
}
