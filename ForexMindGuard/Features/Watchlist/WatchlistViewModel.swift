// WatchlistViewModel.swift
// ForexMindGuard – Features/Watchlist

import Foundation
import Combine

final class WatchlistViewModel: ObservableObject {

    @Published var pairs: [ForexPair] = ForexPair.samples
    @Published var isConnected: Bool = false
    @Published var showAddPairSheet: Bool = false

    private let pairManager     = CurrencyPairManager()
    private let webSocketService = ForexWebSocketService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        pairManager.$watchedPairs
            .receive(on: DispatchQueue.main)
            .assign(to: &$pairs)

        webSocketService.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConnected)

        pairManager.observe(webSocketService: webSocketService)
        webSocketService.connect(pairs: pairs.map(\.id), provider: .mock)
    }

    func removePair(at offsets: IndexSet) {
        offsets.forEach { idx in pairManager.removePair(id: pairs[idx].id) }
    }

    func addPair(base: String, quote: String) {
        pairManager.addPair(base: base.uppercased(), quote: quote.uppercased())
        webSocketService.connect(pairs: pairManager.watchedPairs.map(\.id), provider: .mock)
    }
}
