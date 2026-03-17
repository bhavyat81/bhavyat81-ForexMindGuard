// EmotionClassifier.swift
// ForexMindGuard – Core/Services/EmotionAI
//
// CoreML model wrapper that combines facial blend shape features + heart rate
// to produce a classified EmotionState.
//
// TODO: Train and export a real CoreML model (EmotionClassifier.mlmodel).
//       Until then, the rule-based classifier is used as a fallback.

import Foundation
import CoreML
import Combine

// MARK: - EmotionClassifier
final class EmotionClassifier: ObservableObject {

    @Published private(set) var classifiedEmotion: EmotionState = .neutral
    @Published private(set) var isModelLoaded: Bool = false

    // TODO: Load real EmotionClassifier.mlmodel
    // private var model: EmotionClassifierModel?

    init() {
        loadModel()
    }

    // MARK: - Load CoreML model
    private func loadModel() {
        // TODO: Replace with actual MLModel loading:
        // guard let url = Bundle.main.url(forResource: "EmotionClassifier", withExtension: "mlmodelc"),
        //       let model = try? EmotionClassifierModel(contentsOf: url) else {
        //     print("[EmotionClassifier] CoreML model not found — using rule-based fallback")
        //     return
        // }
        // self.model = model
        print("[EmotionClassifier] Using rule-based emotion classifier (CoreML model not loaded)")
        isModelLoaded = false
    }

    // MARK: - Classify
    /// Classify emotion from blend shape features and heart rate.
    /// Falls back to rule-based logic until a real CoreML model is available.
    func classify(
        facialFactor: Double,
        heartRateFactor: Double,
        behavioralFactor: Double
    ) -> EmotionState {
        // TODO: Route through CoreML model:
        // let input = EmotionClassifierInput(
        //     facialFactor: facialFactor,
        //     heartRateFactor: heartRateFactor,
        //     behavioralFactor: behavioralFactor
        // )
        // if let output = try? model?.prediction(input: input) {
        //     return EmotionState(rawValue: output.emotion) ?? ruleBasedClassify(...)
        // }

        // Rule-based fallback
        return ruleBasedClassify(
            facialFactor: facialFactor,
            heartRateFactor: heartRateFactor,
            behavioralFactor: behavioralFactor
        )
    }

    // MARK: - Rule-based fallback
    private func ruleBasedClassify(
        facialFactor: Double,
        heartRateFactor: Double,
        behavioralFactor: Double
    ) -> EmotionState {
        let composite = heartRateFactor * 0.4 + facialFactor * 0.4 + behavioralFactor * 0.2

        switch composite {
        case ..<0.2:  return .calm
        case 0.2..<0.35: return .neutral
        case 0.35..<0.50: return .anxious
        case 0.50..<0.65: return .stressed
        case 0.65..<0.78: return .fearful
        case 0.78..<0.88: return .angry
        default: return .angry
        }
    }
}
