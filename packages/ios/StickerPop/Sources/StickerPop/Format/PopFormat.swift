import Foundation

/// Content formats from the Sticker Pop spec: Indian rupees with Indian digit
/// grouping, compact amounts, and short dates and times. Amounts are `Int64`
/// paise, never floating point. Output matches every other platform
/// (`parity/format-cases.json`).
public enum PopFormat {
    private static let minus = "\u{2212}" // −, a real minus sign

    /// How `formatInr` marks direction.
    public enum Sign: Sendable {
        /// Only negatives get a sign (−).
        case auto
        /// Money in gets "+", money out gets "−".
        case always
        /// No sign, even for negatives.
        case none
    }

    /// Groups digits the Indian way: 1,25,000 and 12,34,56,789.
    public static func groupIndian(_ value: Int64) -> String {
        let digits = String(value.magnitude)
        guard digits.count > 3 else { return digits }
        let last3 = String(digits.suffix(3))
        var rest = String(digits.dropLast(3))
        var parts: [String] = []
        while rest.count > 2 {
            parts.insert(String(rest.suffix(2)), at: 0)
            rest = String(rest.dropLast(2))
        }
        if !rest.isEmpty { parts.insert(rest, at: 0) }
        return parts.joined(separator: ",") + "," + last3
    }

    /// ₹1,25,000 or ₹1,250.50. Paise show only when non-zero, unless `alwaysPaise`.
    public static func formatInr(_ paise: Int64, sign: Sign = .auto, alwaysPaise: Bool = false) -> String {
        let magnitude = Int64(paise.magnitude)
        let rupees = magnitude / 100
        let rem = magnitude % 100
        let body: String
        if rem != 0 || alwaysPaise {
            body = groupIndian(rupees) + "." + (rem < 10 ? "0\(rem)" : "\(rem)")
        } else {
            body = groupIndian(rupees)
        }
        return signFor(paise, sign) + "₹" + body
    }

    /// ₹950, ₹51.2k, ₹1.25L, ₹2.1Cr: at most three significant figures.
    public static func formatInrCompact(_ paise: Int64, sign: Sign = .auto) -> String {
        let rupees = Double(paise.magnitude) / 100
        let body: String
        if rupees >= 1e7 {
            body = trim(rupees / 1e7) + "Cr"
        } else if rupees >= 1e5 {
            body = trim(rupees / 1e5) + "L"
        } else if rupees >= 1e3 {
            body = trim(rupees / 1e3) + "k"
        } else {
            body = groupIndian(Int64(rupees.rounded()))
        }
        return signFor(paise, sign) + "₹" + body
    }

    private static func signFor(_ paise: Int64, _ sign: Sign) -> String {
        switch sign {
        case .none: return ""
        case .auto: return paise < 0 ? minus : ""
        case .always: return paise < 0 ? minus : (paise > 0 ? "+" : "")
        }
    }

    private static func trim(_ v: Double) -> String {
        let decimals = v >= 100 ? 0 : (v >= 10 ? 1 : 2)
        var s = String(format: "%.\(decimals)f", locale: Locale(identifier: "en_US_POSIX"), v)
        if s.contains(".") {
            while s.hasSuffix("0") { s.removeLast() }
            if s.hasSuffix(".") { s.removeLast() }
        }
        return s
    }

    private static let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    /// "Today", "Yesterday", or "18 Nov 2026", in `calendar`'s time zone.
    public static func formatPopDate(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now)).day ?? 0
        if days == 0 { return "Today" }
        if days == 1 { return "Yesterday" }
        let c = calendar.dateComponents([.day, .month, .year], from: date)
        return "\(c.day!) \(months[c.month! - 1]) \(c.year!)"
    }

    /// "Nov 2026".
    public static func formatPopMonth(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.month, .year], from: date)
        return "\(months[c.month! - 1]) \(c.year!)"
    }

    /// 12-hour time: "1:12 pm", "9:05 am", "12:00 pm".
    public static func formatPopTime(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.hour, .minute], from: date)
        let hour = c.hour!, minute = c.minute!
        let h = hour % 12 == 0 ? 12 : hour % 12
        return "\(h):\(minute < 10 ? "0\(minute)" : "\(minute)") \(hour < 12 ? "am" : "pm")"
    }
}
