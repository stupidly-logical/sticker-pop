import SwiftUI

/// A small counter, like how many people split a bill: − and + sticker
/// buttons with the number between them in 20/800. Each button disables at
/// its limit; VoiceOver adjusts it as one control.
public struct PopStepper: View {
    let label: String
    @Binding var value: Int
    var range: ClosedRange<Int>
    var step: Int

    public init(_ label: String, value: Binding<Int>, in range: ClosedRange<Int> = 0...99, step: Int = 1) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
    }

    public var body: some View {
        HStack(spacing: 0) {
            PopIconButton(systemImage: "minus", label: "Less") { value -= step }.disabled(value - step < range.lowerBound)
            PopText("\(value)", PopTextSpecs.sectionHeading).monospacedDigit().frame(minWidth: 48)
            PopIconButton(systemImage: "plus", label: "More") { value += step }.disabled(value + step > range.upperBound)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(value)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: if value + step <= range.upperBound { value += step }
            case .decrement: if value - step >= range.lowerBound { value -= step }
            @unknown default: break
            }
        }
    }
}
