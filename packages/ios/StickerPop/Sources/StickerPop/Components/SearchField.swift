import SwiftUI

/// A search box: a text field (white, 2 ink outline, radius 14, 48 high)
/// with a search icon, a ✕ that clears it while it has text, and an
/// optional "Cancel" text button after it (`onCancel`).
public struct PopSearchField: View {
    let hint: String
    @Binding var text: String
    var onSubmit: () -> Void
    var onCancel: (() -> Void)?
    var cancelLabel: String
    @FocusState private var focused: Bool

    public init(_ hint: String = "Search", text: Binding<String>, onSubmit: @escaping () -> Void = {},
                cancelLabel: String = "Cancel", onCancel: (() -> Void)? = nil) {
        self.hint = hint
        self._text = text
        self.onSubmit = onSubmit
        self.cancelLabel = cancelLabel
        self.onCancel = onCancel
    }

    public var body: some View {
        HStack(spacing: PopSpace.md) {
            HStack(spacing: PopSpace.sm) {
                Image(systemName: "magnifyingglass").font(.system(size: 17, weight: .bold)).foregroundStyle(PopColors.ink)
                    .accessibilityHidden(true)
                TextField("", text: $text, prompt: Text(hint).foregroundColor(PopColors.inkMuted))
                    .font(.pop(PopTextSpecs.input.size, weight: PopTextSpecs.input.weight))
                    .foregroundStyle(PopColors.ink)
                    .tint(PopColors.ink)
                    .focused($focused)
                    .submitLabel(.search)
                    .onSubmit(onSubmit)
                if !text.isEmpty {
                    Button { text = ""; focused = true } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 18, weight: .bold)).foregroundStyle(PopColors.ink)
                            .frame(width: 40, height: 40).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.leading, PopSpace.md)
            .padding(.trailing, text.isEmpty ? PopSpace.md : PopSpace.xs)
            .frame(minHeight: PopSize.tapTarget)
            .sticker(fill: PopColors.white, radius: PopRadius.field, border: focused ? PopBorder.regular : PopBorder.thin, shadow: 0)
            if let onCancel { PopTextButton(cancelLabel, action: onCancel) }
        }
    }
}
