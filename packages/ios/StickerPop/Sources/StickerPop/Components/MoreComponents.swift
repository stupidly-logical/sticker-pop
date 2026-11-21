import SwiftUI

// MARK: - Surfaces

/// The lilac empty-state card: one or two sentences saying what will appear
/// here and how to start.
public struct PopHintCard<Action: View>: View {
    let message: String
    var title: String?
    var systemImage: String?
    var fill: Color
    let action: Action

    public init(_ message: String, title: String? = nil, systemImage: String? = nil, fill: Color = PopColors.lilac,
                @ViewBuilder action: () -> Action) {
        self.message = message
        self.title = title
        self.systemImage = systemImage
        self.fill = fill
        self.action = action()
    }

    public var body: some View {
        StickerCard(fill: fill) {
            HStack(alignment: .top, spacing: PopSpace.md) {
                if let systemImage {
                    Image(systemName: systemImage).font(.system(size: 18, weight: .bold)).foregroundStyle(PopColors.ink)
                }
                VStack(alignment: .leading, spacing: PopSpace.xs) {
                    if let title { PopText(title, PopTextSpecs.rowTitle) }
                    PopText(message, PopTextSpecs.body)
                    action
                }
                Spacer(minLength: 0)
            }
        }
    }
}

extension PopHintCard where Action == EmptyView {
    public init(_ message: String, title: String? = nil, systemImage: String? = nil, fill: Color = PopColors.lilac) {
        self.init(message, title: title, systemImage: systemImage, fill: fill) { EmptyView() }
    }
}

/// A small caps section label such as "RECENT", usually with a trailing text button.
public struct PopSectionLabel<Trailing: View>: View {
    let text: String
    let trailing: Trailing

    public init(_ text: String, @ViewBuilder trailing: () -> Trailing) {
        self.text = text
        self.trailing = trailing()
    }

    public var body: some View {
        HStack {
            PopText(text, PopTextSpecs.sectionLabel).accessibilityAddTraits(.isHeader)
            Spacer()
            trailing
        }
    }
}

extension PopSectionLabel where Trailing == EmptyView {
    public init(_ text: String) { self.init(text) { EmptyView() } }
}

// MARK: - Inputs

/// The big amount entry: a bright card with a currency prefix at the same
/// 32/800 size. Choose `fill` by meaning (e.g. yellow for money out, mint
/// for money in). Only digits and up to two decimals are accepted.
public struct PopAmountField: View {
    @Binding var value: String
    var fill: Color
    var label: String
    var currencySymbol: String
    var error: String?

    public init(value: Binding<String>, fill: Color = PopColors.yellow, label: String = "Amount",
                currencySymbol: String = "₹", error: String? = nil) {
        self._value = value
        self.fill = fill
        self.label = label
        self.currencySymbol = currencySymbol
        self.error = error
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: PopSpace.sm) {
            StickerCard(fill: fill, padding: PopSpace.lg) {
                VStack(alignment: .leading, spacing: 2) {
                    PopText(label, PopTextSpecs.sectionLabel)
                    HStack(spacing: PopSpace.xs) {
                        PopText(currencySymbol, PopTextSpecs.amountEntry)
                        TextField("", text: Binding(
                            get: { value },
                            set: { new in if PopAmountField.isValid(new) { value = new } }
                        ), prompt: Text("0").foregroundColor(PopColors.inkMuted))
                        .font(.pop(PopTextSpecs.amountEntry.size, weight: PopTextSpecs.amountEntry.weight))
                        .monospacedDigit()
                        .foregroundStyle(PopColors.ink)
                        .tint(PopColors.ink)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .accessibilityLabel(label)
                    }
                }
            }
            if let error { PopFormError(error) }
        }
    }

    static func isValid(_ s: String) -> Bool {
        s.range(of: #"^\d*\.?\d{0,2}$"#, options: .regularExpression) != nil
    }
}

/// One labelled line inside a details card: a 76-wide muted label column,
/// the value on the right, min height 52 and a 2px divider under each row.
public struct PopFieldRow<Content: View>: View {
    let label: String
    var showChevron: Bool
    var divider: Bool
    var action: (() -> Void)?
    let content: Content

    public init(_ label: String, showChevron: Bool = false, divider: Bool = true, action: (() -> Void)? = nil,
                @ViewBuilder content: () -> Content) {
        self.label = label
        self.showChevron = showChevron
        self.divider = divider
        self.action = action
        self.content = content()
    }

    public var body: some View {
        let row = HStack(spacing: 0) {
            PopText(label, PopTextSpecs.fieldLabel).frame(width: PopSize.fieldLabelColumn, alignment: .leading)
            content.frame(maxWidth: .infinity, alignment: .leading)
            if showChevron {
                Image(systemName: "chevron.right").font(.system(size: 15, weight: .bold)).foregroundStyle(PopColors.ink)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 6)
        .frame(minHeight: PopSize.rowMin)
        .contentShape(Rectangle())
        VStack(spacing: 0) {
            if let action {
                Button(action: action) { row }.buttonStyle(.plain)
            } else {
                row
            }
            if divider { Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider) }
        }
    }
}
