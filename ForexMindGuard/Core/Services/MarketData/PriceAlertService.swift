// PriceAlertService.swift
// ForexMindGuard – Core/Services/MarketData
//
// Watches price ticks from ForexWebSocketService and fires a PriceMovement
// event whenever a pair moves more than the configured pip threshold within
// the configured time window.

import Foundation
import Combine

// MARK: - PriceAlertService
final class PriceAlertService: ObservableObject {

    // MARK: Published
    @Published private(set) var recentMovements: [PriceMovement] = []
    @Published private(set) var latestSignificantMovement: PriceMovement?

    // MARK: Combine
    private let movementSubject = PassthroughSubject<PriceMovement, Never>()
    var movementPublisher: AnyPublisher<PriceMovement, Never> { movementSubject.eraseToAnyPublisher() }

    // MARK: Settings
    var pipThreshold: Double = DefaultThresholds.significantMovePips
    var windowMinutes: Int   = DefaultThresholds.movementWindowMinutes

    // MARK: Private
    // Store price snapshots: [pairSymbol: [(price, timestamp)]]
    private var priceHistory: [String: [(price: Double, date: Date)]] = [:]
    private var tickSubscription: AnyCancellable?

    // MARK: - Observe WebSocket service
    func observe(webSocketService: ForexWebSocketService) {
        tickSubscription = webSocketService.tickPublisher
            .sink { [weak self] tick in
                self?.processTick(tick)
            }
    }

    // MARK: - Process incoming tick
    private func processTick(_ tick: PriceTick) {
        let mid = (tick.bid + tick.ask) / 2
        let now = Date()
        let symbol = tick.symbol

        // Append to history and prune old entries
        var history = priceHistory[symbol] ?? []
        history.append((price: mid, date: now))
        let cutoff = now.addingTimeInterval(-Double(windowMinutes) * 60)
        history = history.filter { $0.date >= cutoff }
        priceHistory[symbol] = history

        // Need at least 2 points to compute movement
        guard history.count >= 2, let oldest = history.first else { return }

        let isJPY = symbol.hasSuffix("JPY")
        let priceDiff = mid - oldest.price
        let pipsChange = priceDiff * (isJPY ? 100 : 10_000)
        let absPips = abs(pipsChange)

        guard absPips >= pipThreshold else { return }

        let direction: MovementDirection = pipsChange > 0 ? .up : .down
        let pctChange = (priceDiff / oldest.price) * 100

        let movement = PriceMovement(
            pair: symbol,
            pipsChange: pipsChange,
            percentChange: pctChange,
            timeframe: windowMinutes,
            direction: direction,
            startPrice: oldest.price,
            endPrice: mid
        )

        DispatchQueue.main.async { [weak self] in
            self?.latestSignificantMovement = movement
            self?.recentMovements.insert(movement, at: 0)
            // Keep last 50 movements
            if let self, self.recentMovements.count > 50 {
                self.recentMovements.removeLast()
            }
            self?.movementSubject.send(movement)
        }

        // Clear the window so we don't re-fire for the same move
        priceHistory[symbol] = [(price: mid, date: now)]
    }
}
