// Date+Extensions.swift
// ForexMindGuard – Utilities/Extensions

import Foundation

extension Date {
    /// Formatted as "HH:mm:ss" – used for live price timestamps
    var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: self)
    }

    /// Formatted as "dd MMM, HH:mm" – used for news articles
    var newsDateString: String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM, HH:mm"
        return f.string(from: self)
    }

    /// Relative time string: "2 minutes ago", "Just now", etc.
    var relativeString: String {
        let interval = Date().timeIntervalSince(self)
        switch interval {
        case ..<5:      return "Just now"
        case 5..<60:    return "\(Int(interval))s ago"
        case 60..<3600: return "\(Int(interval/60))m ago"
        case 3600..<86400: return "\(Int(interval/3600))h ago"
        default:        return "\(Int(interval/86400))d ago"
        }
    }

    /// Formatted cooldown string "mm:ss"
    static func countdownString(from seconds: TimeInterval) -> String {
        let mins = Int(max(seconds, 0)) / 60
        let secs = Int(max(seconds, 0)) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    /// Returns date at start of current day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// London session: 08:00–17:00 UTC
    var isLondonSession: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return (8...17).contains(hour)
    }

    /// New York session: 13:00–22:00 UTC
    var isNewYorkSession: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return (13...22).contains(hour)
    }

    /// Tokyo session: 00:00–09:00 UTC
    var isTokyoSession: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return (0...9).contains(hour)
    }

    /// Returns session stress factor (higher during volatile overlap hours)
    var sessionStressFactor: Double {
        let hour = Calendar.current.component(.hour, from: self)
        // London-NY overlap 13:00-17:00 UTC is most volatile → higher factor
        switch hour {
        case 13...17: return 0.85   // London-NY overlap
        case 8...12:  return 0.65   // London open
        case 20...22: return 0.55   // NY close
        default:      return 0.35   // Off-peak
        }
    }
}
