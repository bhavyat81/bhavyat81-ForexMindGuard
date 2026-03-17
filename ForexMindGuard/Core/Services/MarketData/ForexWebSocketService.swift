// ForexWebSocketService.swift
// ForexMindGuard – Core/Services/MarketData
//
// Streams live forex price ticks via WebSocket.
// Supports multiple providers: TraderMade, Finage.
// On disconnect, automatically attempts reconnection with exponential back-off.
//
// NOTE: Add the Starscream package via SPM (already in Package.swift).

import Foundation
import Combine

// MARK: - WebSocket provider
enum WebSocketProvider {
    case traderMade
    case finage
    case mock  // For SwiftUI previews and testing
}

// MARK: - Price tick
struct PriceTick: Decodable {
    let symbol: String    // e.g. "EURUSD"
    let bid: Double
    let ask: Double
    let timestamp: Date

    // TraderMade WebSocket format
    enum CodingKeys: String, CodingKey {
        case symbol = "instrument"
        case bid, ask
        case timestamp = "ts"
    }
}

// MARK: - ForexWebSocketService
final class ForexWebSocketService: NSObject, ObservableObject, URLSessionWebSocketDelegate {

    // MARK: Published
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var latestTick: PriceTick?
    @Published private(set) var connectionError: String?

    // MARK: Combine
    private let tickSubject = PassthroughSubject<PriceTick, Never>()
    var tickPublisher: AnyPublisher<PriceTick, Never> { tickSubject.eraseToAnyPublisher() }

    // MARK: Private
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var watchedPairs: [String] = []
    private var reconnectAttempts: Int = 0
    private let maxReconnectAttempts: Int = 5
    private var provider: WebSocketProvider = .traderMade
    private var pingTimer: Timer?

    // MARK: - Connect
    func connect(pairs: [String], provider: WebSocketProvider = .traderMade) {
        self.watchedPairs = pairs
        self.provider = provider
        guard provider != .mock else {
            startMockStream()
            return
        }
        openSocket()
    }

    // MARK: - Disconnect
    func disconnect() {
        pingTimer?.invalidate()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        DispatchQueue.main.async { self.isConnected = false }
    }

    // MARK: - Open WebSocket
    private func openSocket() {
        let urlString: String
        switch provider {
        case .traderMade:
            urlString = "\(APIEndpoints.traderMadeWS)?token=\(APIKeys.traderMade)"
        case .finage:
            urlString = "\(APIEndpoints.finageWS)?token=\(APIKeys.finage)"
        case .mock:
            return
        }

        guard let url = URL(string: urlString) else { return }
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        startReceiving()
        startPingTimer()
    }

    // MARK: - Subscribe to pairs
    private func subscribeToPairs() {
        let symbols = watchedPairs.joined(separator: ",")
        let message: String
        switch provider {
        case .traderMade:
            message = #"{"userKey":"\#(APIKeys.traderMade)","symbol":"\#(symbols)"}"#
        case .finage:
            message = #"{"action":"subscribe","symbols":"\#(symbols)"}"#
        case .mock:
            return
        }
        send(message: message)
    }

    // MARK: - Send message
    private func send(message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error { print("[WebSocket] Send error: \(error)") }
        }
    }

    // MARK: - Receive loop
    private func startReceiving() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.startReceiving()  // Continue receiving
            case .failure(let error):
                self?.handleDisconnect(error: error)
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8) else { return }
            parseTick(data: data)
        case .data(let data):
            parseTick(data: data)
        @unknown default:
            break
        }
    }

    private func parseTick(data: Data) {
        // Try TraderMade format first
        if let tick = try? JSONDecoder().decode(PriceTick.self, from: data) {
            DispatchQueue.main.async { [weak self] in
                self?.latestTick = tick
                self?.tickSubject.send(tick)
            }
        }
    }

    // MARK: - URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async { self.isConnected = true; self.reconnectAttempts = 0 }
        subscribeToPairs()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async { self.isConnected = false }
        scheduleReconnect()
    }

    // MARK: - Ping to keep connection alive
    private func startPingTimer() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.webSocketTask?.sendPing { _ in }
        }
    }

    // MARK: - Reconnect with exponential back-off
    private func handleDisconnect(error: Error) {
        DispatchQueue.main.async { self.isConnected = false; self.connectionError = error.localizedDescription }
        scheduleReconnect()
    }

    private func scheduleReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else { return }
        let delay = pow(2.0, Double(reconnectAttempts))
        reconnectAttempts += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.openSocket()
        }
    }

    // MARK: - Mock stream for previews / testing
    private var mockTimer: Timer?

    private func startMockStream() {
        DispatchQueue.main.async { self.isConnected = true }
        mockTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            let pair = self.watchedPairs.randomElement() ?? "EURUSD"
            let baseBid = 1.085 + Double.random(in: -0.005...0.005)
            let tick = PriceTick(
                symbol: pair,
                bid: baseBid,
                ask: baseBid + 0.00002,
                timestamp: Date()
            )
            self.latestTick = tick
            self.tickSubject.send(tick)
        }
    }

    deinit {
        disconnect()
        mockTimer?.invalidate()
    }
}

// PriceTick manual init for mock
extension PriceTick {
    init(symbol: String, bid: Double, ask: Double, timestamp: Date) {
        self.symbol = symbol
        self.bid = bid
        self.ask = ask
        self.timestamp = timestamp
    }
}
