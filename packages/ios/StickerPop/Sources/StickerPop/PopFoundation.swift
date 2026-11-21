import CoreText
import SwiftUI

public enum StickerPopFonts {
    private static var registered = false

    /// Registers Bricolage Grotesque from the package bundle. Call once at
    /// launch (e.g. in your App's init). Safe to call again.
    public static func register() {
        guard !registered,
              let url = Bundle.module.url(forResource: "BricolageGrotesque-Variable", withExtension: "ttf")
        else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        registered = true
    }
}

extension Font {
    /// Bricolage Grotesque at `size` and a weight of 600–800. It scales with
    /// the system text size (Dynamic Type), like the other platforms do.
    public static func pop(_ size: CGFloat, weight: CGFloat) -> Font {
        let w: Font.Weight = weight >= 800 ? .heavy : (weight >= 700 ? .bold : .semibold)
        return .custom("Bricolage Grotesque", size: size, relativeTo: .body).weight(w)
    }
}

extension PopTextColor {
    var color: Color {
        switch self {
        case .ink: return PopColors.ink
        case .inkMuted: return PopColors.inkMuted
        case .white: return PopColors.white
        }
    }
}

/// Text in one role of the type scale.
public struct PopText: View {
    let text: String
    let spec: PopTextSpec
    var color: Color?

    public init(_ text: String, _ spec: PopTextSpec, color: Color? = nil) {
        self.text = text
        self.spec = spec
        self.color = color
    }

    public var body: some View {
        Text(spec.caps ? text.uppercased() : text)
            .font(.pop(spec.size, weight: spec.weight))
            .tracking(spec.letterSpacing)
            .monospacedDigit(spec.tabular)
            .foregroundStyle(color ?? spec.color.color)
            // Amounts (the tabular roles) never wrap: they shrink to fit.
            .lineLimit(spec.tabular ? 1 : nil)
            .minimumScaleFactor(spec.tabular ? 0.4 : 1)
            .accessibilityLabel(text)
    }
}

private extension View {
    @ViewBuilder func monospacedDigit(_ on: Bool) -> some View {
        if on { self.monospacedDigit() } else { self }
    }
}

/// Fill, ink outline and a solid, blur-free shadow offset down-right.
public struct StickerSurface: ViewModifier {
    var fill: Color
    var gradient: LinearGradient? = nil
    var radius: CGFloat
    var border: CGFloat = PopBorder.regular
    var shadow: CGFloat = PopShadow.regular
    var shadowColor: Color = PopColors.ink

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        // Fill behind, content clipped to the corners, outline on top.
        return content
            .background(gradient.map { AnyShapeStyle($0) } ?? AnyShapeStyle(fill), in: shape)
            .clipShape(shape)
            .overlay(shape.strokeBorder(PopColors.ink, lineWidth: border))
            .background(shape.fill(shadowColor).offset(x: shadow, y: shadow).opacity(shadow > 0 ? 1 : 0))
    }
}

extension View {
    public func sticker(
        fill: Color, radius: CGFloat, border: CGFloat = PopBorder.regular,
        shadow: CGFloat = PopShadow.regular, shadowColor: Color = PopColors.ink,
        gradient: LinearGradient? = nil
    ) -> some View {
        modifier(StickerSurface(fill: fill, gradient: gradient, radius: radius, border: border, shadow: shadow, shadowColor: shadowColor))
    }

    /// Tilts as if stuck on by hand. Clamped to ±6°.
    public func popTilt(_ degrees: CGFloat) -> some View {
        rotationEffect(.degrees(Double(min(max(degrees, -PopTilt.max), PopTilt.max))))
    }
}

/// Press feedback: the sticker moves by its shadow and the shadow goes.
/// No highlight, no ripple.
public struct PopPressStyle: ButtonStyle {
    var offset: CGFloat
    public init(offset: CGFloat = PopShadow.regular) { self.offset = offset }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(x: configuration.isPressed ? offset : 0, y: configuration.isPressed ? offset : 0)
            .environment(\.popPressed, configuration.isPressed)
    }
}

private struct PopPressedKey: EnvironmentKey { static let defaultValue = false }
extension EnvironmentValues {
    var popPressed: Bool {
        get { self[PopPressedKey.self] }
        set { self[PopPressedKey.self] = newValue }
    }
}

/// Cream paper with the dot grid.
public struct PaperBackground: View {
    public init() {}
    public var body: some View {
        Canvas { ctx, size in
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(PopColors.paper))
            let step = PopSize.paperDotStep, r = PopSize.paperDotRadius
            var y = step / 2
            while y < size.height {
                var x = step / 2
                while x < size.width {
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(PopColors.paperDot))
                    x += step
                }
                y += step
            }
        }
        .ignoresSafeArea()
    }
}

/// A sticker surface whose shadow collapses while its enclosing
/// [PopPressStyle] button is pressed.
struct PressableSticker<Content: View>: View {
    @Environment(\.popPressed) private var pressed
    var fill: Color
    var gradient: LinearGradient? = nil
    var radius: CGFloat
    var border: CGFloat = PopBorder.regular
    var shadow: CGFloat = PopShadow.regular
    var shadowColor: Color = PopColors.ink
    @ViewBuilder var content: Content

    var body: some View {
        content.sticker(fill: fill, radius: radius, border: border, shadow: pressed ? 0 : shadow, shadowColor: shadowColor, gradient: gradient)
    }
}

/// Lays out children left to right and wraps onto new lines, like Flutter's
/// Wrap and Compose's FlowRow. Use it for chip and badge rows.
public struct PopWrap: Layout {
    var spacing: CGFloat
    var runSpacing: CGFloat

    public init(spacing: CGFloat = PopSpace.sm, runSpacing: CGFloat = PopSpace.sm) {
        self.spacing = spacing
        self.runSpacing = runSpacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let width = rows.map { $0.width }.max() ?? 0
        let height = rows.map { $0.height }.reduce(0, +) + runSpacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: proposal.width ?? width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y + (row.height - size.height) / 2), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + runSpacing
        }
    }

    private struct Row { var indices: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

    private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        for (i, view) in subviews.enumerated() {
            let size = view.sizeThatFits(.unspecified)
            let needed = rows[rows.count - 1].indices.isEmpty ? size.width : rows[rows.count - 1].width + spacing + size.width
            if needed > width && !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
            }
            var row = rows[rows.count - 1]
            row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            row.height = max(row.height, size.height)
            row.indices.append(i)
            rows[rows.count - 1] = row
        }
        return rows.filter { !$0.indices.isEmpty }
    }
}

extension View {
    /// Centres content and caps it at 600 wide on tablets and Macs.
    public func popContentWidth() -> some View {
        frame(maxWidth: 600).frame(maxWidth: .infinity)
    }
}
