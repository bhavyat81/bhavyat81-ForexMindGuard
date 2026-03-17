// Constants.swift
// ForexMindGuard – Utilities
//
// App-wide constants including API key placeholders, default thresholds, and URLs.
// IMPORTANT: Replace TODO placeholders with real values before building for production.
// Never commit actual API keys to source control.

import Foundation

// MARK: - API Keys (load from Keychain / environment in production)
enum APIKeys {
    /// TODO: Set via Keychain or environment variable – never hard-code
    static var openAI: String { APIKeyManager.shared.key(for: .openAI) ?? "YOUR_OPENAI_API_KEY" }
    static var alphaVantage: String { APIKeyManager.shared.key(for: .alphaVantage) ?? "YOUR_ALPHA_VANTAGE_KEY" }
    static var traderMade: String { APIKeyManager.shared.key(for: .traderMade) ?? "YOUR_TRADERMADE_KEY" }
    static var finage: String { APIKeyManager.shared.key(for: .finage) ?? "YOUR_FINAGE_KEY" }
    static var newsAPI: String { APIKeyManager.shared.key(for: .newsAPI) ?? "YOUR_NEWS_API_KEY" }
}

// MARK: - API Endpoints
enum APIEndpoints {
    // WebSocket
    static let traderMadeWS  = "wss://marketdata.tradermade.com/feedadv"
    static let finageWS      = "wss://e.finage.co.uk/forex"

    // REST
    static let alphaVantageBase = "https://www.alphavantage.co/query"
    static let traderMadeBase   = "https://marketdata.tradermade.com/api/v1"
    static let newsAPIBase      = "https://newsapi.org/v2"
    static let openAIBase       = "https://api.openai.com/v1"

    // OpenAI
    static let openAIChatCompletions = "\(openAIBase)/chat/completions"
}

// MARK: - Default Thresholds
enum DefaultThresholds {
    static let warningStress: Double = 70.0
    static let lockStress: Double    = 85.0
    static let cooldownSeconds: TimeInterval = 900  // 15 min
    static let significantMovePips: Double   = 20.0
    static let movementWindowMinutes: Int    = 15
    static let restingHeartRate: Double      = 65.0
    static let elevatedHeartRate: Double     = 100.0

    // Behavioral analysis
    static let rapidTradeIntervalSeconds: TimeInterval = 30  // < 30s between trades = rapid
    static let maxTradesPerHour: Int = 10  // More than this → behavioral flag
    static let rageTradingWindowMinutes: Int = 5
}

// MARK: - OpenAI
enum OpenAIConfig {
    static let model = "gpt-4o"
    static let maxTokens = 800
    static let temperature = 0.4
    static let systemPrompt = """
    You are ForexMindGuard's AI Market Explainer. Your role is to explain why a forex currency pair moved significantly.
    
    Rules:
    1. Explain the WHY in clear, jargon-free language suitable for intermediate traders.
    2. Always reference specific economic events, central bank decisions, or geopolitical factors.
    3. Provide 2-4 paragraphs.
    4. End with key support/resistance levels to watch.
    5. Be factual and cite the news sources provided.
    6. Keep the tone professional but accessible.
    """
}

// MARK: - Notification identifiers
enum NotificationConstants {
    static let stressCategoryID           = "STRESS_CATEGORY"
    static let marketCategoryID           = "MARKET_CATEGORY"
    static let overrideActionID           = "OVERRIDE_LOCK_ACTION"
    static let viewExplanationActionID    = "VIEW_EXPLANATION_ACTION"
    static let stressWarningNotifID       = "stress_warning"
    static let tradingLockedNotifID       = "trading_locked"
    static let marketMovementNotifID      = "market_movement"
}

// MARK: - UserDefaults keys
enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let watchedPairs           = "watchedPairs"
    static let userSettings           = "userSettings"
    static let sessionHistory         = "sessionHistory"
}
