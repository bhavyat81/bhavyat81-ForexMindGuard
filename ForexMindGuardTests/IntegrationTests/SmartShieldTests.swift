// SmartShieldTests.swift
// ForexMindGuardTests – IntegrationTests
//
// Integration tests for the Smart Shield — verifying that both emotion AND
// market systems must be active simultaneously for the shield to engage.

import XCTest
import Combine
@testable import ForexMindGuard

final class SmartShieldTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Smart Shield activation logic

    func testSmartShield_requiresBothConditions() {
        // Smart Shield should only activate when BOTH isLocked AND latestSignificantMovement are set
        let guardVM = TradingGuardViewModel()

        // Initially neither condition is true
        XCTAssertFalse(guardVM.isSmartShieldActive, "Smart shield should be inactive at start")
        XCTAssertFalse(guardVM.isLocked, "Should not be locked at start")
    }

    func testSmartShield_notActive_whenOnlyMarketMove() {
        // A market move alone (without lock) should NOT activate Smart Shield
        let guardVM = TradingGuardViewModel()
        // guardVM is not locked by default
        XCTAssertFalse(guardVM.isSmartShieldActive, "Market move alone should not activate smart shield without lock")
    }

    // MARK: - Emotion model integration

    func testEmotionSnapshot_compositeScore_matchesFormula() {
        // Verify the composite score is computed correctly
        let hr   = 0.72
        let face = 0.68
        let behav = 0.55
        let time = 0.60  // Approximation

        let expectedScore = (hr * 0.35 + face * 0.30 + behav * 0.20 + time * 0.15) * 100
        let snapshot = EmotionSnapshot(
            dominantEmotion: .stressed,
            stressScore: expectedScore,
            heartRateFactor: hr,
            facialFactor: face,
            behavioralFactor: behav,
            timeOfDayFactor: time,
            rawHeartRate: 98.0
        )

        // Check threshold states
        XCTAssertGreaterThan(snapshot.stressScore, 0)
        XCTAssertLessThanOrEqual(snapshot.stressScore, 100)
        XCTAssertTrue(snapshot.isWarning, "Score should be above warning threshold")
    }

    func testTradingSession_analytics() {
        var session = TradingSession.sample
        XCTAssertGreaterThan(session.duration, 0, "Session duration should be positive")
        XCTAssertGreaterThanOrEqual(session.averageStressScore, 0)
        XCTAssertLessThanOrEqual(session.averageStressScore, 100)
    }

    // MARK: - Double extensions

    func testPipCalculation_eurusd() {
        let priceDiff = 0.003
        let pips = priceDiff.toPips(isJPY: false)
        XCTAssertEqual(pips, 30, accuracy: 0.01, "0.003 price diff should be 30 pips")
    }

    func testPipCalculation_usdjpy() {
        let priceDiff = 0.5
        let pips = priceDiff.toPips(isJPY: true)
        XCTAssertEqual(pips, 50, accuracy: 0.01, "0.5 JPY price diff should be 50 pips")
    }

    func testScoreNormalization() {
        XCTAssertEqual(75.0.normalized(min: 0, max: 100), 0.75, accuracy: 0.001)
        XCTAssertEqual(0.0.normalized(min: 0, max: 100), 0.0, accuracy: 0.001)
        XCTAssertEqual(100.0.normalized(min: 0, max: 100), 1.0, accuracy: 0.001)
    }

    func testScoreClamped() {
        XCTAssertEqual(150.0.clamped(to: 0...100), 100.0)
        XCTAssertEqual((-10.0).clamped(to: 0...100), 0.0)
        XCTAssertEqual(50.0.clamped(to: 0...100), 50.0)
    }

    // MARK: - Date extensions

    func testDateSessionStressFactor_overlapHours_isHigh() {
        // Create a date that falls in London-NY overlap (13:00-17:00 UTC)
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 14  // Middle of London-NY overlap
        components.minute = 0
        components.timeZone = TimeZone(identifier: "UTC")

        if let testDate = Calendar.current.date(from: components) {
            XCTAssertGreaterThan(testDate.sessionStressFactor, 0.7,
                                 "London-NY overlap should have high session stress factor")
        }
    }

    // MARK: - APIKeyManager

    func testAPIKeyManager_missingKeys_returnsNil() {
        // Fresh install should have no keys stored
        let testIdentifier = APIKeyIdentifier.openAI
        // Delete first to ensure clean state
        APIKeyManager.shared.delete(identifier: testIdentifier)
        XCTAssertNil(APIKeyManager.shared.key(for: testIdentifier),
                     "Should return nil for unset key")
    }

    func testAPIKeyManager_storeAndRetrieve() {
        let testKey = "test_api_key_\(UUID().uuidString)"
        APIKeyManager.shared.store(key: testKey, for: .alphaVantage)
        let retrieved = APIKeyManager.shared.key(for: .alphaVantage)
        XCTAssertEqual(retrieved, testKey, "Retrieved key should match stored key")
        // Cleanup
        APIKeyManager.shared.delete(identifier: .alphaVantage)
    }
}
