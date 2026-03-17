// FaceTrackingService.swift
// ForexMindGuard – Core/Services/EmotionAI
//
// Uses ARKit's ARFaceTrackingConfiguration to capture facial blend shapes and
// map them to discrete emotion states.  Publishes the detected emotion via Combine.
//
// IMPORTANT: Requires a device with TrueDepth camera (iPhone X or later).
// The app must have NSCameraUsageDescription in Info.plist.

import Foundation
import ARKit
import Combine
import SwiftUI

// MARK: - Blend shape emotion mapping weights
private struct BlendShapeWeights {
    /// Stress / frustration: furrowed brow
    static let browDownLeft       = "browDownLeft"
    static let browDownRight      = "browDownRight"
    /// Fear / anxiety: raised inner brows
    static let browInnerUp        = "browInnerUp"
    /// Wide eyes (fear)
    static let eyeWideLeft        = "eyeWideLeft"
    static let eyeWideRight       = "eyeWideRight"
    /// Greed / happiness: smile
    static let mouthSmileLeft     = "mouthSmileLeft"
    static let mouthSmileRight    = "mouthSmileRight"
    /// Anger / stress: jaw clench (low jawOpen)
    static let jawOpen            = "jawOpen"
    /// Surprise / excitement
    static let browOuterUpLeft    = "browOuterUpLeft"
    static let browOuterUpRight   = "browOuterUpRight"
}

// MARK: - FaceTrackingService
final class FaceTrackingService: NSObject, ObservableObject, ARSessionDelegate {

    // MARK: Published
    @Published private(set) var detectedEmotion: EmotionState = .neutral
    @Published private(set) var facialFactor: Double = 0.0   // 0-1 stress contribution
    @Published private(set) var isTracking: Bool = false
    @Published private(set) var isSupported: Bool = ARFaceTrackingConfiguration.isSupported

    // MARK: Combine
    private let emotionSubject = PassthroughSubject<EmotionState, Never>()
    var publisher: AnyPublisher<EmotionState, Never> { emotionSubject.eraseToAnyPublisher() }

    // MARK: Private
    private var arSession: ARSession?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Start tracking
    func startTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("[FaceTracking] ARFaceTrackingConfiguration not supported on this device.")
            return
        }
        let config = ARFaceTrackingConfiguration()
        config.maximumNumberOfTrackedFaces = 1

        arSession = ARSession()
        arSession?.delegate = self
        arSession?.run(config, options: [.resetTracking, .removeExistingAnchors])
        DispatchQueue.main.async { self.isTracking = true }
    }

    // MARK: - Stop tracking
    func stopTracking() {
        arSession?.pause()
        arSession = nil
        DispatchQueue.main.async { self.isTracking = false }
    }

    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        let blendShapes = faceAnchor.blendShapes

        let emotion = mapBlendShapesToEmotion(blendShapes)
        let factor  = computeFacialStressFactor(blendShapes)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.detectedEmotion = emotion
            self.facialFactor = factor
            self.emotionSubject.send(emotion)
        }
    }

    // MARK: - Blend shape → emotion mapping
    private func mapBlendShapesToEmotion(_ bs: [ARFaceAnchor.BlendShapeLocation: NSNumber]) -> EmotionState {
        let browDown  = avg(bs[.browDownLeft], bs[.browDownRight])
        let browInner = value(bs[.browInnerUp])
        let eyeWide   = avg(bs[.eyeWideLeft], bs[.eyeWideRight])
        let smile     = avg(bs[.mouthSmileLeft], bs[.mouthSmileRight])
        let jawOpen   = value(bs[.jawOpen])
        let browOuter = avg(bs[.browOuterUpLeft], bs[.browOuterUpRight])

        // Score each emotion archetype
        var scores: [EmotionState: Double] = [
            .calm:    smile * 0.6 + (1 - browDown) * 0.4,
            .angry:   browDown * 0.6 + (1 - jawOpen) * 0.4,           // furrowed brow + jaw clench
            .fearful: eyeWide * 0.5 + browInner * 0.3 + browOuter * 0.2,
            .greedy:  smile * 0.8 + browOuter * 0.2,
            .stressed: browDown * 0.5 + (1 - jawOpen) * 0.3 + browInner * 0.2,
            .excited: browOuter * 0.5 + eyeWide * 0.3 + smile * 0.2,
            .anxious: browInner * 0.6 + eyeWide * 0.4,
            .neutral: 0.5  // baseline
        ]

        // Normalise and pick winner
        return scores.max(by: { $0.value < $1.value })?.key ?? .neutral
    }

    /// Composite facial stress contribution (0-1)
    private func computeFacialStressFactor(_ bs: [ARFaceAnchor.BlendShapeLocation: NSNumber]) -> Double {
        let browDown  = avg(bs[.browDownLeft], bs[.browDownRight])
        let eyeWide   = avg(bs[.eyeWideLeft], bs[.eyeWideRight])
        let jawTension = 1.0 - value(bs[.jawOpen])  // High tension = closed jaw
        let browInner = value(bs[.browInnerUp])
        return (browDown * 0.35 + eyeWide * 0.25 + jawTension * 0.25 + browInner * 0.15).clamped(to: 0...1)
    }

    // MARK: - Helpers
    private func value(_ n: NSNumber?) -> Double { Double(truncating: n ?? 0) }
    private func avg(_ a: NSNumber?, _ b: NSNumber?) -> Double { (value(a) + value(b)) / 2 }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double { min(max(self, range.lowerBound), range.upperBound) }
}
