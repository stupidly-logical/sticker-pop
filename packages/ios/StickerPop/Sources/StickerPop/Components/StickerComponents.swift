import SwiftUI

// MARK: - Cards

/// White (or bright) card: 2.5 ink outline, radius 22, 4/4 hard shadow.
public struct StickerCard<Content: View>: View {
    var fill: Color
    var gradient: LinearGradient?
    var shadow: CGFloat
    var tilt: CGFloat
    var padding: CGFloat
    var action: (() -> Void)?
    @ViewBuilder var content: Content

    /// `gradient` (from `PopGradients`) replaces `fill` when set.
    public init(fill: Color = PopColors.white, gradient: LinearGradient? = nil, shadow: CGFloat = PopShadow.regular, tilt: CGFloat = 0,
                padding: CGFloat = PopSpace.card, action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.fill = fill
        self.gradient = gradient
        self.shadow = shadow
        self.tilt = min(max(tilt, -PopTilt.cardMax), PopTilt.cardMax)
        self.padding = padding
        self.action = action
        self.content = content()
    }

    public var body: some View {
        let surface = PressableSticker(fill: fill, gradient: gradient, radius: PopRadius.card, shadow: shadow) {
            content.padding(padding).frame(maxWidth: .infinity, alignment: .leading)
        }
        Group {
            if let action {
                Button(action: action) { surface }.buttonStyle(PopPressStyle(offset: shadow))
            } else {
                surface
            }
        }
        .popTilt(tilt)
    }
}

/// The yellow headline card with the large 6/6 shadow.
public func StickerHeroCard<Content: View>(tilt: CGFloat = PopTilt.hero, gradient: LinearGradient? = nil, action: (() -> Void)? = nil,
                                          @ViewBuilder content: () -> Content) -> StickerCard<Content> {
    StickerCard(fill: PopColors.yellow, gradient: gradient, shadow: PopShadow.large, tilt: tilt, padding: PopSpace.xl, action: action, content: content)
}

/// A blue (or lilac or mint) card for information and hints.
public func StickerInfoCard<Content: View>(fill: Color = PopColors.blue, action: (() -> Void)? = nil,
                                          @ViewBuilder content: () -> Content) -> StickerCard<Content> {
    StickerCard(fill: fill, action: action, content: content)
}

// MARK: - Buttons

/// Primary action: ink fill, white 18/800 label, pink hard shadow. One per
/// screen. `busy` shows "Label…" and ignores taps; `.disabled(true)` mutes it.
public struct StickerButton: View {
    let label: String
    var busy: Bool
    var shadowColor: Color
    let action: () -> Void
    @Environment(\.isEnabled) private var enabled

    public init(_ label: String, busy: Bool = false, shadowColor: Color = PopColors.pink, action: @escaping () -> Void) {
        self.label = label
        self.busy = busy
        self.shadowColor = shadowColor
        self.action = action
    }

    public var body: some View {
        let active = enabled && !busy
        Button(action: action) {
            PressableSticker(fill: active ? PopColors.ink : PopColors.inkMuted, radius: PopRadius.button,
                             shadowColor: shadowColor) {
                PopText(busy ? "\(label)…" : label, PopTextSpecs.buttonLabel)
                    .lineLimit(1).minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, minHeight: PopSize.button)
            }
        }
        .buttonStyle(PopPressStyle())
        .disabled(busy)
        .accessibilityLabel(label)
    }
}

/// Secondary action in plain ink text.
public struct PopTextButton: View {
    let label: String
    var underline = false
    let action: () -> Void
    @Environment(\.isEnabled) private var enabled

    public init(_ label: String, underline: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.underline = underline
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            PopText(label, PopTextSpecs.textButton, color: enabled ? PopColors.ink : PopColors.inkMuted)
                .underline(underline)
                .frame(minWidth: PopSize.tapTarget, minHeight: PopSize.tapTarget)
        }
        .buttonStyle(.plain)
    }
}

/// 46 round sticker button holding one 22 icon. `label` is read aloud.
public struct PopIconButton: View {
    let systemImage: String
    let label: String
    var fill: Color = PopColors.white
    var selected: Bool = false
    let action: () -> Void
    @Environment(\.isEnabled) private var enabled

    public init(systemImage: String, label: String, fill: Color = PopColors.white, selected: Bool = false,
                action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.label = label
        self.fill = fill
        self.selected = selected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: PopSize.iconNav * 0.8, weight: .bold))
                .foregroundStyle(enabled ? PopColors.ink : PopColors.inkMuted)
                .frame(width: PopSize.iconButton, height: PopSize.iconButton)
                .background(Circle().fill(enabled ? fill : PopColors.paper))
                .overlay(Circle().strokeBorder(PopColors.ink, lineWidth: selected ? PopBorder.spotlight : PopBorder.regular))
                .background(Circle().fill(PopColors.ink).offset(x: PopShadow.small, y: PopShadow.small).opacity(enabled ? 1 : 0))
        }
        .buttonStyle(PopPressStyle(offset: PopShadow.small))
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

// MARK: - Selection

/// Selectable pill. Selected: bright fill, 2.5 outline, 2/2 shadow, 800 text.
public struct PopChip: View {
    let label: String
    let selected: Bool
    var fill: Color = PopColors.yellow
    var systemImage: String?
    var onRemove: (() -> Void)?
    let action: () -> Void
    @Environment(\.isEnabled) private var enabled

    public init(_ label: String, selected: Bool, fill: Color = PopColors.yellow, systemImage: String? = nil,
                onRemove: (() -> Void)? = nil, action: @escaping () -> Void) {
        self.label = label
        self.selected = selected
        self.fill = fill
        self.systemImage = systemImage
        self.onRemove = onRemove
        self.action = action
    }

    public var body: some View {
        let fg = enabled ? PopColors.ink : PopColors.inkMuted
        HStack(spacing: 6) {
            if let systemImage { Image(systemName: systemImage).font(.system(size: 13, weight: .bold)).foregroundStyle(fg) }
            // The label reserves the width of its bold (selected) form, so the
            // chip is the same size selected or not and neighbours never move.
            ZStack {
                PopText(label, PopTextSpecs.chipSelected).lineLimit(1).hidden().accessibilityHidden(true)
                PopText(label, selected ? PopTextSpecs.chipSelected : PopTextSpecs.chip, color: fg).lineLimit(1)
            }
            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundStyle(fg).padding(4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(label)")
            }
        }
        .padding(.leading, 14).padding(.trailing, onRemove == nil ? 14 : 6).padding(.vertical, 6)
        .frame(minHeight: PopSize.chip)
        .sticker(fill: !enabled ? PopColors.paper : (selected ? fill : PopColors.white), radius: PopRadius.pill,
                 border: selected ? PopBorder.regular : PopBorder.thin, shadow: selected && enabled ? PopShadow.chip : 0)
        .contentShape(Capsule())
        .onTapGesture { if enabled { action() } }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

/// Equal segments with one selected (pink by default).
public struct PopSegmented<T: Hashable>: View {
    let values: [T]
    @Binding var selection: T
    let label: (T) -> String
    var fill: (T) -> Color = { _ in PopColors.pink }
    @Environment(\.isEnabled) private var enabled

    public init(_ values: [T], selection: Binding<T>, label: @escaping (T) -> String,
                fill: @escaping (T) -> Color = { _ in PopColors.pink }) {
        self.values = values
        self._selection = selection
        self.label = label
        self.fill = fill
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(values.enumerated()), id: \.element) { i, v in
                if i > 0 { Rectangle().fill(PopColors.ink).frame(width: PopBorder.regular) }
                let on = v == selection
                Button { selection = v } label: {
                    PopText(label(v), on ? PopTextSpecs.segmentSelected : PopTextSpecs.segment,
                            color: enabled ? PopColors.ink : PopColors.inkMuted)
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: PopSize.segment)
                        .background(on && enabled ? fill(v) : Color.clear)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .frame(height: PopSize.segment)
        .clipShape(RoundedRectangle(cornerRadius: PopRadius.tile, style: .continuous))
        .sticker(fill: enabled ? PopColors.white : PopColors.paper, radius: PopRadius.tile, shadow: 0)
    }
}

/// 52×30 switch: white off, mint on, knob slides in 150 ms.
public struct PopSwitch: View {
    @Binding var isOn: Bool
    let label: String
    @Environment(\.isEnabled) private var enabled

    public init(isOn: Binding<Bool>, label: String) {
        self._isOn = isOn
        self.label = label
    }

    public var body: some View {
        Button { withAnimation(.easeOut(duration: PopMotion.toggle)) { isOn.toggle() } } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule().fill(!enabled ? PopColors.paper : (isOn ? PopColors.mint : PopColors.white))
                Circle().fill(enabled ? PopColors.white : PopColors.divider)
                    .overlay(Circle().strokeBorder(PopColors.ink, lineWidth: PopBorder.thin))
                    .frame(width: PopSize.switchKnob, height: PopSize.switchKnob)
                    .padding(PopBorder.regular + 1.5)
            }
            .frame(width: PopSize.switchWidth, height: PopSize.switchHeight)
            .overlay(Capsule().strokeBorder(PopColors.ink, lineWidth: PopBorder.regular))
            .frame(minHeight: PopSize.tapTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? "On" : "Off")
        .modifier(PopToggleTrait())
    }
}

// MARK: - Inputs

/// White field, 2 outline (2.5 in error), radius 14. Errors show in ink with ⚠.
public struct PopTextField: View {
    let hint: String
    @Binding var text: String
    var label: String?
    var error: String?
    @Environment(\.isEnabled) private var enabled
    @FocusState private var focused: Bool

    public init(_ hint: String, text: Binding<String>, label: String? = nil, error: String? = nil) {
        self.hint = hint
        self._text = text
        self.label = label
        self.error = error
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label { PopText(label, PopTextSpecs.fieldLabel) }
            TextField("", text: $text, prompt: Text(hint).foregroundColor(PopColors.inkMuted))
                .font(.pop(PopTextSpecs.input.size, weight: PopTextSpecs.input.weight))
                .foregroundStyle(enabled ? PopColors.ink : PopColors.inkMuted)
                .tint(PopColors.ink)
                .focused($focused)
                .padding(.horizontal, PopSpace.md)
                .frame(minHeight: PopSize.tapTarget)
                .sticker(fill: enabled ? PopColors.white : PopColors.paper, radius: PopRadius.field,
                         border: error == nil && !focused ? PopBorder.thin : PopBorder.regular, shadow: 0)
            if let error { PopFormError(error) }
        }
    }
}

/// Inline form error: 14/800 ink with ⚠, directly above the primary button.
public struct PopFormError: View {
    let message: String
    public init(_ message: String) { self.message = message }
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: "exclamationmark.circle").font(.system(size: 13, weight: .bold))
            PopText(message, PopTextSpecs.formError)
        }
        .foregroundStyle(PopColors.ink)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Badges, dots, lists

/// Small tilted label: UPI, Unsure, 80%.
public struct StickerBadge: View {
    let label: String
    var fill: Color = PopColors.white
    var gradient: LinearGradient?
    var tilt: CGFloat = PopTilt.badge
    public init(_ label: String, fill: Color = PopColors.white, gradient: LinearGradient? = nil, tilt: CGFloat = PopTilt.badge) {
        self.label = label
        self.fill = fill
        self.gradient = gradient
        self.tilt = tilt
    }
    public var body: some View {
        PopText(label, PopTextSpec(size: 12, weight: 800, tabular: true))
            .padding(.horizontal, 9).padding(.vertical, 2)
            .sticker(fill: fill, radius: PopRadius.badge, border: PopBorder.thin, shadow: 0, gradient: gradient)
            .popTilt(tilt)
    }
}

/// 42 round category icon, tilted −5°.
public struct CategoryDot: View {
    let systemImage: String
    let fill: Color
    var size: CGFloat = PopSize.categoryDot
    public init(systemImage: String, fill: Color, size: CGFloat = PopSize.categoryDot) {
        self.systemImage = systemImage
        self.fill = fill
        self.size = size
    }
    public var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundStyle(PopColors.ink)
            .frame(width: size, height: size)
            .background(Circle().fill(fill))
            .overlay(Circle().strokeBorder(PopColors.ink, lineWidth: PopBorder.thin))
            .popTilt(PopTilt.categoryDot)
            .accessibilityHidden(true)
    }
}

/// One row in a sticker list.
public struct StickerListRow: View {
    let title: String
    var subtitle: String?
    var amount: String?
    var leading: AnyView?
    var badge: AnyView?
    var amountCaption: String?
    var selected: Bool

    public init(_ title: String, subtitle: String? = nil, amount: String? = nil, leading: AnyView? = nil,
                badge: AnyView? = nil, amountCaption: String? = nil, selected: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.leading = leading
        self.badge = badge
        self.amountCaption = amountCaption
        self.selected = selected
    }

    public var body: some View {
        HStack(spacing: PopSpace.md) {
            leading
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: PopSpace.sm) { PopText(title, PopTextSpecs.rowTitle).lineLimit(1); badge }
                if let subtitle { PopText(subtitle, PopTextSpecs.caption).lineLimit(1) }
            }
            Spacer(minLength: PopSpace.sm)
            if let amount {
                VStack(alignment: .trailing, spacing: 1) {
                    PopText(amount, PopTextSpecs.rowAmount)
                    if let amountCaption { PopText(amountCaption, PopTextSpecs.caption) }
                }
            }
        }
        .padding(.horizontal, PopSpace.lg).padding(.vertical, 11)
        .frame(minHeight: PopSize.rowMin)
        .background(selected ? PopColors.yellow : Color.clear)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// A card holding rows separated by 2 divider lines.
public struct StickerList<Data: RandomAccessCollection, Row: View>: View where Data.Element: Identifiable {
    let data: Data
    let row: (Data.Element) -> Row
    public init(_ data: Data, @ViewBuilder row: @escaping (Data.Element) -> Row) {
        self.data = data
        self.row = row
    }
    public var body: some View {
        StickerCard(padding: 0) {
            VStack(spacing: 0) {
                ForEach(Array(data.enumerated()), id: \.element.id) { i, item in
                    if i > 0 { Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider) }
                    row(item)
                }
            }
            // No padding: a selected row's fill reaches the outline on every edge.
        }
    }
}

/// Goal or budget bar: white track 18 high, 2 outline, bright fill.
public struct PopProgressBar: View {
    let value: Double
    var fill: Color = PopColors.mint
    let label: String
    public init(value: Double, fill: Color = PopColors.mint, label: String) {
        self.value = value
        self.fill = fill
        self.label = label
    }
    public var body: some View {
        let v = min(max(value, 0), 1)
        GeometryReader { geo in
            Rectangle().fill(fill).frame(width: geo.size.width * v)
                // Straight ink cut at the leading edge, as on every platform.
                .overlay(alignment: .trailing) {
                    if v > 0 && v < 1 { Rectangle().fill(PopColors.ink).frame(width: PopBorder.thin) }
                }
        }
        .frame(height: PopSize.progressBar)
        .background(PopColors.white)
        .clipShape(RoundedRectangle(cornerRadius: PopRadius.progressTrack))
        .overlay(RoundedRectangle(cornerRadius: PopRadius.progressTrack).strokeBorder(PopColors.ink, lineWidth: PopBorder.thin))
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(v * 100))%")
    }
}

// MARK: - Navigation

/// One destination in `PopNavBar`.
public struct PopNavItem: Identifiable {
    public let id = UUID()
    public let systemImage: String
    public let label: String
    public init(systemImage: String, label: String) {
        self.systemImage = systemImage
        self.label = label
    }
}

/// Bottom navigation: four destinations, tilted pink add button centred.
public struct PopNavBar: View {
    let items: [PopNavItem]
    @Binding var selection: Int
    let onAdd: () -> Void

    public init(items: [PopNavItem], selection: Binding<Int>, onAdd: @escaping () -> Void) {
        precondition(items.count == 4, "PopNavBar has four destinations plus Add")
        self.items = items
        self._selection = selection
        self.onAdd = onAdd
    }

    public var body: some View {
        HStack(spacing: 0) {
            slot(0); slot(1)
            // The add slot is as wide as the button plus room for tilt and shadow; the four
            // items share the rest, so on a narrow phone it never overlaps its neighbours.
            PopAddButton(action: onAdd).fixedSize()
                .padding(.leading, PopSpace.sm).padding(.trailing, PopSpace.sm + PopShadow.regular)
            slot(2); slot(3)
        }
        .padding(.horizontal, 8).padding(.vertical, 10)
        .background(PopColors.white)
        .overlay(alignment: .top) { Rectangle().fill(PopColors.ink).frame(height: PopBorder.regular) }
    }

    private func slot(_ i: Int) -> some View {
        let on = i == selection
        return Button { selection = i } label: {
            VStack(spacing: 3) {
                Image(systemName: items[i].systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(on ? PopColors.ink : PopColors.inkMuted)
                    .padding(.horizontal, 10).padding(.vertical, 2)
                    .background {
                        if on {
                            RoundedRectangle(cornerRadius: PopRadius.navPill).fill(PopColors.yellow)
                                .overlay(RoundedRectangle(cornerRadius: PopRadius.navPill).strokeBorder(PopColors.ink, lineWidth: PopBorder.thin))
                        }
                    }
                // Nav labels grow with system text up to about 150%, then stop.
                PopText(items[i].label, on ? PopTextSpecs.navLabelSelected : PopTextSpecs.navLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            }
            .padding(.horizontal, 2)
            .frame(maxWidth: .infinity, minHeight: PopSize.tapTarget)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

/// Pink sticker, radius 20, tilted −6°, holding a 28 "+".
public struct PopAddButton: View {
    let action: () -> Void
    public init(action: @escaping () -> Void) { self.action = action }
    public var body: some View {
        Button(action: action) {
            PressableSticker(fill: PopColors.pink, radius: PopRadius.addButton) {
                Image(systemName: "plus").font(.system(size: 22, weight: .heavy)).foregroundStyle(PopColors.ink)
                    .frame(width: PopSize.iconAdd, height: PopSize.iconAdd).padding(13)
            }
        }
        .buttonStyle(PopPressStyle())
        .popTilt(PopTilt.addButton)
        .accessibilityLabel("Add transaction")
    }
}

/// Home's Type it / Say it / Scan it row.
public struct PopQuickAddRow: View {
    let onType: () -> Void, onSay: () -> Void, onScan: () -> Void
    public init(onType: @escaping () -> Void, onSay: @escaping () -> Void, onScan: @escaping () -> Void) {
        self.onType = onType
        self.onSay = onSay
        self.onScan = onScan
    }
    public var body: some View {
        HStack(spacing: PopSpace.md) {
            tile("Type it", "keyboard", PopColors.white, -1.5, onType)
            tile("Say it", "mic.fill", PopColors.pink, 1.5, onSay)
            tile("Scan it", "doc.viewfinder", PopColors.mint, -1, onScan)
        }
    }
    private func tile(_ label: String, _ icon: String, _ fill: Color, _ tilt: CGFloat, _ action: @escaping () -> Void) -> some View {
        StickerCard(fill: fill, tilt: tilt, padding: PopSpace.md, action: action) {
            VStack(spacing: PopSpace.xs) {
                Image(systemName: icon).font(.system(size: 21, weight: .bold)).foregroundStyle(PopColors.ink)
                PopText(label, PopTextSpecs.tileLabel).lineLimit(1).minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(label)
    }
}

/// VoiceOver's "toggle" trait arrived in iOS 17 and macOS 14; older systems
/// still hear the label and the "On" / "Off" value.
struct PopToggleTrait: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17, macOS 14, *) {
            content.accessibilityAddTraits(.isToggle)
        } else {
            content
        }
    }
}
