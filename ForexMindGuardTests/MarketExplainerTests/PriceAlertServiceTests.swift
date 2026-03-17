// PriceAlertServiceTests.swift
// ForexMindGuardTests – MarketExplainerTests
//
// Tests for significant pip movement detection logic.

import XCTest
import Combine
@testable import ForexMindGuard

final class PriceAlertServiceTests: XCTestCase {

    var alertService: PriceAlertService!
    var webSocketService: ForexWebSocketService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        alertService = PriceAlertService()
        alertService.pipThreshold = 20.0
        alertService.windowMinutes = 15
        webSocketService = ForexWebSocketService()
        cancellables = []
    }

    override func tearDown() {
        alertService = nil
        webSocketService = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Pip movement detection

    func testSignificantMove_triggers_movementEvent() {
        let expectation = expectation(description: "Movement detected")

        alertService.movementPublisher
            .sink { movement in
                XCTAssertEqual(movement.pair, "EURUSD")
                XCTAssertGreaterThanOrEqual(abs(movement.pipsChange), 20)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Simulate a 30-pip move by injecting ticks
        alertService.observe(webSocketService: webSocketService)
        webSocketService.connect(pairs: ["EURUSD"], provider: .mock)

        // Wait for mock stream to produce a significant move
        wait(for: [expectation], timeout: 10.0)
    }

    func testSmallMove_doesNot_triggerAlert() {
        var movementsReceived = 0

        alertService.movementPublisher
            .sink { _ in movementsReceived += 1 }
            .store(in: &cancellables)

        // Set very high threshold so mock data won't trigger
        alertService.pipThreshold = 10000  // Essentially infinite

        alertService.observe(webSocketService: webSocketService)
        webSocketService.connect(pairs: ["EURUSD"], provider: .mock)

        // Wait briefly
        let exp = expectation(description: "No movement")
        exp.isInverted = true
        alertService.movementPublisher
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 3.0)
        XCTAssertEqual(movementsReceived, 0, "High threshold should not trigger any alerts")
    }

    // MARK: - Direction detection

    func testMovement_direction_isDown() {
        let movement = PriceMovement(
            pair: "EURUSD",
            pipsChange: -45.0,
            percentChange: -0.042,
            timeframe: 15,
            direction: .down,
            startPrice: 1.09000,
            endPrice: 1.08550
        )
        XCTAssertEqual(movement.direction, .down)
        XCTAssertTrue(movement.isSignificant)
    }

    func testMovement_direction_isUp() {
        let movement = PriceMovement(
            pair: "GBPUSD",
            pipsChange: 35.0,
            percentChange: 0.027,
            timeframe: 15,
            direction: .up,
            startPrice: 1.27000,
            endPrice: 1.27350
        )
        XCTAssertEqual(movement.direction, .up)
        XCTAssertTrue(movement.isSignificant)
    }

    // MARK: - Formatted output

    func testFormattedPips_positiveMove() {
        let movement = PriceMovement(
            pair: "EURUSD", pipsChange: 30, percentChange: 0.03, timeframe: 15,
            direction: .up, startPrice: 1.08, endPrice: 1.083
        )
        XCTAssertTrue(movement.formattedPips.hasPrefix("+"), "Positive pip change should have + prefix")
    }

    func testFormattedPips_negativeMove() {
        let movement = PriceMovement(
            pair: "EURUSD", pipsChange: -30, percentChange: -0.03, timeframe: 15,
            direction: .down, startPrice: 1.08, endPrice: 1.077
        )
        XCTAssertTrue(movement.formattedPips.hasPrefix("-"), "Negative pip change should have - prefix")
    }

    // MARK: - Timeframe label

    func testTimeframeLabel_underOneHour() {
        let movement = PriceMovement(pair: "EURUSD", pipsChange: 20, percentChange: 0.02, timeframe: 15, direction: .up, startPrice: 1, endPrice: 1)
        XCTAssertEqual(movement.timeframeLabel, "15m")
    }

    func testTimeframeLabel_oneHour() {
        let movement = PriceMovement(pair: "EURUSD", pipsChange: 20, percentChange: 0.02, timeframe: 60, direction: .up, startPrice: 1, endPrice: 1)
        XCTAssertEqual(movement.timeframeLabel, "1h")
    }
}
