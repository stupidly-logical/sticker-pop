import SwiftUI

/// A whole-screen state for when there's nothing to show yet, or something
/// went wrong: a 96 sticker tile with a 44 icon, tilted −4°, then a 22/800
/// title, a short 15/600 message and up to two actions, all centred. Lilac
/// for empty (the default), orange for errors and offline.
public struct PopEmptyState: View {
    let systemImage: String
    let title: String
    let message: String
    var fill: Color
    var actionLabel: String?
    var onAction: () -> Void
    var secondaryLabel: String?
    var onSecondary: () -> Void

    public init(systemImage: String, title: String, message: String, fill: Color = PopColors.lilac,
                actionLabel: String? = nil, onAction: @escaping () -> Void = {},
                secondaryLabel: String? = nil, onSecondary: @escaping () -> Void = {}) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.fill = fill
        self.actionLabel = actionLabel
        self.onAction = onAction
        self.secondaryLabel = secondaryLabel
        self.onSecondary = onSecondary
    }

    public var body: some View {
        VStack(spacing: 0) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(PopColors.ink)
                .frame(width: PopSize.stateTile, height: PopSize.stateTile)
                .sticker(fill: fill, radius: PopRadius.card, shadow: PopShadow.large)
                .popTilt(-4)
                .accessibilityHidden(true)
            PopText(title, PopTextSpecs.sheetTitle)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, PopSpace.xxl)
            PopText(message, PopTextSpecs.body, color: PopColors.inkMuted)
                .multilineTextAlignment(.center)
                .padding(.top, PopSpace.sm)
            if let actionLabel { StickerButton(actionLabel, action: onAction).padding(.top, PopSpace.xl) }
            if let secondaryLabel { PopTextButton(secondaryLabel, action: onSecondary).padding(.top, PopSpace.sm) }
        }
        .frame(maxWidth: 340)
        .padding(PopSpace.xl)
        .frame(maxWidth: .infinity)
    }
}
