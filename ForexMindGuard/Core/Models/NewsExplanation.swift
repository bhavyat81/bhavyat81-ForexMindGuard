// NewsExplanation.swift
// ForexMindGuard – Core Models
//
// The result of the AI "Why Did It Move?" pipeline:
//  news articles + OpenAI GPT → plain-English explanation + sentiment

import Foundation

// MARK: - Sentiment
enum Sentiment: String, Codable, CaseIterable {
    case bullish = "Bullish"
    case bearish = "Bearish"
    case neutral = "Neutral"

    var emoji: String {
        switch self {
        case .bullish: return "📈"
        case .bearish: return "📉"
        case .neutral: return "⚖️"
        }
    }

    var colorName: String {
        switch self {
        case .bullish: return "neonGreen"
        case .bearish: return "dangerRed"
        case .neutral: return "systemGray"
        }
    }
}

// MARK: - NewsSource
struct NewsSource: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let url: URL
    let publishedAt: Date
    let sourceName: String

    init(id: UUID = UUID(), title: String, url: URL, publishedAt: Date = Date(), sourceName: String) {
        self.id = id
        self.title = title
        self.url = url
        self.publishedAt = publishedAt
        self.sourceName = sourceName
    }

    static let sample = NewsSource(
        title: "ECB Holds Rates Steady, Signals Caution on Inflation",
        url: URL(string: "https://example.com/ecb-rates")!,
        publishedAt: Date().addingTimeInterval(-3600),
        sourceName: "Reuters"
    )
}

// MARK: - NewsExplanation
/// Plain-English AI explanation for a price movement, with sources and sentiment.
struct NewsExplanation: Codable, Identifiable {
    let id: UUID
    let movementID: UUID       // Links back to the PriceMovement
    let headline: String       // Short headline e.g. "EUR drops 80 pips on ECB surprise"
    let summary: String        // 1-2 sentence summary
    let aiExplanation: String  // Full GPT-generated explanation (2–4 paragraphs)
    let sentiment: Sentiment
    let confidenceScore: Double   // 0.0–1.0
    let sources: [NewsSource]
    let timestamp: Date
    let pairSymbol: String     // e.g. "EUR/USD"
    let isLoading: Bool        // True while awaiting API response

    init(
        id: UUID = UUID(),
        movementID: UUID = UUID(),
        headline: String,
        summary: String,
        aiExplanation: String,
        sentiment: Sentiment,
        confidenceScore: Double,
        sources: [NewsSource],
        timestamp: Date = Date(),
        pairSymbol: String,
        isLoading: Bool = false
    ) {
        self.id = id
        self.movementID = movementID
        self.headline = headline
        self.summary = summary
        self.aiExplanation = aiExplanation
        self.sentiment = sentiment
        self.confidenceScore = confidenceScore
        self.sources = sources
        self.timestamp = timestamp
        self.pairSymbol = pairSymbol
        self.isLoading = isLoading
    }

    var formattedConfidence: String { String(format: "%.0f%%", confidenceScore * 100) }

    // MARK: Sample data
    static let sample = NewsExplanation(
        headline: "EUR/USD drops 80 pips as ECB signals policy hold",
        summary: "The Euro fell sharply after the ECB kept rates unchanged, disappointing traders who expected a cut.",
        aiExplanation: """
        The Euro weakened significantly against the US Dollar today, falling approximately 80 pips in just 15 minutes during the European session. The primary catalyst was the European Central Bank's (ECB) monetary policy decision.

        The ECB voted unanimously to keep interest rates unchanged at 4.00%, surprising a portion of the market that had been pricing in a 25 basis point cut based on recent softer inflation data. ECB President Christine Lagarde emphasized that the Governing Council remains committed to maintaining restrictive policy "as long as necessary" to return inflation to the 2% target.

        This hawkish-hold stance strengthened the Dollar relative narrative but also raised concerns about Eurozone economic stagnation, causing EUR/USD sellers to dominate. Additionally, stronger-than-expected US ISM Manufacturing data released simultaneously added further downside pressure on the pair.

        Key levels to watch: Support at 1.0750, resistance at 1.0820. The next major catalyst will be US Non-Farm Payrolls on Friday.
        """,
        sentiment: .bearish,
        confidenceScore: 0.87,
        sources: [.sample],
        pairSymbol: "EUR/USD"
    )

    /// Placeholder while loading
    static let loading = NewsExplanation(
        headline: "Analysing market movement…",
        summary: "Fetching news and generating AI explanation",
        aiExplanation: "",
        sentiment: .neutral,
        confidenceScore: 0,
        sources: [],
        pairSymbol: "EUR/USD",
        isLoading: true
    )
}
