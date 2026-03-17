// HeartRateMonitorView.swift
// ForexMindGuardWatch
//
// Live heart rate display on Apple Watch.

import SwiftUI
import HealthKit

struct HeartRateMonitorView: View {

    @EnvironmentObject var connectivity: WatchConnectivityService
    @StateObject private var heartRateVM = WatchHeartRateViewModel()

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.system(size: 30))
                .foregroundStyle(.red)
                .symbolEffect(.pulse.byLayer, isActive: heartRateVM.isMonitoring)

            Text("\(Int(heartRateVM.currentBPM))")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(heartRateVM.isElevated ? .red : .white)
                .contentTransition(.numericText())
                .animation(.easeInOut, value: heartRateVM.currentBPM)

            Text("BPM")
                .font(.caption2)
                .foregroundStyle(.secondary)

            if heartRateVM.isElevated {
                Text("⚡ ELEVATED")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.red)
            }

            Button(heartRateVM.isMonitoring ? "Stop" : "Monitor") {
                heartRateVM.isMonitoring ? heartRateVM.stop() : heartRateVM.start()
            }
            .buttonStyle(.borderedProminent)
            .tint(heartRateVM.isMonitoring ? .red : .green)
            .font(.caption2)
        }
        .navigationTitle("Heart Rate")
        .onAppear { heartRateVM.start() }
    }
}

// MARK: - Watch heart rate view model
final class WatchHeartRateViewModel: ObservableObject {
    @Published var currentBPM: Double = 0
    @Published var isMonitoring: Bool = false
    @Published var isElevated: Bool = false

    private let healthStore = HKHealthStore()
    private var query: HKAnchoredObjectQuery?

    func start() {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-30), end: nil)

        let q = HKAnchoredObjectQuery(
            type: hrType, predicate: predicate,
            anchor: nil, limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.process(samples)
        }
        q.updateHandler = { [weak self] _, samples, _, _, _ in self?.process(samples) }
        healthStore.execute(q)
        query = q
        DispatchQueue.main.async { self.isMonitoring = true }
    }

    func stop() {
        if let q = query { healthStore.stop(q) }
        DispatchQueue.main.async { self.isMonitoring = false }
    }

    private func process(_ samples: [HKSample]?) {
        guard let q = samples as? [HKQuantitySample], let last = q.last else { return }
        let bpm = last.quantity.doubleValue(for: .init(from: "count/min"))
        DispatchQueue.main.async {
            self.currentBPM = bpm
            self.isElevated = bpm > 100
        }
        WatchConnectivityService.shared.sendHeartRate(bpm: bpm)
    }
}

#Preview {
    HeartRateMonitorView()
        .environmentObject(WatchConnectivityService.shared)
}
