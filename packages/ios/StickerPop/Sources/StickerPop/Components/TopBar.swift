import SwiftUI

/// The bar at the top of a screen. Compact (the default) is for
/// sub-screens: a back sticker button when `onBack` is set, a one-line 22/800
/// title and up to two actions, 64 high. `large` is for main screens, at the
/// top of the scrolling content: the 34/800 screen title (up to two lines).
///
/// When content scrolls under it (`scrolled`), it fills with paper and draws a
/// 2.5 ink line along its bottom.
public struct PopTopBar<Actions: View>: View {
    let title: String
    var large: Bool
    var scrolled: Bool
    var backLabel: String
    var onBack: (() -> Void)?
    let actions: Actions

    public init(_ title: String, large: Bool = false, scrolled: Bool = false, backLabel: String = "Back",
                onBack: (() -> Void)? = nil, @ViewBuilder actions: () -> Actions) {
        self.title = title
        self.large = large
        self.scrolled = scrolled
        self.backLabel = backLabel
        self.onBack = onBack
        self.actions = actions()
    }

    public var body: some View {
        HStack(spacing: PopSpace.sm) {
            if let onBack {
                PopIconButton(systemImage: "arrow.left", label: backLabel, action: onBack)
                    .padding(.trailing, PopSpace.xs)
            }
            PopText(title, large ? PopTextSpecs.screenTitle : PopTextSpecs.sheetTitle)
                .lineLimit(large ? 2 : 1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            actions.padding(.leading, PopSpace.xs)
        }
        .padding(.horizontal, PopSpace.screen)
        .padding(.vertical, large ? PopSpace.sm : 0)
        .frame(maxWidth: .infinity, minHeight: PopSize.topBar - PopBorder.regular)
        .padding(.bottom, PopBorder.regular)
        .background(scrolled ? PopColors.paper : Color.clear)
        .overlay(alignment: .bottom) {
            Rectangle().fill(PopColors.ink).frame(height: PopBorder.regular).opacity(scrolled ? 1 : 0)
        }
        .animation(.easeOut(duration: PopMotion.fade), value: scrolled)
    }
}

extension PopTopBar where Actions == EmptyView {
    public init(_ title: String, large: Bool = false, scrolled: Bool = false, backLabel: String = "Back",
                onBack: (() -> Void)? = nil) {
        self.init(title, large: large, scrolled: scrolled, backLabel: backLabel, onBack: onBack) { EmptyView() }
    }
}
