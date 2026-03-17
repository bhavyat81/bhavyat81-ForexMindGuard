// SentimentAnalyzer.swift
// ForexMindGuard – Core/Services/NewsAI
//
// Performs NLP-based sentiment analysis on news/AI-generated text to produce
// a bullish/bearish/neutral classification with a confidence score.
// Uses a keyword-weighted rule-based approach as the default, compatible with
// CoreML NaturalLanguage framework for on-device inference.

import Foundation
import NaturalLanguage

// MARK: - Sentiment result
struct SentimentResult {
    let sentiment: Sentiment
    let confidence: Double   // 0.0 – 1.0
    let bullishScore: Double
    let bearishScore: Double
}

// MARK: - SentimentAnalyzer
final class SentimentAnalyzer {

    // MARK: - Keyword dictionaries
    private let bullishKeywords: [String: Double] = [
        "rally": 1.0, "surge": 1.0, "rise": 0.8, "gain": 0.8, "bullish": 1.0,
        "positive": 0.7, "strong": 0.7, "optimistic": 0.8, "hawkish": 0.9,
        "rate hike": 1.0, "beat": 0.8, "exceed": 0.8, "recovery": 0.7,
        "growth": 0.6, "upward": 0.8, "higher": 0.6, "strengthen": 0.8
    ]

    private let bearishKeywords: [String: Double] = [
        "drop": 1.0, "fall": 0.8, "decline": 0.8, "bearish": 1.0, "weak": 0.7,
        "negative": 0.7, "pessimistic": 0.8, "dovish": 0.9, "rate cut": 1.0,
        "miss": 0.8, "below": 0.6, "downward": 0.8, "lower": 0.6, "weaken": 0.8,
        "crash": 1.0, "plunge": 1.0, "recession": 0.9, "uncertainty": 0.6
    ]

    // MARK: - Analyse
    func analyze(text: String) -> SentimentResult {
        let lowered = text.lowercased()

        var bullishScore = 0.0
        var bearishScore = 0.0

        // Keyword scoring
        for (keyword, weight) in bullishKeywords {
            if lowered.contains(keyword) { bullishScore += weight }
        }
        for (keyword, weight) in bearishKeywords {
            if lowered.contains(keyword) { bearishScore += weight }
        }

        // Apple NaturalLanguage sentiment (on-device)
        let nlScore = appleNLSentimentScore(text: text)
        // NL returns -1.0 (negative) to +1.0 (positive)
        if nlScore > 0.1 { bullishScore += nlScore * 2 }
        else if nlScore < -0.1 { bearishScore += abs(nlScore) * 2 }

        let total = bullishScore + bearishScore
        let confidence: Double
        let sentiment: Sentiment

        if total == 0 {
            return SentimentResult(sentiment: .neutral, confidence: 0.5, bullishScore: 0, bearishScore: 0)
        }

        let bullishRatio = bullishScore / total
        let bearishRatio = bearishScore / total

        if bullishRatio > 0.6 {
            sentiment  = .bullish
            confidence = min(bullishRatio, 0.99)
        } else if bearishRatio > 0.6 {
            sentiment  = .bearish
            confidence = min(bearishRatio, 0.99)
        } else {
            sentiment  = .neutral
            confidence = 0.5
        }

        return SentimentResult(
            sentiment: sentiment,
            confidence: confidence,
            bullishScore: bullishScore,
            bearishScore: bearishScore
        )
    }

    // MARK: - Apple NaturalLanguage sentiment
    private func appleNLSentimentScore(text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let (tag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        return Double(tag?.rawValue ?? "0") ?? 0
    }
}
