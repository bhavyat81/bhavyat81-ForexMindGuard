// NewsAPIService.swift
// ForexMindGuard – Core/Services/NewsAI
//
// Fetches recent forex news articles related to a currency pair from NewsAPI.org
// or Alpha Vantage News Sentiment endpoint.

import Foundation

// MARK: - Raw news article from API
struct RawNewsArticle: Decodable {
    let title: String
    let description: String?
    let url: String
    let publishedAt: String
    let source: RawSource

    struct RawSource: Decodable {
        let name: String
    }
}

struct NewsAPIResponse: Decodable {
    let articles: [RawNewsArticle]
}

// MARK: - NewsAPIService
final class NewsAPIService {

    private let session = URLSession.shared

    // MARK: - Fetch news for a currency pair
    /// Returns recent news articles relevant to a forex pair (e.g. "EURUSD").
    func fetchNews(for pair: String, limit: Int = 5) async throws -> [NewsSource] {
        let query = buildQuery(for: pair)
        let urlString = "\(APIEndpoints.newsAPIBase)/everything?q=\(query)&language=en&sortBy=publishedAt&pageSize=\(limit)&apiKey=\(APIKeys.newsAPI)"

        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            throw ForexAPIError.invalidURL
        }

        let (data, _): (Data, URLResponse)
        do {
            (data, _) = try await session.data(from: url)
        } catch {
            throw ForexAPIError.networkError(error)
        }

        let response: NewsAPIResponse
        do {
            response = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
        } catch {
            throw ForexAPIError.decodingError(error)
        }

        let formatter = ISO8601DateFormatter()
        return response.articles.compactMap { article -> NewsSource? in
            guard let url = URL(string: article.url) else { return nil }
            let date = formatter.date(from: article.publishedAt) ?? Date()
            return NewsSource(
                title: article.title,
                url: url,
                publishedAt: date,
                sourceName: article.source.name
            )
        }
    }

    // MARK: - Build search query from pair
    private func buildQuery(for pair: String) -> String {
        guard pair.count >= 6 else { return pair }
        let base  = String(pair.prefix(3))
        let quote = String(pair.suffix(3))
        let currencyNames = CurrencyNames.name(for:)
        let baseName  = currencyNames(base)
        let quoteName = currencyNames(quote)
        return "\(base) \(quote) OR \(baseName) \(quoteName) forex"
    }
}

// MARK: - Currency display names
enum CurrencyNames {
    static func name(for code: String) -> String {
        switch code.uppercased() {
        case "EUR": return "Euro"
        case "USD": return "Dollar"
        case "GBP": return "Pound"
        case "JPY": return "Yen"
        case "AUD": return "Australian Dollar"
        case "CAD": return "Canadian Dollar"
        case "CHF": return "Swiss Franc"
        case "NZD": return "New Zealand Dollar"
        default:    return code
        }
    }
}
