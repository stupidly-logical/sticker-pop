import SwiftUI

/// Tour progress: 10-high dots, 22 wide for the current step, pink once reached.
public struct PopProgressDots: View {
    let count: Int
    let current: Int
    public init(count: Int, current: Int) {
        self.count = count
        self.current = current
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i <= current ? PopColors.pink : PopColors.white)
                    .overlay(Capsule().strokeBorder(PopColors.ink, lineWidth: PopBorder.thin))
                    .frame(width: i == current ? PopSize.progressDotCurrent : PopSize.progressDot, height: PopSize.progressDot)
            }
        }
        .animation(.easeOut(duration: PopMotion.toggle), value: current)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(current + 1) of \(count)")
    }
}

/// The yellow coach-mark card: dots and "Skip", title, body, then "Next" or "Got it".
public struct PopTourCard: View {
    let step: Int
    let count: Int
    let title: String
    let message: String
    let onNext: () -> Void
    var onSkip: (() -> Void)?
    var tilt: CGFloat?

    public init(step: Int, count: Int, title: String, message: String, tilt: CGFloat? = nil,
                onSkip: (() -> Void)? = nil, onNext: @escaping () -> Void) {
        self.step = step
        self.count = count
        self.title = title
        self.message = message
        self.tilt = tilt
        self.onSkip = onSkip
        self.onNext = onNext
    }

    public var body: some View {
        let last = step == count - 1
        VStack(alignment: .leading, spacing: PopSpace.sm) {
            HStack {
                PopProgressDots(count: count, current: step)
                Spacer()
                if let onSkip, !last { PopTextButton("Skip", underline: true, action: onSkip) }
            }
            PopText(title, PopTextSpecs.sheetTitle).accessibilityAddTraits(.isHeader)
            PopText(message, PopTextSpecs.body)
            StickerButton(last ? "Got it" : "Next", action: onNext).padding(.top, PopSpace.sm)
        }
        .padding(PopSpace.xl)
        .sticker(fill: PopColors.yellow, radius: PopRadius.card, shadow: PopShadow.large)
        .popTilt(tilt ?? (step % 2 == 0 ? PopTilt.hero : PopTilt.heroAlt))
    }
}

/// One stop on a tour; `target` matches a `.popTourTarget(_:)` id.
public struct PopTourStep {
    public let target: String
    public let title: String
    public let message: String
    public init(target: String, title: String, message: String) {
        self.target = target
        self.title = title
        self.message = message
    }
}

/// Drives a tour: `start(_:)`, then the overlay calls `next()` / `stop()`.
@MainActor
public final class PopTourState: ObservableObject {
    @Published public private(set) var steps: [PopTourStep] = []
    @Published public private(set) var index: Int = -1
    public var isRunning: Bool { steps.indices.contains(index) }
    public init() {}

    public func start(_ steps: [PopTourStep]) {
        self.steps = steps
        index = steps.isEmpty ? -1 : 0
    }

    public func next() { index = index + 1 < steps.count ? index + 1 : -1 }
    public func stop() { index = -1 }
}

struct PopTourTargetKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

/// Spotlight scrim with a rounded cut-out around `hole`.
struct SpotlightShape: Shape {
    var hole: CGRect?
    func path(in rect: CGRect) -> Path {
        var p = Path(rect)
        if let hole { p.addRoundedRect(in: hole, cornerSize: CGSize(width: PopRadius.spotlight, height: PopRadius.spotlight)) }
        return p
    }
}

struct PopTourOverlayModifier: ViewModifier {
    @ObservedObject var state: PopTourState
    var onFinished: (Bool) -> Void

    func body(content: Content) -> some View {
        content.overlayPreferenceValue(PopTourTargetKey.self) { anchors in
            GeometryReader { geo in
                if state.isRunning {
                    let step = state.steps[state.index]
                    let hole = anchors[step.target].map { geo[$0].insetBy(dx: -8, dy: -8) }
                    let below = hole.map { $0.midY < geo.size.height / 2 } ?? true
                    ZStack(alignment: below ? .top : .bottom) {
                        SpotlightShape(hole: hole)
                            .fill(PopColors.scrim, style: FillStyle(eoFill: true))
                            .contentShape(Rectangle())
                            .onTapGesture {}
                        if let hole {
                            RoundedRectangle(cornerRadius: PopRadius.spotlight)
                                .stroke(PopColors.yellow, lineWidth: PopBorder.spotlight)
                                .frame(width: hole.width, height: hole.height)
                                .position(x: hole.midX, y: hole.midY)
                        }
                        PopTourCard(
                            step: state.index, count: state.steps.count, title: step.title, message: step.message,
                            onSkip: { state.stop(); onFinished(false) },
                            onNext: {
                                let last = state.index == state.steps.count - 1
                                state.next()
                                if last { onFinished(true) }
                            }
                        )
                        .padding(.horizontal, PopSpace.lg)
                        .padding(.top, below ? (hole?.maxY ?? 0) + PopSpace.lg : 0)
                        .padding(.bottom, below ? 0 : geo.size.height - (hole?.minY ?? geo.size.height) + PopSpace.lg)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
    }
}

extension View {
    /// Marks a real control the tour can spotlight.
    public func popTourTarget(_ id: String) -> some View {
        anchorPreference(key: PopTourTargetKey.self, value: .bounds) { [id: $0] }
    }

    /// Runs the tour in `state` over this view: a 72% ink scrim with a
    /// rounded cut-out (radius 18, yellow 3 outline) and the tour card on the
    /// roomier side. Apply it to the screen's root view.
    public func popTourOverlay(_ state: PopTourState, onFinished: @escaping (Bool) -> Void = { _ in }) -> some View {
        modifier(PopTourOverlayModifier(state: state, onFinished: onFinished))
    }
}
