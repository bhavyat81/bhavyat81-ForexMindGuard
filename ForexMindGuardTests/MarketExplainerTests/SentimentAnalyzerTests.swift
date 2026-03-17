// SentimentAnalyzerTests.swift
// ForexMindGuardTests – MarketExplainerTests
//
// Tests for the NLP sentiment classification system.

import XCTest
@testable import ForexMindGuard

final class SentimentAnalyzerTests: XCTestCase {

    var analyzer: SentimentAnalyzer!

    override func setUp() {
        super.setUp()
        analyzer = SentimentAnalyzer()
    }

    override func tearDown() {
        analyzer = nil
        super.tearDown()
    }

    // MARK: - Bullish detection

    func testBullishText_classifiesBullish() {
        let text = "EUR/USD surged higher as the Fed announced a rate hike, signaling strong economic growth. Traders rallied behind the Dollar."
        let result = analyzer.analyze(text: text)
        XCTAssertEqual(result.sentiment, .bullish, "Text with bullish keywords should classify as bullish")
        XCTAssertGreaterThan(result.bullishScore, result.bearishScore)
    }

    // MARK: - Bearish detection

    func testBearishText_classifiesBearish() {
        let text = "EUR/USD dropped sharply as fears of recession spread. The pair fell below key support and traders remain bearish amid uncertainty."
        let result = analyzer.analyze(text: text)
        XCTAssertEqual(result.sentiment, .bearish, "Text with bearish keywords should classify as bearish")
        XCTAssertGreaterThan(result.bearishScore, result.bullishScore)
    }

    // MARK: - Neutral detection

    func testNeutralText_classifiesNeutral() {
        let text = "The currency pair traded sideways in a narrow range as markets awaited the upcoming economic data release."
        let result = analyzer.analyze(text: text)
        // May be neutral or slightly directional – just verify it doesn't strongly go one way
        XCTAssertLessThan(abs(result.bullishScore - result.bearishScore), 3.0,
                          "Neutral text should have similar bullish and bearish scores")
    }

    // MARK: - Confidence score

    func testConfidenceScore_inRange_0to1() {
        let texts = [
            "EUR/USD rallied 100 pips on strong US NFP data beating expectations.",
            "GBP/USD plunged as Brexit uncertainty caused massive selloffs.",
            "Markets are quiet today with no major data releases expected."
        ]
        for text in texts {
            let result = analyzer.analyze(text: text)
            XCTAssertGreaterThanOrEqual(result.confidence, 0, "Confidence must be >= 0")
            XCTAssertLessThanOrEqual(result.confidence, 1.0, "Confidence must be <= 1.0")
        }
    }

    // MARK: - Empty text

    func testEmptyText_returnsNeutral() {
        let result = analyzer.analyze(text: "")
        XCTAssertEqual(result.sentiment, .neutral, "Empty text should return neutral")
    }

    // MARK: - Keyword matching

    func testBullishKeywords_allPresent_highScore() {
        let text = "rally surge rise gain bullish positive strong optimistic rate hike beat exceed recovery growth upward higher strengthen"
        let result = analyzer.analyze(text: text)
        XCTAssertGreaterThan(result.bullishScore, 5.0, "All bullish keywords should produce high bullish score")
    }

    func testBearishKeywords_allPresent_highScore() {
        let text = "drop fall decline bearish weak negative pessimistic dovish rate cut miss below downward lower weaken crash plunge recession uncertainty"
        let result = analyzer.analyze(text: text)
        XCTAssertGreaterThan(result.bearishScore, 5.0, "All bearish keywords should produce high bearish score")
    }
}
