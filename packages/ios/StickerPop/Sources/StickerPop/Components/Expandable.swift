import SwiftUI

/// A card that opens to show more: a header row (16/800 title, optional
/// subtitle, a chevron that flips) and a body that slides open. For FAQs,
/// breakdowns and details that most people won't need.
public struct PopExpandable<Content: View>: View {
    let title: String
    var subtitle: String?
    @State private var open: Bool
    let content: Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(_ title: String, subtitle: String? = nil, initiallyExpanded: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self._open = State(initialValue: initiallyExpanded)
        self.content = content()
    }

    public var body: some View {
        StickerCard(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: PopMotion.sheet)) { open.toggle() }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            PopText(title, PopTextSpecs.rowTitle)
                            if let subtitle { PopText(subtitle, PopTextSpecs.caption) }
                        }
                        Spacer(minLength: PopSpace.sm)
                        Image(systemName: "chevron.down").font(.system(size: 15, weight: .bold)).foregroundStyle(PopColors.ink)
                            .rotationEffect(.degrees(open ? 180 : 0))
                    }
                    .padding(.leading, PopSpace.lg)
                    .padding(.trailing, PopSpace.md)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, minHeight: PopSize.rowMin, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel([title, subtitle].compactMap { $0 }.joined(separator: ", "))
                .accessibilityValue(open ? "Expanded" : "Collapsed")
                .accessibilityAddTraits(.isButton)
                if open {
                    Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider)
                    content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(PopSpace.lg)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .clipped()
    }
}
