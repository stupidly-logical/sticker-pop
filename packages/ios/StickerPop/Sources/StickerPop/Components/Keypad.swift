import SwiftUI

/// Applies one keypad key ("0"–"9", "." or "⌫") to an amount being typed:
/// one decimal point, at most `decimals` decimal places, no leading zeros,
/// at most `maxDigits` digits before the point.
public func applyPopKey(_ current: String, _ key: String, decimals: Int = 2, maxDigits: Int = 9) -> String {
    if key == "⌫" { return String(current.dropLast()) }
    if key == "." { return decimals == 0 || current.contains(".") ? current : (current.isEmpty ? "0." : current + ".") }
    guard key.count == 1, key.first!.isNumber else { return current }
    if let dot = current.firstIndex(of: ".") {
        if current.distance(from: dot, to: current.endIndex) - 1 >= decimals { return current }
    } else {
        let digits = current.hasPrefix("0") ? String(current.dropFirst()) : current
        if digits.count >= maxDigits { return current }
    }
    if current == "0" { return key }
    return current + key
}

/// A number keypad for entering amounts, in place of the system keyboard: a
/// 3 × 4 grid of white sticker keys (1–9, ".", 0, backspace) with 26/800
/// digits, 56 high, 3/3 shadow. Combine with `applyPopKey`.
public struct PopKeypad: View {
    let onKey: (String) -> Void
    var decimal: Bool

    public init(decimal: Bool = true, onKey: @escaping (String) -> Void) {
        self.decimal = decimal
        self.onKey = onKey
    }

    private let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], [".", "0", "⌫"]]

    public var body: some View {
        VStack(spacing: PopSpace.sm) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: PopSpace.sm) {
                    ForEach(row, id: \.self) { k in
                        if k == "." && !decimal {
                            Color.clear.frame(maxWidth: .infinity).frame(height: PopSize.keypadKey)
                        } else {
                            Button { onKey(k) } label: {
                                Group {
                                    if k == "⌫" {
                                        Image(systemName: "delete.left").font(.system(size: 22, weight: .bold)).foregroundStyle(PopColors.ink)
                                    } else {
                                        PopText(k, PopTextSpecs.keypadKey)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: PopSize.keypadKey)
                                .sticker(fill: PopColors.white, radius: PopRadius.tile, border: PopBorder.thin, shadow: PopShadow.small)
                            }
                            .buttonStyle(PopPressStyle(offset: PopShadow.small))
                            .accessibilityLabel(k == "⌫" ? "Delete" : k == "." ? "Decimal point" : k)
                        }
                    }
                }
            }
        }
        .padding(.trailing, PopShadow.small)
        .padding(.bottom, PopShadow.small)
    }
}
