// EmotionMonitorViewModel.swift
// ForexMindGuard – Features/EmotionMonitor

import Foundation
import Combine

final class EmotionMonitorViewModel: ObservableObject {

    // MARK: Published
    @Published var currentSnapshot: EmotionSnapshot = .calm
    @Published var stressHistory: [EmotionSnapshot] = []
    @Published var heartRate: Double = 65
    @Published var isHeartRateElevated: Bool = false
    @Published var detectedEmotion: EmotionState = .neutral
    @Published var isFaceTrackingActive: Bool = false
    @Published var behavioralFlags: [String] = []

    // MARK: Services
    let heartRateService   = HeartRateService()
    let faceTrackingService = FaceTrackingService()
    let stressCalculator   = StressCalculator()
    let behaviorAnalyzer   = BehaviorAnalyzer()

    private var cancellables = Set<AnyCancellable>()

    init() {
        bind()
    }

    private func bind() {
        heartRateService.$latestReading
            .compactMap { $0 }
            .sink { [weak self] reading in
                self?.heartRate = reading.bpm
                self?.isHeartRateElevated = reading.isElevated
                self?.stressCalculator.update(heartRate: reading)
            }
            .store(in: &cancellables)

        faceTrackingService.$detectedEmotion
            .receive(on: DispatchQueue.main)
            .assign(to: &$detectedEmotion)

        faceTrackingService.$facialFactor
            .sink { [weak self] factor in self?.stressCalculator.update(facialFactor: factor) }
            .store(in: &cancellables)

        faceTrackingService.$isTracking
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFaceTrackingActive)

        behaviorAnalyzer.$flagDescriptions
            .receive(on: DispatchQueue.main)
            .assign(to: &$behavioralFlags)

        behaviorAnalyzer.$behavioralFactor
            .sink { [weak self] factor in self?.stressCalculator.update(behavioralFactor: factor) }
            .store(in: &cancellables)

        stressCalculator.$lastSnapshot
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.currentSnapshot = snapshot
                self?.stressHistory.append(snapshot)
                if let self, self.stressHistory.count > 300 {
                    self.stressHistory.removeFirst()
                }
            }
            .store(in: &cancellables)
    }

    func startMonitoring() {
        Task { await heartRateService.requestAuthorization() }
        heartRateService.startMonitoring()
        faceTrackingService.startTracking()
    }

    func stopMonitoring() {
        heartRateService.stopMonitoring()
        faceTrackingService.stopTracking()
    }
}
