import SwiftUI

/// What a `PopBanner` is about; sets its fill and default icon.
public enum PopBannerTone {
    case info, warning, success
}

/// A message that stays in the page until it's dealt with: a bright sticker
/// card (info blue, warning orange, success mint) with an icon, an optional
/// 16/800 title, a 15/600 message, an optional text-button action and an
/// optional close button. Never red.
public struct PopBanner: View {
    let message: String
    var title: String?
    var tone: PopBannerTone
    var systemImage: String?
    var actionLabel: String?
    var onAction: () -> Void
    var onDismiss: (() -> Void)?

    public init(_ message: String, title: String? = nil, tone: PopBannerTone = .info, systemImage: String? = nil,
                actionLabel: String? = nil, onAction: @escaping () -> Void = {}, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.title = title
        self.tone = tone
        self.systemImage = systemImage
        self.actionLabel = actionLabel
        self.onAction = onAction
        self.onDismiss = onDismiss
    }

    private var fill: Color {
        switch tone { case .info: return PopColors.blue; case .warning: return PopColors.orange; case .success: return PopColors.mint }
    }
    private var icon: String {
        systemImage ?? { switch tone { case .info: return "info.circle"; case .warning: return "exclamationmark.triangle"; case .success: return "checkmark.circle" } }()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: PopSpace.md) {
            Image(systemName: icon).font(.system(size: 18, weight: .bold)).foregroundStyle(PopColors.ink).padding(.top, 2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                if let title { PopText(title, PopTextSpecs.rowTitle) }
                PopText(message, PopTextSpecs.body)
                if let actionLabel { PopTextButton(actionLabel, underline: true, action: onAction).padding(.top, PopSpace.xs) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark").font(.system(size: 15, weight: .bold)).foregroundStyle(PopColors.ink)
                        .frame(width: 40, height: 40).contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss")
            }
        }
        .padding(.leading, PopSpace.lg)
        .padding(.trailing, onDismiss == nil ? PopSpace.lg : PopSpace.sm)
        .padding(.vertical, PopSpace.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sticker(fill: fill, radius: PopRadius.card)
        .accessibilityElement(children: .contain)
    }
}
