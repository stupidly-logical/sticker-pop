import SwiftUI

/// Shows a PIN or one-time code being typed: a row of `length` boxes (48 ×
/// 56, radius 14). Filled boxes show an ink dot (`obscure`) or the digit;
/// the next box has a 2.5 outline. With `error` the boxes turn orange and the
/// message shows below. Feed it from a `PopKeypad(decimal: false)`.
public struct PopPinField: View {
    let value: String
    var length: Int
    var obscure: Bool
    var error: String?
    var label: String

    public init(_ value: String, length: Int = 4, obscure: Bool = true, error: String? = nil, label: String = "PIN") {
        self.value = value
        self.length = length
        self.obscure = obscure
        self.error = error
        self.label = label
    }

    public var body: some View {
        let digits = Array(value)
        let bad = error != nil
        VStack(spacing: PopSpace.md) {
            HStack(spacing: PopSpace.sm) {
                ForEach(0..<length, id: \.self) { i in
                    ZStack {
                        if i < digits.count {
                            if obscure { Circle().fill(PopColors.ink).frame(width: 14, height: 14) }
                            else { PopText(String(digits[i]), PopTextSpecs.keypadKey) }
                        }
                    }
                    .frame(maxWidth: 48)
                    .frame(height: 56)
                    .sticker(fill: bad ? PopColors.orange : PopColors.white, radius: PopRadius.field,
                             border: !bad && i == digits.count ? PopBorder.regular : PopBorder.thin, shadow: 0)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue("\(digits.count) of \(length) entered")
            .animation(.easeOut(duration: PopMotion.toggle), value: bad)
            if let error { PopFormError(error) }
        }
    }
}
