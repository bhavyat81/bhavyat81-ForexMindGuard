// WatchConnectivityService.swift
// ForexMindGuardWatch
//
// Manages WCSession communication between iPhone and Apple Watch.
// Receives stress score, emotion, and lock state from the iPhone app,
// and sends heart rate data from the Watch to the iPhone.

import Foundation
import WatchConnectivity
import Combine

final class WatchConnectivityService: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = WatchConnectivityService()

    // MARK: Published (Watch-side state mirrored from iPhone)
    @Published var stressScore: Double = 0
    @Published var currentEmotion: String = "Neutral"
    @Published var isTradingLocked: Bool = false
    @Published var cooldownRemaining: TimeInterval = 0
    @Published var isReachable: Bool = false

    private var session: WCSession?

    private override init() {
        super.init()
    }

    // MARK: - Activate
    func activate() {
        guard WCSession.isSupported() else { return }
        let s = WCSession.default
        s.delegate = self
        s.activate()
        session = s
    }

    // MARK: - Send heart rate to iPhone
    func sendHeartRate(bpm: Double) {
        guard let session, session.isReachable else { return }
        session.sendMessage(
            ["type": "heartRate", "bpm": bpm, "timestamp": Date().timeIntervalSince1970],
            replyHandler: nil,
            errorHandler: { print("[WatchConnectivity] Send HR error: \($0)") }
        )
    }

    // MARK: - WCSessionDelegate (Watch)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
    }

    // Receive messages from iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let score = message["stressScore"] as? Double {
                self.stressScore = score
            }
            if let emotion = message["emotion"] as? String {
                self.currentEmotion = emotion
            }
            if let locked = message["isLocked"] as? Bool {
                self.isTradingLocked = locked
            }
            if let cooldown = message["cooldownRemaining"] as? Double {
                self.cooldownRemaining = cooldown
            }
        }
    }

    // Receive context updates (background sync)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        self.session(session, didReceiveMessage: applicationContext)
    }

    // Required for iOS-side delegate conformance (not called on watchOS)
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif
}
