import SwiftUI

/// The pull-to-refresh sticker: a 44 white circle with a 2 ink outline and
/// a 3 hard shadow. While pulling, an ink ring fills with `progress` (0 to
/// 1, full means "let go to refresh"); with `progress` nil it spins. Use it
/// for custom refresh flows; lists get the system gesture through
/// `.popRefreshable`.
public struct PopRefreshIndicator: View {
    var progress: Double?

    public init(progress: Double? = nil) {
        self.progress = progress
    }

    public var body: some View {
        ZStack {
            if let progress {
                ZStack {
                    Circle().stroke(PopColors.divider, lineWidth: 2.5)
                    Circle().trim(from: 0, to: min(max(progress, 0), 1))
                        .stroke(PopColors.ink, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 17.5, height: 17.5)
                .accessibilityHidden(true)
            } else {
                PopSpinner(size: 20, label: "Refreshing")
            }
        }
        .frame(width: 44, height: 44)
        .background(Circle().fill(PopColors.white))
        .overlay(Circle().strokeBorder(PopColors.ink, lineWidth: PopBorder.thin))
        .background(Circle().fill(PopColors.ink).offset(x: PopShadow.small, y: PopShadow.small))
    }
}

public extension View {
    /// Pull down from the top of a List or ScrollView to refresh. Uses the
    /// system gesture and spinner (tinted ink), which VoiceOver already
    /// supports; `action` runs until the refresh is done.
    func popRefreshable(_ action: @escaping @Sendable () async -> Void) -> some View {
        refreshable { await action() }.tint(PopColors.ink)
    }
}
