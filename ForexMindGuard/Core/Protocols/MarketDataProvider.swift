// MarketDataProvider.swift
// ForexMindGuard – Protocols
//
// Protocol for any market data source (WebSocket, REST, mock).

import Foundation
import Combine

/// Provides live forex price data and significant movement events.
protocol MarketDataProvider: AnyObject {
    /// Publisher emitting updated ForexPair whenever a price tick arrives.
    var pricePublisher: AnyPublisher<ForexPair, Never> { get }

    /// Publisher emitting PriceMovement when a significant move is detected.
    var movementPublisher: AnyPublisher<PriceMovement, Never> { get }

    /// Current snapshot of all tracked pairs.
    var pairs: [ForexPair] { get }

    /// Start streaming prices for the given pair identifiers.
    func connect(pairs: [String])

    /// Stop streaming.
    func disconnect()

    var isConnected: Bool { get }
}
