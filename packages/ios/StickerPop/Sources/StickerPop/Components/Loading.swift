import SwiftUI

/// A placeholder shape shown while content loads: divider-coloured, no
/// outline, gently pulsing (still under Reduce Motion).
public struct PopSkeleton: View {
    enum Kind { case line, circle, block }
    let kind: Kind
    var width: CGFloat?
    var height: CGFloat
    var radius: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dim = false

    /// A text line, 14 high.
    public static func line(width: CGFloat? = nil, height: CGFloat = PopSize.skeletonLine) -> PopSkeleton {
        PopSkeleton(kind: .line, width: width, height: height, radius: PopRadius.skeletonLine)
    }
    /// A circle, e.g. where a category dot will be.
    public static func circle(size: CGFloat = PopSize.categoryDot) -> PopSkeleton {
        PopSkeleton(kind: .circle, width: size, height: size, radius: size / 2)
    }
    /// A block, e.g. where a card or chart will be.
    public static func block(height: CGFloat, radius: CGFloat = PopRadius.card) -> PopSkeleton {
        PopSkeleton(kind: .block, width: nil, height: height, radius: radius)
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(PopColors.divider)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .opacity(dim ? 0.55 : 1)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: PopMotion.pulse).repeatForever(autoreverses: true)) { dim = true }
            }
            .accessibilityHidden(true)
    }
}

/// A `StickerList`-shaped stack of skeleton rows, announced once as "Loading".
public struct PopSkeletonList: View {
    var rows: Int
    var label: String
    public init(rows: Int = 3, label: String = "Loading") {
        self.rows = rows
        self.label = label
    }
    public var body: some View {
        StickerCard(padding: 0) {
            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { i in
                    if i > 0 { Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider) }
                    HStack(spacing: PopSpace.md) {
                        PopSkeleton.circle()
                        VStack(alignment: .leading, spacing: PopSpace.sm) {
                            PopSkeleton.line(width: i % 2 == 0 ? 130 : 100)
                            PopSkeleton.line(width: 170, height: 10)
                        }
                        Spacer(minLength: 0)
                        PopSkeleton.line(width: 56)
                    }
                    .padding(.horizontal, PopSpace.lg)
                    .padding(.vertical, 12)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }
}

/// A 24 divider ring with a turning ink arc, for short waits. Still under Reduce Motion.
public struct PopSpinner: View {
    var size: CGFloat
    var label: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var turning = false

    public init(size: CGFloat = PopSize.spinner, label: String = "Loading") {
        self.size = size
        self.label = label
    }

    public var body: some View {
        let w = size / 8
        ZStack {
            Circle().stroke(PopColors.divider, lineWidth: w)
            Circle().trim(from: 0, to: 0.25).stroke(PopColors.ink, style: StrokeStyle(lineWidth: w, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding(w / 2)
        .frame(width: size, height: size)
        .rotationEffect(.degrees(turning ? 360 : 0))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: PopMotion.spin).repeatForever(autoreverses: false)) { turning = true }
        }
        .accessibilityLabel(label)
    }
}
