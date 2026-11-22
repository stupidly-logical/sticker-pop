import SwiftUI

/// The page slots to show for `page` of `count` (both from 1): every page
/// when there are 7 or fewer, otherwise always 7 slots with nil for "…",
/// e.g. 1 … 4 5 6 … 12. The same rule runs on every platform.
public func popPageItems(_ page: Int, _ count: Int) -> [Int?] {
    if count <= 7 { return count < 1 ? [] : (1...count).map { Optional($0) } }
    if page <= 4 { return [1, 2, 3, 4, 5, nil, count] }
    if page >= count - 3 { return [1, nil] + (count - 4...count).map { Optional($0) } }
    return [1, nil, page - 1, page, page + 1, nil, count]
}

/// Moves through pages of a long list: previous and next sticker icon
/// buttons around the page numbers (40, radius 12; the current page is
/// yellow with a 2.5 outline). Where the full row doesn't fit (under 404,
/// so on most phones) it shows "Page 3 of 12" between the arrows instead.
public struct PopPagination: View {
    @Binding var page: Int
    let count: Int

    public init(page: Binding<Int>, count: Int) {
        self._page = page
        self.count = count
    }

    private var prev: some View {
        PopIconButton(systemImage: "chevron.left", label: "Previous page") { page -= 1 }.disabled(page <= 1)
    }

    private var next: some View {
        PopIconButton(systemImage: "chevron.right", label: "Next page") { page += 1 }.disabled(page >= count)
    }

    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: PopSpace.xs) {
                prev
                ForEach(Array(popPageItems(page, count).enumerated()), id: \.offset) { _, p in
                    if let p {
                        Button { page = p } label: {
                            PopText("\(p)", p == page ? PopTextSpecs.segmentSelected : PopTextSpecs.segment)
                                .lineLimit(1)
                                .frame(width: 40, height: 40)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(p == page ? PopColors.yellow : .clear))
                                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(PopColors.ink, lineWidth: p == page ? PopBorder.regular : 0))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Page \(p) of \(count)")
                        .accessibilityAddTraits(p == page ? [.isButton, .isSelected] : .isButton)
                    } else {
                        PopText("…", PopTextSpecs.segment).frame(width: 40).accessibilityHidden(true)
                    }
                }
                next
            }
            .fixedSize()
            HStack(spacing: PopSpace.xs) {
                prev
                PopText("Page \(page) of \(count)", PopTextSpecs.rowTitle)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.updatesFrequently)
                next
            }
        }
        .animation(.easeOut(duration: PopMotion.toggle), value: page)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Pages")
    }
}
