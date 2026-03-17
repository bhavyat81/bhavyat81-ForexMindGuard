// ForexAPIClient.swift
// ForexMindGuard – Core/Services/MarketData
//
// REST API client for historical forex data.
// Supports multiple providers: Alpha Vantage, TraderMade.

import Foundation

// MARK: - API errors
enum ForexAPIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "Invalid API URL"
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .decodingError(let e): return "Decoding error: \(e.localizedDescription)"
        case .apiError(let msg):  return "API error: \(msg)"
        case .rateLimited:        return "API rate limit reached. Try again later."
        }
    }
}

// MARK: - Historical candle
struct OHLCCandle: Decodable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double?

    var midClose: Double { close }
    var range: Double { high - low }
    var isBullish: Bool { close >= open }
}

// MARK: - ForexAPIClient
final class ForexAPIClient {

    static let shared = ForexAPIClient()
    private init() {}

    private let session = URLSession.shared

    // MARK: - Fetch historical candles
    /// Fetches OHLC historical data for a currency pair.
    /// - Parameters:
    ///   - pair: e.g. "EURUSD"
    ///   - interval: e.g. "15min", "1hour", "daily"
    ///   - outputSize: number of candles
    func fetchCandles(pair: String, interval: String = "15min", outputSize: Int = 100) async throws -> [OHLCCandle] {
        // Alpha Vantage FX_INTRADAY endpoint
        let urlString = "\(APIEndpoints.alphaVantageBase)?function=FX_INTRADAY&from_symbol=\(pair.prefix(3))&to_symbol=\(pair.suffix(3))&interval=\(interval)&outputsize=compact&apikey=\(APIKeys.alphaVantage)"

        guard let url = URL(string: urlString) else { throw ForexAPIError.invalidURL }

        let (data, _): (Data, URLResponse)
        do {
            (data, _) = try await session.data(from: url)
        } catch {
            throw ForexAPIError.networkError(error)
        }

        // Alpha Vantage returns a JSON structure – parse "Time Series FX (15min)"
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let seriesKey = json.keys.first(where: { $0.hasPrefix("Time Series") }),
              let series = json[seriesKey] as? [String: [String: String]] else {
            // Check for error note
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let note = json["Note"] as? String, note.contains("frequency") {
                throw ForexAPIError.rateLimited
            }
            throw ForexAPIError.decodingError(NSError(domain: "parse", code: 0))
        }

        let formatter = ISO8601DateFormatter()
        let candles: [OHLCCandle] = series.compactMap { dateStr, values in
            guard let date = formatter.date(from: dateStr),
                  let open  = Double(values["1. open"]  ?? ""),
                  let high  = Double(values["2. high"]  ?? ""),
                  let low   = Double(values["3. low"]   ?? ""),
                  let close = Double(values["4. close"] ?? "") else { return nil }
            return OHLCCandle(timestamp: date, open: open, high: high, low: low, close: close, volume: nil)
        }
        .sorted { $0.timestamp < $1.timestamp }

        return Array(candles.suffix(outputSize))
    }

    // MARK: - Fetch current quote (REST fallback when WebSocket is unavailable)
    func fetchQuote(pair: String) async throws -> ForexPair {
        let urlString = "\(APIEndpoints.alphaVantageBase)?function=CURRENCY_EXCHANGE_RATE&from_currency=\(pair.prefix(3))&to_currency=\(pair.suffix(3))&apikey=\(APIKeys.alphaVantage)"
        guard let url = URL(string: urlString) else { throw ForexAPIError.invalidURL }

        let (data, _) = try await session.data(from: url)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rate = json["Realtime Currency Exchange Rate"] as? [String: String],
              let bidStr = rate["8. Bid Price"],
              let askStr = rate["9. Ask Price"],
              let bid = Double(bidStr),
              let ask = Double(askStr) else {
            throw ForexAPIError.decodingError(NSError(domain: "parse", code: 0))
        }

        return ForexPair(
            base:  String(pair.prefix(3)),
            quote: String(pair.suffix(3)),
            bid: bid,
            ask: ask
        )
    }
}
