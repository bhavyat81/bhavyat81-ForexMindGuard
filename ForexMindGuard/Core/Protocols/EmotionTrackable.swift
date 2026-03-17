// EmotionTrackable.swift
// ForexMindGuard – Protocols
//
// Protocol that any emotion data source (FaceTracking, HeartRate, etc.) must conform to.

import Foundation
import Combine

/// An object that can produce a stream of EmotionSnapshots.
protocol EmotionTrackable: AnyObject {
    /// Publisher emitting the latest emotion snapshot.
    var emotionPublisher: AnyPublisher<EmotionSnapshot, Never> { get }

    /// Start capturing emotion data.
    func startTracking()

    /// Stop capturing emotion data.
    func stopTracking()

    /// Whether the service is currently active.
    var isTracking: Bool { get }
}
