// TradingGuardViewModel.swift
// ForexMindGuard – Features/TradingGuard

import Foundation
import Combine

final class TradingGuardViewModel: ObservableObject {

    // MARK: Published
    @Published var lockState: TradingLockState = .unlocked
    @Published var isLocked: Bool = false
    @Published var cooldownRemaining: TimeInterval = 0
    @Published var isSmartShieldActive: Bool = false
    @Published var latestStressScore: Double = 0
    @Published var currentEmotion: EmotionState = .neutral
    @Published var latestMovement: PriceMovement?
    @Published var latestExplanation: NewsExplanation?

    // MARK: Services
    let stressCalculator   = StressCalculator()
    let lockManager        = TradingLockManager()
    let webSocketService   = ForexWebSocketService()
    let priceAlertService  = PriceAlertService()
    let aiExplainer        = AIExplainerService()

    private var cancellables = Set<AnyCancellable>()

    init() {
        bind()
    }

    private func bind() {
        // Lock manager → published state
        lockManager.$lockState
            .receive(on: DispatchQueue.main)
            .assign(to: &$lockState)

        lockManager.$isLocked
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLocked)

        lockManager.$cooldownRemaining
            .receive(on: DispatchQueue.main)
            .assign(to: &$cooldownRemaining)

        // Stress score
        stressCalculator.$currentScore
            .receive(on: DispatchQueue.main)
            .assign(to: &$latestStressScore)

        stressCalculator.$currentEmotion
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentEmotion)

        // Smart Shield: activate when BOTH locked AND there's a significant market move
        Publishers.CombineLatest($isLocked, priceAlertService.$latestSignificantMovement)
            .map { locked, movement in locked && movement != nil }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isSmartShieldActive)

        priceAlertService.$latestSignificantMovement
            .receive(on: DispatchQueue.main)
            .assign(to: &$latestMovement)

        // Wire stress calculator to lock manager
        lockManager.observe(stressCalculator: stressCalculator)
    }

    func startStreaming(pairs: [String]) {
        webSocketService.connect(pairs: pairs, provider: .mock)
        priceAlertService.observe(webSocketService: webSocketService)
    }

    func requestOverride() { lockManager.requestOverride() }
    func confirmOverride() { lockManager.confirmOverride() }
    func cancelOverride()  { lockManager.cancelOverride() }
}
