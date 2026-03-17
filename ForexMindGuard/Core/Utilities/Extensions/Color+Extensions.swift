// Color+Extensions.swift
// ForexMindGuard – Utilities/Extensions
//
// Custom app color palette matching the dark trading theme.

import SwiftUI

// MARK: - App color palette
enum AppColors {
    /// Deep navy – primary background
    static let deepNavy       = Color(hex: "#0A1628")
    /// Dark charcoal – secondary background / card background
    static let darkCharcoal   = Color(hex: "#1A1A2E")
    /// Electric blue – emotion / info accent
    static let electricBlue   = Color(hex: "#00D4FF")
    /// Neon green – bullish / positive
    static let neonGreen      = Color(hex: "#00FF88")
    /// Danger red – bearish / negative / warning
    static let dangerRed      = Color(hex: "#FF3B3B")
    /// Gold – neutral / informational
    static let warmGold       = Color(hex: "#FFB800")
    /// Muted text colour
    static let mutedText      = Color(hex: "#8892A4")
    /// Card border colour
    static let cardBorder     = Color(hex: "#2A3448")
}

// MARK: - Stress score gradient
extension AppColors {
    /// Returns a gradient color for a stress score 0-100
    static func stressColor(for score: Double) -> Color {
        switch score {
        case ..<40:   return neonGreen
        case 40..<60: return warmGold
        case 60..<75: return .orange
        case 75..<85: return Color(hex: "#FF6B35")
        default:      return dangerRed
        }
    }

    /// Full gradient for the stress gauge
    static let stressGradient = LinearGradient(
        colors: [neonGreen, warmGold, .orange, dangerRed],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Color from hex string
extension Color {
    /// Initialises a SwiftUI Color from a hex string (e.g. "#00D4FF" or "00D4FF").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
