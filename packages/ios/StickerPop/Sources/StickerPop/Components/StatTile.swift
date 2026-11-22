import SwiftUI

/// Which way a `PopStatTile`'s change went, and whether that's good.
public enum PopTrend {
    case upGood, upBad, downGood, downBad
}

/// A headline number on a dashboard: a 13/800 caps label, a 28/800 tabular
/// figure, an optional change badge ("+12.4%", mint when good, orange when
/// not) and an optional caption. A StickerCard, white by default.
public struct PopStatTile: View {
    let label: String
    let value: String
    var change: String?
    var trend: PopTrend
    var caption: String?
    var fill: Color

    public init(_ label: String, value: String, change: String? = nil, trend: PopTrend = .upGood, caption: String? = nil, fill: Color = PopColors.white) {
        self.label = label
        self.value = value
        self.change = change
        self.trend = trend
        self.caption = caption
        self.fill = fill
    }

    public var body: some View {
        let up = trend == .upGood || trend == .upBad
        let good = trend == .upGood || trend == .downGood
        StickerCard(fill: fill) {
            VStack(alignment: .leading, spacing: PopSpace.xs) {
                PopText(label, PopTextSpecs.sectionLabel)
                PopText(value, PopTextSpecs.cardFigure)
                if let change { StickerBadge((up ? "+" : "−") + change, fill: good ? PopColors.mint : PopColors.orange) }
                if let caption { PopText(caption, PopTextSpecs.caption) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([label, value, change.map { (up ? "up " : "down ") + $0 }, caption].compactMap { $0 }.joined(separator: ", "))
    }
}
