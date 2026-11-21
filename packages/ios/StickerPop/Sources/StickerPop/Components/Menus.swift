import SwiftUI

// MARK: - Overlay host

/// Draws Sticker Pop sheets and menus above the whole screen. Apply
/// `.popOverlayHost()` once, at the root of a screen (or the app); `PopSelect`
/// and `PopMenu` inside it then present through it. Without a host they fall
/// back to the system sheet and the system menu.
@MainActor
public final class PopOverlayController: ObservableObject {
    @Published var sheet: AnyView?
    @Published var menu: PopMenuRequest?

    public init() {}

    /// Shows `content` (usually a `PopSheet`) as a bottom sheet.
    public func present<Sheet: View>(sheet content: Sheet) { sheet = AnyView(content) }
    public func dismissSheet() { sheet = nil }
    public func dismissMenu() { menu = nil }
}

struct PopMenuRequest {
    let id = UUID()
    let anchor: CGRect
    let entries: [PopMenuEntry]
}

private struct PopOverlayKey: EnvironmentKey {
    static let defaultValue: PopOverlayController? = nil
}

extension EnvironmentValues {
    /// The nearest `.popOverlayHost()`, if any.
    public var popOverlay: PopOverlayController? {
        get { self[PopOverlayKey.self] }
        set { self[PopOverlayKey.self] = newValue }
    }
}

struct PopOverlayHost: ViewModifier {
    @StateObject private var controller = PopOverlayController()

    func body(content: Content) -> some View {
        content
            .environment(\.popOverlay, controller)
            .overlay {
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        if let sheet = controller.sheet {
                            PopColors.ink.opacity(0.45)
                                .ignoresSafeArea()
                                .onTapGesture { controller.sheet = nil }
                                .accessibilityAddTraits(.isButton)
                                .accessibilityLabel("Close")
                                .transition(.opacity)
                            sheet
                                .frame(maxHeight: geo.size.height * PopSize.sheetMaxHeightFraction, alignment: .bottom)
                                .transition(.move(edge: .bottom))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .animation(.easeOut(duration: PopMotion.sheet), value: controller.sheet != nil)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .overlay {
                GeometryReader { geo in
                    if let menu = controller.menu {
                        PopMenuLayer(request: menu, host: geo.frame(in: .global)) { controller.menu = nil }
                            .id(menu.id)
                    }
                }
            }
    }
}

extension View {
    /// Lets `PopSelect` and `PopMenu` inside this view draw their sheet and
    /// menu above everything. Apply once, at the root of a screen.
    public func popOverlayHost() -> some View { modifier(PopOverlayHost()) }
}

// MARK: - Select

/// One choice in a `PopSelect`.
public struct PopSelectOption<Value: Hashable>: Identifiable {
    public let value: Value
    public let label: String
    public var systemImage: String?
    public var caption: String?
    public var id: Value { value }

    public init(_ label: String, value: Value, systemImage: String? = nil, caption: String? = nil) {
        self.label = label
        self.value = value
        self.systemImage = systemImage
        self.caption = caption
    }
}

/// A dropdown: a field (white, 2 ink outline, radius 14) showing the chosen
/// option and a chevron. Tapping it opens a bottom sheet listing the options;
/// the chosen row is yellow with a tick. For two to five short options a
/// `PopSegmented` or chips are usually better.
public struct PopSelect<Value: Hashable>: View {
    let options: [PopSelectOption<Value>]
    @Binding var selection: Value?
    var label: String?
    var hint: String
    var sheetTitle: String?
    var error: String?
    @Environment(\.popOverlay) private var overlay
    @Environment(\.isEnabled) private var enabled
    @State private var nativeSheet = false

    public init(_ options: [PopSelectOption<Value>], selection: Binding<Value?>, label: String? = nil,
                hint: String = "Choose", sheetTitle: String? = nil, error: String? = nil) {
        self.options = options
        self._selection = selection
        self.label = label
        self.hint = hint
        self.sheetTitle = sheetTitle
        self.error = error
    }

    private var selected: PopSelectOption<Value>? { options.first { $0.value == selection } }
    private var tint: Color { enabled ? PopColors.ink : PopColors.inkMuted }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label { PopText(label, PopTextSpecs.fieldLabel) }
            Button(action: open) {
                HStack(spacing: PopSpace.sm) {
                    if let image = selected?.systemImage {
                        Image(systemName: image).font(.system(size: PopSize.iconNav * 0.8, weight: .bold)).foregroundStyle(tint)
                    }
                    if let selected {
                        PopText(selected.label, PopTextSpecs.input, color: tint).lineLimit(1)
                    } else {
                        PopText(hint, PopTextSpecs.inputHint).lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.down").font(.system(size: 15, weight: .bold)).foregroundStyle(tint)
                }
                .padding(.horizontal, PopSpace.md)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, minHeight: PopSize.tapTarget)
                .sticker(fill: enabled ? PopColors.white : PopColors.paper, radius: PopRadius.field,
                         border: error == nil ? PopBorder.thin : PopBorder.regular, shadow: 0)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label ?? hint)
            .accessibilityValue(selected?.label ?? hint)
            .accessibilityHint("Opens a list")
            if let error { PopFormError(error) }
        }
        .sheet(isPresented: $nativeSheet) {
            makeSheet { nativeSheet = false }
                .presentationDetents([.medium, .large])
        }
    }

    private func makeSheet(close: @escaping () -> Void) -> PopSelectSheet<Value> {
        PopSelectSheet(title: sheetTitle ?? label ?? hint, options: options, selected: selection) { picked in
            selection = picked.value
            close()
        }
    }

    private func open() {
        if let overlay {
            overlay.present(sheet: makeSheet { overlay.dismissSheet() })
        } else {
            nativeSheet = true
        }
    }
}

/// The `PopSelect` sheet on its own: a titled sheet with the options in a sticker list.
public struct PopSelectSheet<Value: Hashable>: View {
    let title: String
    let options: [PopSelectOption<Value>]
    let selected: Value?
    let onPick: (PopSelectOption<Value>) -> Void

    public init(title: String, options: [PopSelectOption<Value>], selected: Value?, onPick: @escaping (PopSelectOption<Value>) -> Void) {
        self.title = title
        self.options = options
        self.selected = selected
        self.onPick = onPick
    }

    public var body: some View {
        PopSheet(title) {
            StickerList(options) { o in
                PopOptionRow(o.label, caption: o.caption, systemImage: o.systemImage, selected: o.value == selected) { onPick(o) }
            }
        }
    }
}

/// A select-list row: optional icon, a 16 label (800 when chosen), optional
/// caption, and a tick. The chosen row fills yellow to the edges.
public struct PopOptionRow: View {
    let label: String
    var caption: String?
    var systemImage: String?
    var selected: Bool
    let action: () -> Void

    public init(_ label: String, caption: String? = nil, systemImage: String? = nil, selected: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.caption = caption
        self.systemImage = systemImage
        self.selected = selected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: PopSpace.md) {
                if let systemImage {
                    Image(systemName: systemImage).font(.system(size: PopSize.iconNav * 0.8, weight: .bold)).foregroundStyle(PopColors.ink)
                }
                VStack(alignment: .leading, spacing: 2) {
                    PopText(label, selected ? PopTextSpecs.rowTitle : PopTextSpecs.input)
                    if let caption { PopText(caption, PopTextSpecs.caption) }
                }
                Spacer(minLength: 0)
                if selected {
                    Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundStyle(PopColors.ink)
                }
            }
            .padding(.horizontal, PopSpace.lg)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: PopSize.rowMin, alignment: .leading)
            .background(selected ? PopColors.yellow : PopColors.white)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Menu

/// One action in a `PopMenu`. Destructive actions (Delete) are 800 and go
/// last, after a divider; they stay ink, never red.
public struct PopMenuItem {
    public let label: String
    public var systemImage: String?
    public var destructive: Bool
    public var enabled: Bool
    public let action: () -> Void

    public init(_ label: String, systemImage: String? = nil, destructive: Bool = false, enabled: Bool = true, action: @escaping () -> Void) {
        self.label = label
        self.systemImage = systemImage
        self.destructive = destructive
        self.enabled = enabled
        self.action = action
    }
}

/// An entry in a `PopMenu`: an item or a divider.
public enum PopMenuEntry {
    case item(PopMenuItem)
    case divider

    public static func item(_ label: String, systemImage: String? = nil, destructive: Bool = false, enabled: Bool = true,
                            action: @escaping () -> Void) -> PopMenuEntry {
        .item(PopMenuItem(label, systemImage: systemImage, destructive: destructive, enabled: enabled, action: action))
    }
}

/// A small popover of actions anchored to its trigger (usually a
/// `PopIconButton` with "ellipsis"). A white sticker, radius 16, 4/4 shadow;
/// rows are 48 high and turn yellow when pressed or hovered. It opens below
/// the trigger, lined up with its trailing edge, and flips above when there
/// is no room. Needs `.popOverlayHost()` above it; without one it falls back
/// to the system menu.
public struct PopMenu<Trigger: View>: View {
    let entries: [PopMenuEntry]
    let trigger: (_ toggle: @escaping () -> Void) -> Trigger
    @Environment(\.popOverlay) private var overlay
    @State private var frame: CGRect = .zero

    public init(_ entries: [PopMenuEntry], @ViewBuilder trigger: @escaping (_ toggle: @escaping () -> Void) -> Trigger) {
        self.entries = entries
        self.trigger = trigger
    }

    public var body: some View {
        if let overlay {
            trigger {
                overlay.menu = overlay.menu == nil ? PopMenuRequest(anchor: frame, entries: entries) : nil
            }
            .background(
                GeometryReader { g in
                    Color.clear
                        .onAppear { frame = g.frame(in: .global) }
                        .onChange(of: g.frame(in: .global)) { frame = $0 }
                }
            )
        } else {
            Menu {
                ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                    switch entry {
                    case .divider:
                        Divider()
                    case .item(let item):
                        Button(action: item.action) {
                            if let image = item.systemImage { Label(item.label, systemImage: image) } else { Text(item.label) }
                        }
                        .disabled(!item.enabled)
                    }
                }
            } label: {
                trigger({}).allowsHitTesting(false)
            }
        }
    }
}

private struct PopMenuSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

/// The full-screen layer a menu lives in: a tap outside closes it.
struct PopMenuLayer: View {
    let request: PopMenuRequest
    let host: CGRect
    let onClose: () -> Void
    @State private var size: CGSize = .zero
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(perform: onClose)
                .accessibilityHidden(true)
            PopMenuPanel(request.entries, onClose: onClose)
                .background(GeometryReader { g in Color.clear.preference(key: PopMenuSizeKey.self, value: g.size) })
                .onPreferenceChange(PopMenuSizeKey.self) { size = $0 }
                .scaleEffect(shown || reduceMotion ? 1 : 0.96, anchor: .topTrailing)
                .opacity(size == .zero ? 0 : (shown ? 1 : 0))
                .offset(x: origin.x, y: origin.y)
        }
        .frame(width: host.width, height: host.height, alignment: .topLeading)
        .onAppear { withAnimation(.easeOut(duration: PopMotion.fade)) { shown = true } }
        .popEscape(onClose)
    }

    private var origin: CGPoint {
        let a = request.anchor.offsetBy(dx: -host.minX, dy: -host.minY)
        let edge = PopSpace.sm
        let x = min(max(a.maxX - size.width, edge), max(edge, host.width - size.width - edge))
        let below = a.maxY + edge
        let y = below + size.height <= host.height - edge ? below : max(edge, a.minY - edge - size.height)
        return CGPoint(x: x, y: y)
    }
}

/// The menu's sticker panel on its own.
public struct PopMenuPanel: View {
    let entries: [PopMenuEntry]
    let onClose: () -> Void

    public init(_ entries: [PopMenuEntry], onClose: @escaping () -> Void) {
        self.entries = entries
        self.onClose = onClose
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                switch entry {
                case .divider:
                    Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider).padding(.vertical, 6)
                case .item(let item):
                    Button {
                        onClose()
                        item.action()
                    } label: {
                        HStack(spacing: PopSpace.md) {
                            if let image = item.systemImage {
                                Image(systemName: image).font(.system(size: PopSize.iconNav * 0.8, weight: .bold))
                            }
                            PopText(item.label, item.destructive ? PopTextSpecs.tileLabel : PopTextSpecs.menuItem,
                                    color: item.enabled ? PopColors.ink : PopColors.inkMuted)
                        }
                        .foregroundStyle(item.enabled ? PopColors.ink : PopColors.inkMuted)
                        .padding(.horizontal, PopSpace.lg)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, minHeight: PopSize.tapTarget, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PopMenuRowStyle())
                    .disabled(!item.enabled)
                }
            }
        }
        .padding(.vertical, 6)
        .frame(minWidth: PopSize.menuMinWidth, maxWidth: PopSize.menuMaxWidth)
        .fixedSize(horizontal: true, vertical: true)
        .sticker(fill: PopColors.white, radius: PopRadius.menu)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}

/// Yellow while pressed or hovered.
private struct PopMenuRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { Row(configuration: configuration) }

    private struct Row: View {
        let configuration: ButtonStyleConfiguration
        @State private var hover = false
        @Environment(\.isEnabled) private var enabled
        var body: some View {
            configuration.label
                .background((configuration.isPressed || hover) && enabled ? PopColors.yellow : Color.clear)
                .onHover { hover = $0 }
        }
    }
}

private extension View {
    /// Escape closes, where the OS sends key presses (iOS 17, macOS 14).
    @ViewBuilder func popEscape(_ action: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            self.focusable().onKeyPress(.escape) { action(); return .handled }
        } else {
            self
        }
    }
}
