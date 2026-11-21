import SwiftUI

/// A row of tabs for switching between views of one screen. Unselected tabs
/// are plain 15/700 muted text; the selected one sits in a yellow pill with a
/// 2 ink outline and 800 text. Scrolls sideways when the tabs don't fit.
public struct PopTabs: View {
    let tabs: [String]
    @Binding var selection: Int

    public init(_ tabs: [String], selection: Binding<Int>) {
        self.tabs = tabs
        self._selection = selection
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PopSpace.xs) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { i, t in
                    let on = i == selection
                    Button { selection = i } label: {
                        PopText(t, on ? PopTextSpecs.segmentSelected : PopTextSpecs.segment, color: on ? PopColors.ink : PopColors.inkMuted)
                            .lineLimit(1)
                            .padding(.horizontal, PopSpace.lg)
                            .frame(minWidth: PopSize.tapTarget, minHeight: PopSize.chip)
                            .background(Capsule().fill(on ? PopColors.yellow : Color.clear))
                            .overlay(Capsule().strokeBorder(PopColors.ink, lineWidth: on ? PopBorder.thin : 0))
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(t)
                    .accessibilityValue("Tab \(i + 1) of \(tabs.count)")
                    .accessibilityAddTraits(on ? [.isButton, .isSelected] : .isButton)
                    .animation(.easeOut(duration: PopMotion.toggle), value: selection)
                }
            }
        }
    }
}
