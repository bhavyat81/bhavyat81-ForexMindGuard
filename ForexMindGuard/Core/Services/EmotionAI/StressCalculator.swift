// StressCalculator.swift
// ForexMindGuard – Core/Services/EmotionAI
//
// Combines heart rate, facial expression, behavioural, and time-of-day signals
// into a single composite 0-100 stress score using the defined weighted formula:
//
//   Score = (HR × 0.35) + (Face × 0.30) + (Behaviour × 0.20) + (TimeOfDay × 0.15)
//
// Maintains a 5-minute rolling average and publishes changes via Combine.

import Foundation
import Combine

// MARK: - StressCalculator
final class StressCalculator: ObservableObject {

    // MARK: Published
    @Published private(set) var currentScore: Double = 0
    @Published private(set) var rollingAverageScore: Double = 0
    @Published private(set) var currentEmotion: EmotionState = .neutral
    @Published private(set) var lastSnapshot: EmotionSnapshot?

    // MARK: Combine
    private let snapshotSubject = PassthroughSubject<EmotionSnapshot, Never>()
    var snapshotPublisher: AnyPublisher<EmotionSnapshot, Never> { snapshotSubject.eraseToAnyPublisher() }

    // MARK: Inputs (updated by upstream services)
    private(set) var heartRateFactor: Double   = 0
    private(set) var facialFactor: Double      = 0
    private(set) var behavioralFactor: Double  = 0
    private(set) var lastHeartRate: Double     = 65

    // MARK: Rolling average (5-minute window)
    private var recentScores: [(score: Double, date: Date)] = []
    private let rollingWindowSeconds: TimeInterval = 5 * 60

    private let classifier = EmotionClassifier()

    // MARK: - Update inputs
    /// Called by HeartRateService when a new reading arrives.
    func update(heartRate reading: HeartRateReading) {
        heartRateFactor = reading.stressFactor
        lastHeartRate   = reading.bpm
        recalculate()
    }

    /// Called by FaceTrackingService with the latest facial factor.
    func update(facialFactor: Double) {
        self.facialFactor = facialFactor
        recalculate()
    }

    /// Called by BehaviorAnalyzer with the latest behavioural factor.
    func update(behavioralFactor: Double) {
        self.behavioralFactor = behavioralFactor
        recalculate()
    }

    // MARK: - Core calculation
    private func recalculate() {
        let timeOfDayFactor = Date().sessionStressFactor

        // Weighted formula
        let rawScore = (heartRateFactor * 0.35
                      + facialFactor    * 0.30
                      + behavioralFactor * 0.20
                      + timeOfDayFactor * 0.15) * 100

        let clampedScore = rawScore.clamped(to: 0...100)

        // Update rolling window
        let now = Date()
        recentScores.append((score: clampedScore, date: now))
        // Purge samples older than 5 minutes
        recentScores = recentScores.filter { now.timeIntervalSince($0.date) < rollingWindowSeconds }

        let rollingAvg = recentScores.map(\.score).reduce(0, +) / Double(max(recentScores.count, 1))

        // Classify emotion
        let emotion = classifier.classify(
            facialFactor: facialFactor,
            heartRateFactor: heartRateFactor,
            behavioralFactor: behavioralFactor
        )

        // Build snapshot
        let snapshot = EmotionSnapshot(
            dominantEmotion: emotion,
            stressScore: clampedScore,
            heartRateFactor: heartRateFactor,
            facialFactor: facialFactor,
            behavioralFactor: behavioralFactor,
            timeOfDayFactor: timeOfDayFactor,
            rawHeartRate: lastHeartRate
        )

        DispatchQueue.main.async { [weak self] in
            self?.currentScore = clampedScore
            self?.rollingAverageScore = rollingAvg
            self?.currentEmotion = emotion
            self?.lastSnapshot = snapshot
            self?.snapshotSubject.send(snapshot)
        }
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double { min(max(self, range.lowerBound), range.upperBound) }
}
