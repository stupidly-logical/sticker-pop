import SwiftUI

/// One slice, bar or legend entry.
public struct PopDatum: Identifiable {
    public let id = UUID()
    public let label: String
    public let value: Double
    public let color: Color
    public init(_ label: String, value: Double, color: Color) {
        self.label = label
        self.value = value
        self.color = color
    }
}

/// One donut slice as an annular sector.
struct DonutSlice: Shape {
    var start: Angle
    var end: Angle
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2 - PopBorder.regular / 2
        let inner = outer - thickness
        var p = Path()
        p.addArc(center: c, radius: outer, startAngle: start, endAngle: end, clockwise: false)
        p.addArc(center: c, radius: inner, startAngle: end, endAngle: start, clockwise: true)
        p.closeSubpath()
        return p
    }
}

/// Donut: one bright per slice, each outlined in 2.5 ink, around a yellow centre disc.
public struct PopDonut<Center: View>: View {
    let data: [PopDatum]
    let label: String
    var size: CGFloat
    var thickness: CGFloat
    let center: Center

    public init(_ data: [PopDatum], label: String, size: CGFloat = 180, thickness: CGFloat = 38,
                @ViewBuilder center: () -> Center) {
        self.data = data
        self.label = label
        self.size = size
        self.thickness = thickness
        self.center = center()
    }

    public var body: some View {
        let total = data.reduce(0) { $0 + $1.value }
        let disc = size - (thickness + 8 + PopBorder.regular) * 2
        ZStack {
            if total > 0 {
                ForEach(Array(data.enumerated()), id: \.element.id) { i, d in
                    let before = data.prefix(i).reduce(0) { $0 + $1.value }
                    let start = Angle.degrees(before / total * 360 - 90)
                    let end = Angle.degrees((before + d.value) / total * 360 - 90)
                    DonutSlice(start: start, end: end, thickness: thickness).fill(d.color)
                    DonutSlice(start: start, end: end, thickness: thickness).stroke(PopColors.ink, lineWidth: PopBorder.regular)
                }
            } else {
                Circle().fill(PopColors.white).overlay(Circle().stroke(PopColors.ink, lineWidth: PopBorder.regular))
            }
            Circle().fill(PopColors.yellow).overlay(Circle().stroke(PopColors.ink, lineWidth: PopBorder.regular))
                .frame(width: disc, height: disc)
            center
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }
}

extension PopDonut where Center == EmptyView {
    public init(_ data: [PopDatum], label: String, size: CGFloat = 180, thickness: CGFloat = 38) {
        self.init(data, label: label, size: size, thickness: thickness) { EmptyView() }
    }
}

/// Vertical bars, bright fills, ink outlines, no gridlines. The bar at
/// `highlightIndex` gets a heavier outline and a 2/2 shadow, so emphasis
/// doesn't rely on colour.
public struct PopBarChart: View {
    let data: [PopDatum]
    let label: String
    var height: CGFloat
    var highlightIndex: Int?

    public init(_ data: [PopDatum], label: String, height: CGFloat = 140, highlightIndex: Int? = nil) {
        self.data = data
        self.label = label
        self.height = height
        self.highlightIndex = highlightIndex
    }

    public var body: some View {
        let maxValue = data.map(\.value).max() ?? 0
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.element.id) { i, d in
                let on = i == highlightIndex
                let shape = UnevenTopRoundedRectangle(radius: 8)
                VStack(spacing: 6) {
                    shape.fill(d.color)
                        .overlay(shape.stroke(PopColors.ink, lineWidth: on ? 3 : PopBorder.thin))
                        .background(shape.fill(PopColors.ink).offset(x: on ? PopShadow.chip : 0, y: on ? PopShadow.chip : 0).opacity(on ? 1 : 0))
                        .frame(height: maxValue == 0 ? 4 : max(4, d.value / maxValue * height))
                    PopText(d.label, on ? PopTextSpecs.navLabelSelected : PopTextSpecs.navLabel).lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }
}

/// A rectangle with rounded top corners (works on iOS 16).
struct UnevenTopRoundedRectangle: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let r = min(radius, rect.height / 2, rect.width / 2)
        return TopRoundedShape(radius: r).path(in: rect)
    }
}

/// Legend: 12 square swatches (1.5 outline, radius 4), label 14/700, percentage 14/800 tabular.
public struct PopLegend: View {
    let data: [PopDatum]
    public init(_ data: [PopDatum]) { self.data = data }

    public var body: some View {
        let total = data.reduce(0) { $0 + $1.value }
        VStack(alignment: .leading, spacing: PopSpace.sm) {
            ForEach(data) { d in
                HStack(spacing: PopSpace.sm) {
                    RoundedRectangle(cornerRadius: PopRadius.swatch).fill(d.color)
                        .overlay(RoundedRectangle(cornerRadius: PopRadius.swatch).stroke(PopColors.ink, lineWidth: PopBorder.swatch))
                        .frame(width: PopSize.swatch, height: PopSize.swatch)
                    PopText(d.label, PopTextSpecs.legendLabel)
                    Spacer()
                    PopText("\(total == 0 ? 0 : Int((d.value / total * 100).rounded()))%", PopTextSpecs.legendValue)
                }
            }
        }
    }
}
