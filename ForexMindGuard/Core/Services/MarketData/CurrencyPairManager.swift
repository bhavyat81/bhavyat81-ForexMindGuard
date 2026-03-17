// CurrencyPairManager.swift
// ForexMindGuard – Core/Services/MarketData
//
// Manages the user's watchlist of currency pairs with live price updates.
// Persists the watchlist to UserDefaults.

import Foundation
import Combine

final class CurrencyPairManager: ObservableObject {

    // MARK: Published
    @Published private(set) var watchedPairs: [ForexPair] = []
    @Published private(set) var pairDictionary: [String: ForexPair] = [:]

    // MARK: Combine
    private var tickSubscription: AnyCancellable?

    // MARK: Init
    init() {
        loadSavedPairs()
    }

    // MARK: - Observe WebSocket
    func observe(webSocketService: ForexWebSocketService) {
        tickSubscription = webSocketService.tickPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tick in
                self?.updatePrice(tick)
            }
    }

    // MARK: - CRUD
    func addPair(base: String, quote: String) {
        let id = "\(base)\(quote)"
        guard !watchedPairs.contains(where: { $0.id == id }) else { return }
        let pair = ForexPair(base: base, quote: quote, bid: 0, ask: 0)
        watchedPairs.append(pair)
        pairDictionary[id] = pair
        savePairs()
    }

    func removePair(id: String) {
        watchedPairs.removeAll { $0.id == id }
        pairDictionary.removeValue(forKey: id)
        savePairs()
    }

    func movePair(from source: IndexSet, to destination: Int) {
        watchedPairs.move(fromOffsets: source, toOffset: destination)
        savePairs()
    }

    // MARK: - Update price from WebSocket tick
    private func updatePrice(_ tick: PriceTick) {
        guard let idx = watchedPairs.firstIndex(where: { $0.id == tick.symbol }) else { return }
        watchedPairs[idx].bid = tick.bid
        watchedPairs[idx].ask = tick.ask
        watchedPairs[idx].timestamp = tick.timestamp
        pairDictionary[tick.symbol] = watchedPairs[idx]
    }

    // MARK: - Persistence
    private let pairsKey = "watchedPairSymbols"

    private func loadSavedPairs() {
        let saved = UserDefaults.standard.stringArray(forKey: pairsKey) ?? ["EURUSD", "GBPUSD", "USDJPY"]
        watchedPairs = saved.compactMap { symbol -> ForexPair? in
            guard symbol.count >= 6 else { return nil }
            let base  = String(symbol.prefix(3))
            let quote = String(symbol.suffix(3))
            return ForexPair(base: base, quote: quote, bid: 0, ask: 0)
        }
        // Seed sample prices for preview
        if watchedPairs.isEmpty {
            watchedPairs = ForexPair.samples
        }
    }

    private func savePairs() {
        UserDefaults.standard.set(watchedPairs.map(\.id), forKey: pairsKey)
    }
}
