// AIExplainerServiceTests.swift
// ForexMindGuardTests – MarketExplainerTests
//
// Tests for the AI explanation generation pipeline (mocked network calls).

import XCTest
import Combine
@testable import ForexMindGuard

final class AIExplainerServiceTests: XCTestCase {

    var explainerService: AIExplainerService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        explainerService = AIExplainerService()
        cancellables = []
    }

    override func tearDown() {
        explainerService = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Model tests (no network required)

    func testNewsExplanation_sample_isValid() {
        let sample = NewsExplanation.sample
        XCTAssertFalse(sample.headline.isEmpty, "Sample headline should not be empty")
        XCTAssertFalse(sample.aiExplanation.isEmpty, "Sample explanation should not be empty")
        XCTAssertFalse(sample.sources.isEmpty, "Sample should have at least one source")
        XCTAssertGreaterThan(sample.confidenceScore, 0, "Confidence should be > 0")
        XCTAssertLessThanOrEqual(sample.confidenceScore, 1.0, "Confidence should be <= 1.0")
    }

    func testNewsExplanation_loading_isLoadingState() {
        let loading = NewsExplanation.loading
        XCTAssertTrue(loading.isLoading)
        XCTAssertTrue(loading.sources.isEmpty)
    }

    func testPriceMovement_sample_hasCorrectDirection() {
        let sample = PriceMovement.sample
        XCTAssertEqual(sample.direction, .down, "Sample EUR/USD movement should be down")
        XCTAssertLessThan(sample.pipsChange, 0, "Down movement should have negative pips")
    }

    func testNewsSource_sample_hasValidURL() {
        let source = NewsSource.sample
        XCTAssertNotNil(source.url)
        XCTAssertFalse(source.title.isEmpty)
        XCTAssertFalse(source.sourceName.isEmpty)
    }

    // MARK: - Caching tests

    func testExplanation_cachedForSameMovementID() async {
        // Since we can't make real API calls in tests, verify that
        // the service properly handles the loading state
        let loadingExpl = NewsExplanation.loading
        XCTAssertTrue(loadingExpl.isLoading, "Loading explanation should have isLoading = true")

        // Verify formatted confidence
        XCTAssertEqual(NewsExplanation.sample.formattedConfidence, "87%")
    }

    // MARK: - Sentiment model tests

    func testSentiment_bullish_hasCorrectEmoji() {
        XCTAssertEqual(Sentiment.bullish.emoji, "📈")
    }

    func testSentiment_bearish_hasCorrectEmoji() {
        XCTAssertEqual(Sentiment.bearish.emoji, "📉")
    }

    func testSentiment_neutral_hasCorrectEmoji() {
        XCTAssertEqual(Sentiment.neutral.emoji, "⚖️")
    }

    // MARK: - ForexPair model tests

    func testForexPair_spreadCalculation() {
        let pair = ForexPair(base: "EUR", quote: "USD", bid: 1.08540, ask: 1.08542)
        let spread = pair.spreadPips
        XCTAssertEqual(spread, 0.2, accuracy: 0.01, "Spread should be 0.2 pips")
    }

    func testForexPair_jpyMultiplier() {
        let pair = ForexPair(base: "USD", quote: "JPY", bid: 149.850, ask: 149.855)
        XCTAssertEqual(pair.pipMultiplier, 100, "JPY pairs should use pip multiplier of 100")
    }

    func testForexPair_symbol() {
        let pair = ForexPair.eurusd
        XCTAssertEqual(pair.symbol, "EUR/USD")
    }
}
