// HeartRateService.swift
// ForexMindGuard – Core/Services/EmotionAI
//
// Reads real-time heart rate (and HRV) from HealthKit using HKAnchoredObjectQuery
// for live updates. Publishes readings via Combine for downstream stress calculation.

import Foundation
import HealthKit
import Combine

// MARK: - Custom errors
enum HeartRateServiceError: LocalizedError {
    case healthKitNotAvailable
    case authorizationDenied
    case queryFailed(Error)

    var errorDescription: String? {
        switch self {
        case .healthKitNotAvailable: return "HealthKit is not available on this device."
        case .authorizationDenied:   return "Heart rate access was denied. Enable it in Settings > Privacy > Health."
        case .queryFailed(let e):    return "Heart rate query failed: \(e.localizedDescription)"
        }
    }
}

// MARK: - HeartRateService
final class HeartRateService: ObservableObject {

    // MARK: Published state
    @Published private(set) var latestReading: HeartRateReading?
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var error: HeartRateServiceError?
    @Published private(set) var isMonitoring: Bool = false

    // MARK: Combine
    private let heartRateSubject = PassthroughSubject<HeartRateReading, Never>()
    var publisher: AnyPublisher<HeartRateReading, Never> { heartRateSubject.eraseToAnyPublisher() }

    // MARK: Private
    private let healthStore = HKHealthStore()
    private var anchoredQuery: HKAnchoredObjectQuery?
    private var anchor: HKQueryAnchor?

    private let heartRateType   = HKObjectType.quantityType(forIdentifier: .heartRate)!
    private let hrvType         = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)

    // MARK: - Authorization
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run { self.error = .healthKitNotAvailable }
            return
        }
        var typesToRead: Set<HKObjectType> = [heartRateType]
        if let hrv = hrvType { typesToRead.insert(hrv) }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            await MainActor.run { self.isAuthorized = true }
        } catch {
            await MainActor.run { self.error = .authorizationDenied }
        }
    }

    // MARK: - Start monitoring
    func startMonitoring() {
        guard isAuthorized else { return }
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-60),  // Last 60s to seed initial value
            end: nil,
            options: .strictStartDate
        )

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, error in
            self?.anchor = newAnchor
            if let error { self?.handleQueryError(error); return }
            self?.process(samples: samples)
        }

        // Update handler fires when new heart rate data arrives
        query.updateHandler = { [weak self] _, samples, _, newAnchor, error in
            self?.anchor = newAnchor
            if let error { self?.handleQueryError(error); return }
            self?.process(samples: samples)
        }

        healthStore.execute(query)
        anchoredQuery = query
        DispatchQueue.main.async { self.isMonitoring = true }
    }

    // MARK: - Stop monitoring
    func stopMonitoring() {
        if let query = anchoredQuery { healthStore.stop(query) }
        anchoredQuery = nil
        DispatchQueue.main.async { self.isMonitoring = false }
    }

    // MARK: - Process HealthKit samples
    private func process(samples: [HKSample]?) {
        guard let quantities = samples as? [HKQuantitySample], !quantities.isEmpty else { return }

        // Take the most recent reading
        let sorted = quantities.sorted { $0.startDate < $1.startDate }
        guard let latest = sorted.last else { return }

        let bpm = latest.quantity.doubleValue(for: .init(from: "count/min"))
        let reading = HeartRateReading(
            bpm: bpm,
            timestamp: latest.startDate,
            source: .healthKit
        )

        DispatchQueue.main.async { [weak self] in
            self?.latestReading = reading
            self?.heartRateSubject.send(reading)
        }
    }

    private func handleQueryError(_ error: Error) {
        DispatchQueue.main.async { self.error = .queryFailed(error) }
    }
}

// MARK: - Mock implementation for SwiftUI previews
final class MockHeartRateService: ObservableObject {
    @Published var latestReading: HeartRateReading? = .sample
    @Published var isAuthorized: Bool = true
    @Published var isMonitoring: Bool = true

    func startMonitoring() {}
    func stopMonitoring() {}
}
