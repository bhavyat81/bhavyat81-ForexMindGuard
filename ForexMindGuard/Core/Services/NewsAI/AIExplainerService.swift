// AIExplainerService.swift
// ForexMindGuard – Core/Services/NewsAI
//
// Orchestrates the "Why Did It Move?" pipeline:
//  1. Triggered by PriceAlertService significant movement
//  2. Fetches relevant news from NewsAPIService
//  3. Bundles price context + news into a GPT-4 prompt
//  4. Sends to OpenAI Chat Completions API
//  5. Parses response into NewsExplanation model
//  6. Caches explanations to avoid duplicate API calls

import Foundation
import Combine

// MARK: - OpenAI API request/response types
private struct OpenAIChatRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let maxTokens: Int
    let temperature: Double

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

private struct ChatMessage: Encodable {
    let role: String   // "system", "user", "assistant"
    let content: String
}

private struct OpenAIChatResponse: Decodable {
    let choices: [Choice]
    struct Choice: Decodable {
        let message: ResponseMessage
        struct ResponseMessage: Decodable {
            let content: String
        }
    }
}

// MARK: - AIExplainerService
final class AIExplainerService: ObservableObject, ExplanationProvider {

    // MARK: Published
    @Published private(set) var explanations: [NewsExplanation] = []
    @Published private(set) var isGenerating: Bool = false

    // MARK: Combine
    private let explanationSubject = PassthroughSubject<NewsExplanation, Never>()
    var explanationPublisher: AnyPublisher<NewsExplanation, Never> { explanationSubject.eraseToAnyPublisher() }

    // MARK: Dependencies
    private let newsService     = NewsAPIService()
    private let sentimentService = SentimentAnalyzer()
    private let session          = URLSession.shared

    // MARK: Cache: movementID → explanation
    private var cache: [UUID: NewsExplanation] = [:]

    // MARK: - ExplanationProvider
    func explain(_ movement: PriceMovement) async throws -> NewsExplanation {
        // Return cached if available
        if let cached = cache[movement.id] { return cached }

        await MainActor.run { isGenerating = true }

        // 1. Fetch news
        let sources = (try? await newsService.fetchNews(for: movement.pair, limit: 5)) ?? []

        // 2. Build prompt
        let prompt = buildPrompt(movement: movement, news: sources)

        // 3. Call OpenAI
        let aiText = try await callOpenAI(prompt: prompt)

        // 4. Sentiment analysis
        let sentiment = sentimentService.analyse(text: aiText)

        // 5. Extract headline (first sentence of AI response)
        let headline = extractHeadline(from: aiText, movement: movement)
        let summary  = extractSummary(from: aiText)

        let explanation = NewsExplanation(
            movementID: movement.id,
            headline: headline,
            summary: summary,
            aiExplanation: aiText,
            sentiment: sentiment.sentiment,
            confidenceScore: sentiment.confidence,
            sources: sources,
            pairSymbol: movement.pair
        )

        // 6. Cache and publish
        cache[movement.id] = explanation
        await MainActor.run { [weak self] in
            self?.explanations.insert(explanation, at: 0)
            if let self, self.explanations.count > 100 { self.explanations.removeLast() }
            self?.isGenerating = false
            self?.explanationSubject.send(explanation)
        }
        return explanation
    }

    // MARK: - Build GPT prompt
    private func buildPrompt(movement: PriceMovement, news: [NewsSource]) -> String {
        let newsContext = news.enumerated().map { idx, src in
            "\(idx + 1). \(src.title) (\(src.sourceName))"
        }.joined(separator: "\n")

        return """
        Currency pair: \(movement.pair)
        Movement: \(movement.formattedPips) in \(movement.timeframeLabel) (\(movement.direction.rawValue))
        Price: \(movement.startPrice) → \(movement.endPrice)
        
        Recent news articles:
        \(newsContext.isEmpty ? "No specific news found. Use general forex analysis." : newsContext)
        
        Please explain why this price movement occurred.
        """
    }

    // MARK: - OpenAI API call
    private func callOpenAI(prompt: String) async throws -> String {
        guard let url = URL(string: APIEndpoints.openAIChatCompletions) else {
            throw ForexAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIKeys.openAI)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = OpenAIChatRequest(
            model: OpenAIConfig.model,
            messages: [
                ChatMessage(role: "system", content: OpenAIConfig.systemPrompt),
                ChatMessage(role: "user",   content: prompt)
            ],
            maxTokens: OpenAIConfig.maxTokens,
            temperature: OpenAIConfig.temperature
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ForexAPIError.apiError("HTTP \(httpResponse.statusCode)")
        }

        let decoded = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
        return decoded.choices.first?.message.content ?? "Unable to generate explanation."
    }

    // MARK: - Helpers
    private func extractHeadline(from text: String, movement: PriceMovement) -> String {
        let firstSentence = text.components(separatedBy: ".").first ?? ""
        if firstSentence.count > 20 && firstSentence.count < 120 {
            return firstSentence.trimmingCharacters(in: .whitespaces)
        }
        return "\(movement.pair) moves \(movement.formattedPips)"
    }

    private func extractSummary(from text: String) -> String {
        let sentences = text.components(separatedBy: ".")
        let first2 = sentences.prefix(2).joined(separator: ".").trimmingCharacters(in: .whitespaces)
        return first2.isEmpty ? text : first2 + "."
    }
}
