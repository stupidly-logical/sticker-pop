import SwiftUI

/// A short explanation in an ink bubble (white 13/700 text, radius 10) above
/// the content, shown on a tap (or long-press) and hidden after 3 s. Wrap
/// something that isn't itself a button, usually an ⓘ icon in a 48 square.
/// VoiceOver reads the message as a hint.
public struct PopTooltip<Content: View>: View {
    let message: String
    let content: Content
    @State private var shown = false

    public init(_ message: String, @ViewBuilder content: () -> Content) {
        self.message = message
        self.content = content()
    }

    public var body: some View {
        content
            .contentShape(Rectangle())
            .onTapGesture { show() }
            .onLongPressGesture { show() }
            .overlay(alignment: .top) {
                if shown {
                    Text(message)
                        .font(.pop(13, weight: 700))
                        .foregroundStyle(PopColors.white)
                        .padding(.horizontal, PopSpace.md)
                        .padding(.vertical, PopSpace.sm)
                        .background(RoundedRectangle(cornerRadius: PopRadius.badge, style: .continuous).fill(PopColors.ink))
                        .frame(width: 260)
                        .fixedSize(horizontal: false, vertical: true)
                        .alignmentGuide(.top) { $0[.bottom] + PopSpace.sm }
                        .transition(.opacity)
                        .accessibilityHidden(true)
                }
            }
            .animation(.easeOut(duration: PopMotion.fade), value: shown)
            .accessibilityHint(message)
    }

    private func show() {
        shown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + PopMotion.snackbar) { shown = false }
    }
}
