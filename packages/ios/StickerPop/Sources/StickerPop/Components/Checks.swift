import SwiftUI

/// The three states a checkbox can show.
public enum PopCheckState {
    case off, on, mixed
}

/// The checkbox drawing on its own: a 24 rounded square (radius 7). White
/// with a 2 ink outline when off; mint with a 2.5 outline and an ink tick when
/// on; a dash when mixed (some, not all).
public struct PopCheckboxMark: View {
    let state: PopCheckState
    @Environment(\.isEnabled) private var enabled

    public init(_ state: PopCheckState) { self.state = state }

    public var body: some View {
        let on = state != .off
        let fill = !enabled ? (on ? PopColors.divider : PopColors.paper) : (on ? PopColors.mint : PopColors.white)
        RoundedRectangle(cornerRadius: PopRadius.checkbox, style: .continuous)
            .fill(fill)
            .overlay(RoundedRectangle(cornerRadius: PopRadius.checkbox, style: .continuous)
                .strokeBorder(PopColors.ink, lineWidth: on ? PopBorder.regular : PopBorder.thin))
            .overlay {
                if state != .off {
                    PopCheckGlyph(dash: state == .mixed)
                        .stroke(enabled ? PopColors.ink : PopColors.inkMuted, style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
                }
            }
            .frame(width: PopSize.checkbox, height: PopSize.checkbox)
            .animation(.easeOut(duration: PopMotion.toggle), value: state)
    }
}

struct PopCheckGlyph: Shape {
    var dash: Bool
    func path(in r: CGRect) -> Path {
        var p = Path()
        if dash {
            p.move(to: CGPoint(x: r.width * 0.28, y: r.height * 0.5))
            p.addLine(to: CGPoint(x: r.width * 0.72, y: r.height * 0.5))
        } else {
            p.move(to: CGPoint(x: r.width * 0.24, y: r.height * 0.52))
            p.addLine(to: CGPoint(x: r.width * 0.43, y: r.height * 0.7))
            p.addLine(to: CGPoint(x: r.width * 0.77, y: r.height * 0.32))
        }
        return p
    }
}

/// A checkbox padded to a 48 tap target. Pair it with a label: usually use
/// `PopCheckboxRow`.
public struct PopCheckbox: View {
    let label: String
    let state: PopCheckState
    let action: () -> Void

    /// A checkbox showing `state`; `action` decides what a tap does (a mixed box usually checks everything).
    public init(_ label: String, state: PopCheckState, action: @escaping () -> Void) {
        self.label = label
        self.state = state
        self.action = action
    }

    /// A plain on/off checkbox.
    public init(_ label: String, isOn: Binding<Bool>) {
        self.init(label, state: isOn.wrappedValue ? .on : .off) { isOn.wrappedValue.toggle() }
    }

    public var body: some View {
        Button(action: action) {
            PopCheckboxMark(state)
                .frame(width: PopSize.tapTarget, height: PopSize.tapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityValue(state == .on ? "Checked" : state == .mixed ? "Partly checked" : "Not checked")
    }
}

/// The radio drawing on its own: a 24 circle, white with a 2 ink outline;
/// selected it fills yellow with a 2.5 outline and a 10 ink dot.
public struct PopRadioMark: View {
    let selected: Bool
    @Environment(\.isEnabled) private var enabled

    public init(selected: Bool) { self.selected = selected }

    public var body: some View {
        let fill = !enabled ? (selected ? PopColors.divider : PopColors.paper) : (selected ? PopColors.yellow : PopColors.white)
        Circle()
            .fill(fill)
            .overlay(Circle().strokeBorder(PopColors.ink, lineWidth: selected ? PopBorder.regular : PopBorder.thin))
            .overlay {
                if selected {
                    Circle().fill(enabled ? PopColors.ink : PopColors.inkMuted).frame(width: PopSize.radioDot, height: PopSize.radioDot)
                }
            }
            .frame(width: PopSize.checkbox, height: PopSize.checkbox)
            .animation(.easeOut(duration: PopMotion.toggle), value: selected)
    }
}

/// A radio button padded to a 48 tap target; every radio in a group shares
/// `selection`. Usually use `PopRadioRow`.
public struct PopRadio<Value: Hashable>: View {
    let label: String
    let value: Value
    @Binding var selection: Value

    public init(_ label: String, value: Value, selection: Binding<Value>) {
        self.label = label
        self.value = value
        self._selection = selection
    }

    public var body: some View {
        Button { selection = value } label: {
            PopRadioMark(selected: selection == value)
                .frame(width: PopSize.tapTarget, height: PopSize.tapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(selection == value ? [.isButton, .isSelected] : .isButton)
    }
}

/// A tappable row with a checkbox, a 16/700 label and an optional caption.
public struct PopCheckboxRow: View {
    let label: String
    var caption: String?
    let state: PopCheckState
    let action: () -> Void
    @Environment(\.isEnabled) private var enabled

    public init(_ label: String, caption: String? = nil, state: PopCheckState, action: @escaping () -> Void) {
        self.label = label
        self.caption = caption
        self.state = state
        self.action = action
    }

    public init(_ label: String, caption: String? = nil, isOn: Binding<Bool>) {
        self.init(label, caption: caption, state: isOn.wrappedValue ? .on : .off) { isOn.wrappedValue.toggle() }
    }

    public var body: some View {
        Button(action: action) {
            PopChoiceRowLayout(label: label, caption: caption, enabled: enabled) { PopCheckboxMark(state) }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(caption.map { "\(label), \($0)" } ?? label)
        .accessibilityValue(state == .on ? "Checked" : state == .mixed ? "Partly checked" : "Not checked")
        .accessibilityAddTraits(.isButton)
    }
}

/// A tappable row with a radio, a 16/700 label and an optional caption.
public struct PopRadioRow<Value: Hashable>: View {
    let label: String
    var caption: String?
    let value: Value
    @Binding var selection: Value
    @Environment(\.isEnabled) private var enabled

    public init(_ label: String, caption: String? = nil, value: Value, selection: Binding<Value>) {
        self.label = label
        self.caption = caption
        self.value = value
        self._selection = selection
    }

    public var body: some View {
        Button { selection = value } label: {
            PopChoiceRowLayout(label: label, caption: caption, enabled: enabled) { PopRadioMark(selected: selection == value) }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(caption.map { "\(label), \($0)" } ?? label)
        .accessibilityAddTraits(selection == value ? [.isButton, .isSelected] : .isButton)
    }
}

struct PopChoiceRowLayout<Control: View>: View {
    let label: String
    let caption: String?
    let enabled: Bool
    @ViewBuilder let control: Control

    var body: some View {
        HStack(spacing: PopSpace.md) {
            control
            VStack(alignment: .leading, spacing: 2) {
                PopText(label, PopTextSpecs.input, color: enabled ? PopColors.ink : PopColors.inkMuted)
                if let caption { PopText(caption, PopTextSpecs.caption) }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, PopSpace.lg)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: PopSize.rowMin, alignment: .leading)
        .contentShape(Rectangle())
    }
}
