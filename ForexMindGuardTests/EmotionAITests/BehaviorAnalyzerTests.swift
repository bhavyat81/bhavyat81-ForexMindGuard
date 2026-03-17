// BehaviorAnalyzerTests.swift
// ForexMindGuardTests – EmotionAITests
//
// Tests for rapid-trading, revenge-trading, and excessive-trade detection.

import XCTest
@testable import ForexMindGuard

final class BehaviorAnalyzerTests: XCTestCase {

    var analyzer: BehaviorAnalyzer!

    override func setUp() {
        super.setUp()
        analyzer = BehaviorAnalyzer()
    }

    override func tearDown() {
        analyzer = nil
        super.tearDown()
    }

    // MARK: - Rapid trading

    func testRapidTrading_twoTradesWithin30s_flagged() {
        // Record two winning trades in rapid succession
        analyzer.recordTrade(pipResult: 10)
        analyzer.recordTrade(pipResult: 15)
        XCTAssertTrue(analyzer.activeFlags.contains(.rapidTrading),
                      "Two trades within 30s should flag rapid trading")
    }

    // MARK: - Revenge trading

    func testRevengeTradingFlag_threeConsecutiveLosses() {
        analyzer.recordTrade(pipResult: -20)
        analyzer.recordTrade(pipResult: -15)
        analyzer.recordTrade(pipResult: -18)
        XCTAssertTrue(analyzer.activeFlags.contains(.revengeTrading),
                      "Three consecutive losses should trigger revenge trading flag")
    }

    func testRevengeTradingFlag_notTriggeredAfterWin() {
        analyzer.recordTrade(pipResult: -20)
        analyzer.recordTrade(pipResult: -15)
        analyzer.recordTrade(pipResult: 25)  // Win breaks the streak
        analyzer.recordTrade(pipResult: -10)
        XCTAssertFalse(analyzer.activeFlags.contains(.revengeTrading),
                       "Win between losses should break the revenge trading streak")
    }

    // MARK: - Excessive trades

    func testExcessiveTrades_moreThan10InHour_flagged() {
        for i in 0..<12 {
            analyzer.recordTrade(pipResult: i % 2 == 0 ? 10 : -10)
        }
        XCTAssertTrue(analyzer.activeFlags.contains(.excessiveTrades),
                      "12 trades in an hour should flag excessive trading")
    }

    // MARK: - Factor value

    func testBehavioralFactor_noFlags_isZero() {
        XCTAssertEqual(analyzer.behavioralFactor, 0, accuracy: 0.001,
                       "No flags should produce zero factor")
    }

    func testBehavioralFactor_multipleFlags_increasesScore() {
        // Trigger multiple flags
        for _ in 0..<11 { analyzer.recordTrade(pipResult: -5) }
        XCTAssertGreaterThan(analyzer.behavioralFactor, 0.3,
                             "Multiple flags should produce a significant factor")
    }

    // MARK: - Reset

    func testReset_clearsFlagsAndFactor() {
        for i in 0..<5 { analyzer.recordTrade(pipResult: -i) }
        analyzer.reset()
        XCTAssertTrue(analyzer.activeFlags.isEmpty, "Reset should clear all flags")
        XCTAssertEqual(analyzer.behavioralFactor, 0, accuracy: 0.001, "Reset should zero the factor")
    }

    // MARK: - Panic interaction

    func testPanicInteraction_manyTapsIn30s_flagged() {
        for _ in 0..<25 { analyzer.recordInteraction() }
        XCTAssertTrue(analyzer.activeFlags.contains(.panicInteraction),
                      "25 interactions in 30s should trigger panic flag")
    }
}
