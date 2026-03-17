// Double+Extensions.swift
// ForexMindGuard – Utilities/Extensions
//
// Formatting helpers for forex prices, pip calculations, and percentages.

import Foundation

extension Double {
    // MARK: - Pip calculations

    /// Convert a price difference to pips for a given pair.
    /// - Parameter isJPY: True for JPY pairs (multiplier = 100, not 10000)
    func toPips(isJPY: Bool = false) -> Double {
        return self * (isJPY ? 100 : 10_000)
    }

    /// Convert pips back to price difference.
    func fromPips(isJPY: Bool = false) -> Double {
        return self / (isJPY ? 100 : 10_000)
    }

    // MARK: - Formatting

    /// Format as forex price (5 decimals for normal, 3 for JPY pairs)
    func asForexPrice(isJPY: Bool = false) -> String {
        String(format: isJPY ? "%.3f" : "%.5f", self)
    }

    /// Format as percentage with sign
    func asPercentWithSign(decimals: Int = 2) -> String {
        let prefix = self >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.\(decimals)f", self))%"
    }

    /// Format as pips with sign
    func asPipsWithSign() -> String {
        let prefix = self >= 0 ? "+" : ""
        return "\(prefix)\(Int(self)) pips"
    }

    /// Clamp between min and max
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }

    /// Round to specific decimal places
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// Normalize 0-1 from a given range
    func normalized(min: Double, max: Double) -> Double {
        guard max != min else { return 0 }
        return ((self - min) / (max - min)).clamped(to: 0...1)
    }

    /// Format as BPM e.g. "88 BPM"
    var asBPM: String { "\(Int(self)) BPM" }

    /// Format stress score as percentage
    var asStressPercent: String { String(format: "%.0f", self) }
}
