// ForexMindGuardUITests.swift
// ForexMindGuardUITests
//
// Basic UI tests verifying key screens and navigation flows.

import XCTest

final class ForexMindGuardUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Skip onboarding for UI tests
        app.launchArguments += ["-hasCompletedOnboarding", "true"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Main tab bar

    func testMainTabBar_isVisible() {
        // Tab bar should be present on main screen
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should be visible")
    }

    func testDashboardTab_showsStressSection() {
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 5))
        dashboardTab.tap()

        let stressText = app.staticTexts["Stress Score"]
        XCTAssertTrue(stressText.waitForExistence(timeout: 5), "Dashboard should show Stress Score")
    }

    func testEmotionTab_isAccessible() {
        let emotionTab = app.tabBars.buttons["Emotions"]
        XCTAssertTrue(emotionTab.waitForExistence(timeout: 5))
        emotionTab.tap()

        let navTitle = app.navigationBars["Emotion Monitor"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
    }

    func testExplainerTab_isAccessible() {
        let explainerTab = app.tabBars.buttons["Explainer"]
        XCTAssertTrue(explainerTab.waitForExistence(timeout: 5))
        explainerTab.tap()

        let navTitle = app.navigationBars["AI Explainer"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
    }

    func testWatchlistTab_isAccessible() {
        let watchlistTab = app.tabBars.buttons["Watchlist"]
        XCTAssertTrue(watchlistTab.waitForExistence(timeout: 5))
        watchlistTab.tap()

        let navTitle = app.navigationBars["Watchlist"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
    }

    func testSettingsTab_isAccessible() {
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let navTitle = app.navigationBars["Settings"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
    }

    // MARK: - Watchlist

    func testWatchlistTab_showsCurrencyPairs() {
        app.tabBars.buttons["Watchlist"].tap()
        // Default pairs should be visible
        let eurusdCell = app.staticTexts["EUR/USD"]
        XCTAssertTrue(eurusdCell.waitForExistence(timeout: 5), "EUR/USD should appear in watchlist")
    }

    // MARK: - Settings navigation

    func testSettings_stressThresholds_navigates() {
        app.tabBars.buttons["Settings"].tap()
        let thresholdsCell = app.cells.containing(.staticText, identifier: "Stress Thresholds").firstMatch
        if thresholdsCell.waitForExistence(timeout: 3) {
            thresholdsCell.tap()
            let backButton = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        }
    }

    // MARK: - Accessibility

    func testDashboard_accessibilityLabels_arePresent() {
        app.tabBars.buttons["Dashboard"].tap()
        // Check that accessibility elements exist
        XCTAssertTrue(app.staticTexts.count > 0, "Dashboard should have accessible text elements")
    }
}
