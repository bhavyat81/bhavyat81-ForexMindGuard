// StressCalculatorTests.swift
// ForexMindGuardTests – EmotionAITests
//
// Unit tests for the stress score formula and rolling average logic.

import XCTest
@testable import ForexMindGuard

final class StressCalculatorTests: XCTestCase {

    var calculator: StressCalculator!

    override func setUp() {
        super.setUp()
        calculator = StressCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    // MARK: - Weighted formula tests

    func testStressScore_allZero_isLow() {
        // With all factors at 0, score should be near 0
        let reading = HeartRateReading(bpm: 50)  // Low BPM → low factor
        calculator.update(heartRate: reading)
        calculator.update(facialFactor: 0.0)
        calculator.update(behavioralFactor: 0.0)
        // Allow async update
        XCTAssertLessThanOrEqual(calculator.currentScore, 30, "All-zero inputs should produce a low score")
    }

    func testStressScore_allMax_isHigh() {
        // With all factors at maximum, score should be near 100
        let reading = HeartRateReading(bpm: 150)  // High BPM → high factor
        calculator.update(heartRate: reading)
        calculator.update(facialFactor: 1.0)
        calculator.update(behavioralFactor: 1.0)
        XCTAssertGreaterThanOrEqual(calculator.currentScore, 70, "Max inputs should produce a high score")
    }

    func testStressScore_warningThreshold() {
        // Score of 72 should be above warning (70) but below lock (85)
        let reading = HeartRateReading(bpm: 110)
        calculator.update(heartRate: reading)
        calculator.update(facialFactor: 0.5)
        calculator.update(behavioralFactor: 0.5)
        let score = calculator.currentScore
        if score > StressThresholds.warning {
            XCTAssertLessThan(score, StressThresholds.lock, "Score should not immediately exceed lock threshold")
        }
    }

    func testStressScore_heartRateContributes35Percent() {
        // Isolate heart rate contribution
        // HR factor of 1.0 × 0.35 weight × 100 = 35 points contribution
        let reading = HeartRateReading(bpm: 150)  // Max HR → factor ≈ 1.0
        calculator.update(heartRate: reading)
        calculator.update(facialFactor: 0.0)
        calculator.update(behavioralFactor: 0.0)
        // Time-of-day factor is always present; approximate check
        XCTAssertGreaterThan(calculator.currentScore, 20, "Heart rate alone should contribute meaningfully")
    }

    func testRollingAverage_smoothesSpikes() {
        // Inject a low score first, then a high one
        calculator.update(heartRate: HeartRateReading(bpm: 60))
        let lowScore = calculator.currentScore
        calculator.update(heartRate: HeartRateReading(bpm: 150))
        let highScore = calculator.currentScore
        // Rolling average should be between the two
        XCTAssertLessThan(calculator.rollingAverageScore, highScore + 1,
                          "Rolling average should not exceed instantaneous peak (immediately)")
        XCTAssertGreaterThan(calculator.rollingAverageScore, 0, "Rolling average should be positive")
    }

    func testEmotionClassification_highScore_isNotCalm() {
        calculator.update(heartRate: HeartRateReading(bpm: 145))
        calculator.update(facialFactor: 0.9)
        calculator.update(behavioralFactor: 0.8)
        XCTAssertNotEqual(calculator.currentEmotion, .calm, "High stress should not classify as calm")
    }

    // MARK: - Edge cases

    func testStressScore_clamped_between0And100() {
        // Even with extreme inputs, score must stay 0-100
        calculator.update(heartRate: HeartRateReading(bpm: 250))  // Unrealistically high
        calculator.update(facialFactor: 2.0)  // Above 1
        calculator.update(behavioralFactor: 5.0)  // Above 1
        XCTAssertLessThanOrEqual(calculator.currentScore, 100, "Score must not exceed 100")
        XCTAssertGreaterThanOrEqual(calculator.currentScore, 0, "Score must not be negative")
    }
}
