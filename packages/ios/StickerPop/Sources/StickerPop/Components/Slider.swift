import SwiftUI

/// A slider for picking a number in a range, like a budget limit: a white
/// track 18 high with a 2 ink outline, filled mint (or `fill`) up to a 28
/// white sticker knob with a 3/3 shadow. Drag or tap to set it; VoiceOver
/// swipes step it by `step` (default: 1/20 of the range).
public struct PopSlider: View {
    @Binding var value: Double
    let label: String
    var range: ClosedRange<Double>
    var step: Double?
    var fill: Color
    var valueLabel: (Double) -> String
    @Environment(\.isEnabled) private var enabled

    public init(_ label: String, value: Binding<Double>, in range: ClosedRange<Double> = 0...1, step: Double? = nil,
                fill: Color = PopColors.mint, valueLabel: @escaping (Double) -> String = { String(format: $0.rounded() == $0 ? "%.0f" : "%.1f", $0) }) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.fill = fill
        self.valueLabel = valueLabel
    }

    private var span: Double { range.upperBound - range.lowerBound }
    private func snap(_ v: Double) -> Double {
        var x = min(max(v, range.lowerBound), range.upperBound)
        if let step, step > 0 { x = min(max(range.lowerBound + ((x - range.lowerBound) / step).rounded() * step, range.lowerBound), range.upperBound) }
        return x
    }

    public var body: some View {
        GeometryReader { geo in
            let knob = PopSize.sliderKnob
            let t = span == 0 ? 0 : (value - range.lowerBound) / span
            let x = CGFloat(t) * (geo.size.width - knob)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: PopRadius.progressTrack)
                    .fill(enabled ? PopColors.white : PopColors.paper)
                    .overlay(alignment: .leading) {
                        Rectangle().fill(enabled ? fill : PopColors.divider).frame(width: x + PopSize.progressBar / 2)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: PopRadius.progressTrack))
                    .overlay(RoundedRectangle(cornerRadius: PopRadius.progressTrack).strokeBorder(PopColors.ink, lineWidth: PopBorder.thin))
                    .frame(height: PopSize.progressBar)
                    .padding(.horizontal, knob / 2 - PopSize.progressBar / 2)
                Circle().fill(PopColors.white)
                    .overlay(Circle().strokeBorder(PopColors.ink, lineWidth: PopBorder.regular))
                    .background(Circle().fill(PopColors.ink).offset(x: PopShadow.small, y: PopShadow.small).opacity(enabled ? 1 : 0))
                    .frame(width: knob, height: knob)
                    .offset(x: x)
            }
            .frame(height: PopSize.tapTarget)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { g in
                guard enabled else { return }
                let tt = (g.location.x - knob / 2) / (geo.size.width - knob)
                value = snap(range.lowerBound + Double(min(max(tt, 0), 1)) * span)
            })
        }
        .frame(height: PopSize.tapTarget)
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue(valueLabel(value))
        .accessibilityAdjustableAction { direction in
            let s = step ?? span / 20
            switch direction {
            case .increment: value = snap(value + s)
            case .decrement: value = snap(value - s)
            @unknown default: break
            }
        }
    }
}
