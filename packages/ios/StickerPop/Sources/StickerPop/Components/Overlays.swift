import SwiftUI

// MARK: - Sheet

/// The body of a bottom sheet: paper fill, a 2.5 ink line on top, top
/// radius 24. Title, content, then the inline `error` and the primary button
/// last. Present it with `.popBottomSheet(isPresented:)`.
public struct PopSheet<Content: View, Trailing: View>: View {
    let title: String
    var primaryLabel: String?
    var onPrimary: () -> Void
    var error: String?
    let trailing: Trailing
    let content: Content

    public init(_ title: String, primaryLabel: String? = nil, onPrimary: @escaping () -> Void = {}, error: String? = nil,
                @ViewBuilder trailing: () -> Trailing, @ViewBuilder content: () -> Content) {
        self.title = title
        self.primaryLabel = primaryLabel
        self.onPrimary = onPrimary
        self.error = error
        self.trailing = trailing()
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: PopSpace.lg) {
            HStack {
                PopText(title, PopTextSpecs.sheetTitle).accessibilityAddTraits(.isHeader)
                Spacer()
                trailing
            }
            ScrollView {
                VStack(alignment: .leading, spacing: PopSpace.lg) { content }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fixedSize(horizontal: false, vertical: true)
            if let error { PopFormError(error) }
            if let primaryLabel { StickerButton(primaryLabel, action: onPrimary) }
        }
        .padding(.horizontal, PopSpace.xl)
        .padding(.top, PopSpace.xl)
        .padding(.bottom, PopSpace.xxl)
        .frame(maxWidth: .infinity)
        .background(PopColors.paper)
        .overlay(alignment: .top) { Rectangle().fill(PopColors.ink).frame(height: PopBorder.regular) }
        .clipShape(TopRoundedShape(radius: PopRadius.sheet))
    }
}

extension PopSheet where Trailing == EmptyView {
    public init(_ title: String, primaryLabel: String? = nil, onPrimary: @escaping () -> Void = {}, error: String? = nil,
                @ViewBuilder content: () -> Content) {
        self.init(title, primaryLabel: primaryLabel, onPrimary: onPrimary, error: error, trailing: { EmptyView() }, content: content)
    }
}

/// A rectangle with only its top corners rounded.
struct TopRoundedShape: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.maxY))
        p.addLine(to: CGPoint(x: 0, y: radius))
        p.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX - radius, y: 0))
        p.addArc(center: CGPoint(x: rect.maxX - radius, y: radius), radius: radius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct PopBottomSheetModifier<Sheet: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheet: () -> Sheet

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    if isPresented {
                        PopColors.ink.opacity(0.45)
                            .ignoresSafeArea()
                            .onTapGesture { isPresented = false }
                            .transition(.opacity)
                        sheet()
                            .frame(maxHeight: geo.size.height * PopSize.sheetMaxHeightFraction, alignment: .bottom)
                            .transition(.move(edge: .bottom))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .animation(.easeOut(duration: PopMotion.sheet), value: isPresented)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Dialog

/// A dialog: a paper sticker with the large 6/6 shadow, 20 in from the
/// screen edges. Title, body, the primary button, then "Cancel".
public struct PopDialog: View {
    let title: String
    let message: String
    let primaryLabel: String
    let onPrimary: () -> Void
    let onCancel: () -> Void
    var cancelLabel: String

    public init(_ title: String, message: String, primaryLabel: String, cancelLabel: String = "Cancel",
                onPrimary: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.primaryLabel = primaryLabel
        self.cancelLabel = cancelLabel
        self.onPrimary = onPrimary
        self.onCancel = onCancel
    }

    public var body: some View {
        let card = VStack(alignment: .leading, spacing: PopSpace.sm) {
            PopText(title, PopTextSpecs.sheetTitle).accessibilityAddTraits(.isHeader)
            PopText(message, PopTextSpecs.body)
            StickerButton(primaryLabel, action: onPrimary).padding(.top, PopSpace.md)
            HStack { Spacer(); PopTextButton(cancelLabel, action: onCancel); Spacer() }
        }
        .padding(PopSpace.xl)
        // Scrolls when it's taller than the screen (large text, small phones).
        ViewThatFits(in: .vertical) {
            card
            ScrollView { card }
        }
        .sticker(fill: PopColors.paper, radius: PopRadius.card, shadow: PopShadow.large)
        .padding(PopSpace.xl)
    }
}

struct PopDialogModifier<Dialog: View>: ViewModifier {
    @Binding var isPresented: Bool
    let dialog: () -> Dialog

    func body(content: Content) -> some View {
        content.overlay {
            ZStack {
                if isPresented {
                    PopColors.ink.opacity(0.45).ignoresSafeArea().onTapGesture { isPresented = false }
                    dialog().transition(.scale(scale: 0.96).combined(with: .opacity))
                }
            }
            .animation(.easeOut(duration: PopMotion.fade), value: isPresented)
        }
    }
}

// MARK: - Snackbar

/// State for `.popSnackbarHost(_:)`. Snackbars are only for confirmations
/// such as "Saved" and "Deleted · Undo": 3 s, or 6 s with an action. Never
/// for form errors.
@MainActor
public final class PopSnackbarState: ObservableObject {
    public struct Snack: Equatable {
        public let id = UUID()
        public let message: String
        public let actionLabel: String?
        let onAction: () -> Void
        public static func == (a: Snack, b: Snack) -> Bool { a.id == b.id }
    }

    @Published public private(set) var current: Snack?

    public init() {}

    public func show(_ message: String, actionLabel: String? = nil, onAction: @escaping () -> Void = {}) {
        let snack = Snack(message: message, actionLabel: actionLabel, onAction: onAction)
        current = snack
        let seconds = actionLabel == nil ? PopMotion.snackbar : PopMotion.snackbarWithAction
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            if self?.current == snack { self?.current = nil }
        }
    }

    public func dismiss() { current = nil }
}

struct PopSnackbarHostModifier: ViewModifier {
    @ObservedObject var state: PopSnackbarState

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if let snack = state.current {
                HStack {
                    PopText(snack.message, PopTextSpecs.snackbar)
                    Spacer()
                    if let label = snack.actionLabel {
                        Button {
                            snack.onAction()
                            state.dismiss()
                        } label: {
                            PopText(label, PopTextSpecs.textButton, color: PopColors.yellow)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, PopSpace.lg).padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: PopRadius.snackbar).fill(PopColors.ink))
                .padding(PopSpace.lg)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .accessibilityElement(children: .combine)
            }
        }
        .animation(.easeOut(duration: PopMotion.fade), value: state.current)
    }
}

extension View {
    /// Presents `sheet` (usually a `PopSheet`) from the bottom, over a scrim.
    public func popBottomSheet<Sheet: View>(isPresented: Binding<Bool>, @ViewBuilder sheet: @escaping () -> Sheet) -> some View {
        modifier(PopBottomSheetModifier(isPresented: isPresented, sheet: sheet))
    }

    /// Presents `dialog` (usually a `PopDialog`) centred over a scrim.
    public func popDialog<Dialog: View>(isPresented: Binding<Bool>, @ViewBuilder dialog: @escaping () -> Dialog) -> some View {
        modifier(PopDialogModifier(isPresented: isPresented, dialog: dialog))
    }

    /// Shows the snackbar from `state` floating at the bottom.
    public func popSnackbarHost(_ state: PopSnackbarState) -> some View {
        modifier(PopSnackbarHostModifier(state: state))
    }
}
