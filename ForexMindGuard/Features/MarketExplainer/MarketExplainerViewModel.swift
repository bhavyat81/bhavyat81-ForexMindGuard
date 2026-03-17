// MarketExplainerViewModel.swift
// ForexMindGuard – Features/MarketExplainer

import Foundation
import Combine

final class MarketExplainerViewModel: ObservableObject {

    @Published var explanations: [NewsExplanation] = []
    @Published var isLoading: Bool = false
    @Published var selectedExplanation: NewsExplanation?
    @Published var error: String?

    private let webSocketService  = ForexWebSocketService()
    private let priceAlertService = PriceAlertService()
    private let aiExplainerService = AIExplainerService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        bind()
        seedSampleData()
    }

    private func bind() {
        priceAlertService.movementPublisher
            .sink { [weak self] movement in
                self?.handleMovement(movement)
            }
            .store(in: &cancellables)

        aiExplainerService.$explanations
            .receive(on: DispatchQueue.main)
            .assign(to: &$explanations)

        aiExplainerService.$isGenerating
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
    }

    private func handleMovement(_ movement: PriceMovement) {
        Task {
            do {
                _ = try await aiExplainerService.explain(movement)
            } catch {
                await MainActor.run { self.error = error.localizedDescription }
            }
        }
    }

    func startStreaming(pairs: [String]) {
        webSocketService.connect(pairs: pairs, provider: .mock)
        priceAlertService.observe(webSocketService: webSocketService)
    }

    func refresh() {
        explanations = explanations  // Trigger UI refresh
    }

    private func seedSampleData() {
        explanations = [.sample]
    }
}
