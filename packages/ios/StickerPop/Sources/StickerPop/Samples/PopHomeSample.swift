import SwiftUI

/// One transaction in the Home sample. Negative paise are money out.
public struct SampleTransaction: Identifiable {
    public let id = UUID()
    public let title: String
    public let category: String
    public let paise: Int64
    public let date: Date
    public var account: String?
    public var upi: Bool
    public var unsure: Bool

    public init(title: String, category: String, paise: Int64, date: Date, account: String? = nil,
                upi: Bool = false, unsure: Bool = false) {
        self.title = title
        self.category = category
        self.paise = paise
        self.date = date
        self.account = account
        self.upi = upi
        self.unsure = unsure
    }
}

/// The sample's own categories. Mapping data to icons and colours is an app's job.
private let categories: [String: (String, Color)] = [
    "food": ("cup.and.saucer.fill", PopColors.orange),
    "groceries": ("cart.fill", PopColors.mint),
    "transport": ("car.fill", PopColors.blue),
    "bills": ("bolt.fill", PopColors.lilac),
    "shopping": ("bag.fill", PopColors.pink),
    "salary": ("briefcase.fill", PopColors.mint),
]

private func dot(_ category: String) -> AnyView {
    let (icon, color) = categories[category] ?? ("ellipsis", PopColors.white)
    return AnyView(CategoryDot(systemImage: icon, fill: color))
}

/// A fixed clock for screenshots and tests: 18 Nov 2026, 1:12 pm (local time).
public let popSampleNow: Date = {
    var c = DateComponents()
    c.year = 2026; c.month = 11; c.day = 18; c.hour = 13; c.minute = 12
    return Calendar.current.date(from: c)!
}()

public func sampleTransactions(now: Date) -> [SampleTransaction] {
    [
        SampleTransaction(title: "Chai Point", category: "food", paise: -12000, date: now.addingTimeInterval(-40 * 60), account: "HDFC", upi: true),
        SampleTransaction(title: "Uber", category: "transport", paise: -34650, date: now.addingTimeInterval(-4 * 3600), account: "ICICI", upi: true),
        SampleTransaction(title: "BigBasket", category: "groceries", paise: -184520, date: now.addingTimeInterval(-26 * 3600), account: "HDFC", unsure: true),
        SampleTransaction(title: "Salary", category: "salary", paise: 12_500_000, date: now.addingTimeInterval(-3 * 86400), account: "HDFC"),
        SampleTransaction(title: "Electricity bill", category: "bills", paise: -215000, date: now.addingTimeInterval(-5 * 86400), account: "SBI"),
    ]
}

/// A sample Home screen for an expense app, built only from Sticker Pop
/// components: the yellow month card, Type it / Say it / Scan it, a Recent
/// list and the bottom navigation with the tilted pink add button.
public struct PopHomeSample: View {
    let now: Date
    let transactions: [SampleTransaction]
    @State private var tab = 0
    @State private var adding = false
    @StateObject private var snack = PopSnackbarState()

    public init(now: Date = Date(), transactions: [SampleTransaction]? = nil) {
        self.now = now
        self.transactions = transactions ?? sampleTransactions(now: now)
    }

    public var body: some View {
        let spent = transactions.filter { $0.paise < 0 }.reduce(Int64(0)) { $0 - $1.paise }
        let budget: Int64 = 4_000_000
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: PopSpace.lg) {
                    HStack {
                        PopText("Home", PopTextSpecs.screenTitle).accessibilityAddTraits(.isHeader)
                        Spacer()
                        PopIconButton(systemImage: "gearshape.fill", label: "Settings") { snack.show("Settings opens here") }
                    }
                    StickerHeroCard(tilt: PopTilt.hero, action: { snack.show("Month details open here") }) {
                        VStack(alignment: .leading, spacing: PopSpace.xs) {
                            // Wraps instead of squeezing the label when space is tight.
                            PopWrap(spacing: PopSpace.sm, runSpacing: PopSpace.xs) {
                                PopText("Spent in \(PopFormat.formatPopMonth(now))", PopTextSpecs.sectionLabel)
                                StickerBadge("\(spent * 100 / budget)% of budget")
                            }
                            PopText(PopFormat.formatInr(spent), PopTextSpecs.heroAmount).lineLimit(1).minimumScaleFactor(0.6)
                            PopProgressBar(value: Double(spent) / Double(budget), fill: PopColors.pink, label: "Monthly budget used")
                                .padding(.vertical, PopSpace.sm)
                            PopText("\(PopFormat.formatInr(budget - spent)) left of \(PopFormat.formatInrCompact(budget)) · 12 days to go", PopTextSpecs.body)
                        }
                    }
                    PopQuickAddRow(onType: { adding = true }, onSay: { snack.show("Say it opens here") }, onScan: { snack.show("Scan it opens here") })
                        .padding(.vertical, PopSpace.sm)
                    PopSectionLabel("Recent") { PopTextButton("See all") { tab = 1 } }
                    if transactions.isEmpty {
                        PopHintCard("Your spending shows up here. Add one with Type it, Say it or Scan it.")
                    } else {
                        StickerList(transactions) { t in
                            let date = PopFormat.formatPopDate(t.date, now: now)
                            let subtitle = [date, date == "Today" ? PopFormat.formatPopTime(t.date) : nil, t.account].compactMap { $0 }.joined(separator: " · ")
                            StickerListRow(
                                t.title, subtitle: subtitle,
                                amount: PopFormat.formatInr(t.paise, sign: .always),
                                leading: dot(t.category),
                                badge: t.unsure ? AnyView(StickerBadge("Unsure", fill: PopColors.orange)) : (t.upi ? AnyView(StickerBadge("UPI")) : nil)
                            )
                        }
                    }
                }
                .padding(.horizontal, PopSpace.screen)
                .padding(.top, PopSpace.md)
                .padding(.bottom, PopSpace.xxl)
                .popContentWidth()
            }
            .background(PaperBackground())
            PopNavBar(
                items: [
                    PopNavItem(systemImage: "house.fill", label: "Home"),
                    PopNavItem(systemImage: "list.bullet.rectangle", label: "Activity"),
                    PopNavItem(systemImage: "chart.pie.fill", label: "Insights"),
                    PopNavItem(systemImage: "banknote.fill", label: "Wealth"),
                ],
                selection: $tab,
                onAdd: { adding = true }
            )
        }
        .popSnackbarHost(snack)
        .popBottomSheet(isPresented: $adding) {
            AddSheet(onClose: { adding = false }, onSaved: { adding = false; snack.show("Saved") })
        }
    }
}

private struct AddSheet: View {
    let onClose: () -> Void
    let onSaved: () -> Void
    @State private var kind = "Expense"
    @State private var amount = ""
    @State private var note = ""
    @State private var category = "food"
    @State private var error: String?

    var body: some View {
        PopSheet(
            "Add a transaction", primaryLabel: "Save",
            onPrimary: {
                if amount.isEmpty || Double(amount) == 0 { error = "Enter an amount above ₹0." } else { onSaved() }
            },
            error: error,
            trailing: { PopIconButton(systemImage: "xmark", label: "Close", action: onClose) }
        ) {
            PopSegmented(["Expense", "Income", "Transfer"], selection: $kind, label: { $0 })
            PopAmountField(value: $amount, fill: kind == "Income" ? PopColors.mint : PopColors.yellow, label: kind)
                .onChange(of: amount) { _ in error = nil }
            PopWrap {
                ForEach(["food", "groceries", "transport", "bills", "shopping"], id: \.self) { c in
                    let style = categories[c]!
                    PopChip(c.capitalized, selected: category == c, fill: style.1, systemImage: style.0) { category = c }
                }
            }
            PopTextField("Add a note", text: $note)
        }
    }
}

struct PopHomeSample_Previews: PreviewProvider {
    static var previews: some View { PopHomeSample(now: popSampleNow) }
}
