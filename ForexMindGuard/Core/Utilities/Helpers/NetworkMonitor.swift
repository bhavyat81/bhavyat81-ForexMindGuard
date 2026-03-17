// NetworkMonitor.swift
// ForexMindGuard – Utilities/Helpers
//
// Monitors network connectivity status using Network framework.
// Published property drives UI state (e.g. offline banner, WebSocket reconnect).

import Foundation
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected: Bool = true
    @Published private(set) var connectionType: ConnectionType = .unknown

    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue(label: "com.forexmindguard.networkmonitor")

    private init() {
        start()
    }

    // MARK: - Start monitoring
    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.usesInterfaceType(.wifi) ? .wifi :
                                       path.usesInterfaceType(.cellular) ? .cellular : .other
            }
        }
        monitor.start(queue: queue)
    }

    // MARK: - Stop monitoring
    func stop() {
        monitor.cancel()
    }

    deinit { stop() }
}

// MARK: - Connection type
enum ConnectionType {
    case wifi, cellular, other, unknown
}
