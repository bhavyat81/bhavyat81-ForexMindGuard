// DashboardViewModel.swift
// ForexMindGuard – Features/Dashboard

import Foundation
import Combine

final class DashboardViewModel: ObservableObject {

    // MARK: Published
    @Published var currentStressScore: Double = 0
    @Published var currentEmotion: EmotionState = .neutral
    @Published var latestHeartRate: Double = 65
    @Published var topPairs: [ForexPair] = ForexPair.samples
    @Published var latestExplanation: NewsExplanation?
    @Published var isMarketConnected: Bool = false
    @Published var activeFlagCount: Int = 0

    // MARK: Services (injected or lazily created)
    let stressCalculator   = StressCalculator()
    let heartRateService   = HeartRateService()
    let webSocketService   = ForexWebSocketService()
    let pairManager        = CurrencyPairManager()
    let behaviorAnalyzer   = BehaviorAnalyzer()
    let faceTrackingService = FaceTrackingService()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init() {
        bind()
    }

    // MARK: - Bindings
    private func bind() {
        // Heart rate → stress calculator
        heartRateService.$latestReading
            .compactMap { $0 }
            .sink { [weak self] reading in
                self?.stressCalculator.update(heartRate: reading)
                self?.latestHeartRate = reading.bpm
            }
            .store(in: &cancellables)

        // Face tracking → stress calculator
        faceTrackingService.$facialFactor
            .sink { [weak self] factor in
                self?.stressCalculator.update(facialFactor: factor)
            }
            .store(in: &cancellables)

        // Behavior → stress calculator
        behaviorAnalyzer.$behavioralFactor
            .sink { [weak self] factor in
                self?.stressCalculator.update(behavioralFactor: factor)
            }
            .store(in: &cancellables)

        // Stress calculator → published
        stressCalculator.$currentScore
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentStressScore)

        stressCalculator.$currentEmotion
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentEmotion)

        // WebSocket connected state
        webSocketService.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: &$isMarketConnected)

        // Pair manager prices → top pairs
        pairManager.$watchedPairs
            .receive(on: DispatchQueue.main)
            .map { Array($0.prefix(5)) }
            .assign(to: &$topPairs)

        // Behavior flags count
        behaviorAnalyzer.$activeFlags
            .receive(on: DispatchQueue.main)
            .map { $0.rawValue.nonzeroBitCount }
            .assign(to: &$activeFlagCount)
    }

    // MARK: - Start all services
    func startMonitoring(settings: UserSettings) {
        Task { await heartRateService.requestAuthorization() }
        heartRateService.startMonitoring()
        faceTrackingService.startTracking()
        webSocketService.connect(pairs: settings.watchedPairIDs, provider: .mock)
        pairManager.observe(webSocketService: webSocketService)
    }

    func stopMonitoring() {
        heartRateService.stopMonitoring()
        faceTrackingService.stopTracking()
        webSocketService.disconnect()
    }
}
