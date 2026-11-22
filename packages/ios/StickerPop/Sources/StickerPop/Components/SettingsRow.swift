import SwiftUI

/// A row for settings lists, inside a sticker list: an optional icon, a
/// 16/700 title with an optional subtitle, and on the right either a switch
/// (`isOn`), or an optional muted `value` and a chevron when it opens
/// something (`action`). The whole row is the tap target.
public struct PopSettingsRow: View {
    let title: String
    var subtitle: String?
    var systemImage: String?
    var value: String?
    var action: (() -> Void)?
    var isOn: Binding<Bool>?

    /// A row that opens something, or just shows a value.
    public init(_ title: String, subtitle: String? = nil, systemImage: String? = nil, value: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.value = value
        self.action = action
        self.isOn = nil
    }

    /// A row with a switch.
    public init(_ title: String, subtitle: String? = nil, systemImage: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isOn = isOn
    }

    public var body: some View {
        Button {
            if let isOn { isOn.wrappedValue.toggle() } else { action?() }
        } label: {
            HStack(spacing: PopSpace.md) {
                if let systemImage {
                    Image(systemName: systemImage).font(.system(size: 18, weight: .bold)).foregroundStyle(PopColors.ink).frame(width: PopSize.iconNav)
                }
                VStack(alignment: .leading, spacing: 2) {
                    PopText(title, PopTextSpecs.input)
                    if let subtitle { PopText(subtitle, PopTextSpecs.caption) }
                }
                Spacer(minLength: PopSpace.sm)
                if let isOn {
                    PopSwitch(isOn: isOn, label: title).allowsHitTesting(false)
                } else {
                    if let value { PopText(value, PopTextSpecs.input, color: PopColors.inkMuted).lineLimit(1) }
                    if action != nil { Image(systemName: "chevron.right").font(.system(size: 15, weight: .bold)).foregroundStyle(PopColors.ink) }
                }
            }
            .padding(.leading, PopSpace.lg)
            .padding(.trailing, PopSpace.md)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: PopSize.rowMin, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isOn == nil && action == nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([title, subtitle, value].compactMap { $0 }.joined(separator: ", "))
        .accessibilityValue(isOn.map { $0.wrappedValue ? "On" : "Off" } ?? "")
        .accessibilityAddTraits(isOn == nil && action == nil ? [] : .isButton)
    }
}
