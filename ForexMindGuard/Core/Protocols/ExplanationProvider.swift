// ExplanationProvider.swift
// ForexMindGuard – Protocols
//
// Protocol for AI explanation services (real OpenAI or mock).

import Foundation
import Combine

/// Generates a plain-English explanation for a price movement.
protocol ExplanationProvider: AnyObject {
    /// Asynchronously generate an explanation for the given movement.
    /// - Parameter movement: The price movement to explain.
    /// - Returns: A NewsExplanation with AI-generated content.
    func explain(_ movement: PriceMovement) async throws -> NewsExplanation

    /// Publisher emitting new explanations as they are generated.
    var explanationPublisher: AnyPublisher<NewsExplanation, Never> { get }
}
