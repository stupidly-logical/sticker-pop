import SwiftUI

private let slices = [
    PopDatum("Food", value: 32, color: PopColors.orange),
    PopDatum("Groceries", value: 24, color: PopColors.mint),
    PopDatum("Transport", value: 18, color: PopColors.blue),
    PopDatum("Bills", value: 16, color: PopColors.lilac),
    PopDatum("Shopping", value: 10, color: PopColors.pink),
]

private let galleryToday = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 11, day: 21))!

private let accounts = [
    PopSelectOption("HDFC", value: "hdfc", systemImage: "building.columns", caption: "Savings ·· 4821"),
    PopSelectOption("ICICI", value: "icici", systemImage: "creditcard", caption: "Credit card ·· 4411"),
    PopSelectOption("Cash", value: "cash", systemImage: "banknote"),
]

private extension View {
    /// A rounded, outlined frame for showing a bar out of context.
    func galleryFrame() -> some View {
        clipShape(RoundedRectangle(cornerRadius: PopRadius.tile, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: PopRadius.tile, style: .continuous).strokeBorder(PopColors.divider, lineWidth: PopBorder.divider))
    }
}

private struct GallerySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: PopSpace.md) {
            PopText(title, PopTextSpecs.sectionHeading).accessibilityAddTraits(.isHeader)
            content
        }
        .padding(.top, PopSpace.section + PopSpace.sm)
    }
}


/// Every Sticker Pop component in each of its states (rest, selected,
/// disabled, error), plus colour swatches. `onOpenHome` opens the Home sample.
public struct PopGallery: View {
    var onOpenHome: () -> Void
    @State private var segment = "Expense"
    @State private var chip = "Food"
    @State private var switchOn = true
    @State private var syncOn = false
    @State private var nav = 0
    @State private var tags = ["Office", "Trip"]
    @State private var note = ""
    @State private var payee = ""
    @State private var account = "HDFC ·· 4821"
    @State private var amount = "1250.50"
    @State private var account: String? = "hdfc"
    @State private var paidFrom: String? = nil
    @State private var transfers = true
    @State private var query = ""
    @State private var tab = 0
    @State private var reminder = true
    @State private var budget = 12000.0
    @State private var people = 2
    @State private var typed = "450"
    @State private var tripTags = ["Goa", "Family"]
    @State private var date = galleryToday
    @State private var pickDate = false
    @State private var hideSmall = false
    @State private var period = "Month"
    @State private var name = ""
    @State private var showSheet = false
    @State private var showDialog = false
    @StateObject private var snack = PopSnackbarState()
    @StateObject private var tour = PopTourState()

    public init(onOpenHome: @escaping () -> Void = {}) { self.onOpenHome = onOpenHome }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    PopText("Sticker Pop", PopTextSpecs.welcomeTitle)
                    Spacer()
                    PopIconButton(systemImage: "house.fill", label: "Open the Home sample", fill: PopColors.yellow, action: onOpenHome)
                }
                PopText("A bold, friendly design system", PopTextSpecs.body)

                GallerySection(title: "Colour") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: PopSpace.md)], spacing: PopSpace.md) {
                        ForEach([("paper", PopColors.paper), ("ink", PopColors.ink), ("inkMuted", PopColors.inkMuted),
                                 ("white", PopColors.white), ("divider", PopColors.divider), ("yellow", PopColors.yellow),
                                 ("pink", PopColors.pink), ("blue", PopColors.blue), ("mint", PopColors.mint),
                                 ("lilac", PopColors.lilac), ("orange", PopColors.orange)], id: \.0) { item in
                            PopText(item.0, PopTextSpecs.chipSelected, color: item.0.hasPrefix("ink") ? PopColors.white : PopColors.ink)
                                .padding(PopSpace.sm)
                                .frame(maxWidth: .infinity, minHeight: 64, alignment: .bottomLeading)
                                .sticker(fill: item.1, radius: PopRadius.tile, shadow: PopShadow.small)
                        }
                    }
                }

                GallerySection(title: "Type") {
                    PopText("Screen title 34", PopTextSpecs.screenTitle)
                    PopText("₹1,25,000", PopTextSpecs.heroAmount)
                    PopText("Sheet title 22", PopTextSpecs.sheetTitle)
                    PopText("Row title 16", PopTextSpecs.rowTitle)
                    PopText("Body 15 for sentences people read.", PopTextSpecs.body)
                    PopText("Caption 13 in muted ink", PopTextSpecs.caption)
                    PopText("Section label", PopTextSpecs.sectionLabel)
                }

                GallerySection(title: "StickerCard") {
                    StickerCard { PopText("Default: white, 4/4 shadow", PopTextSpecs.body) }
                    StickerHeroCard {
                        VStack(alignment: .leading) {
                            PopText("Net worth", PopTextSpecs.sectionLabel)
                            PopText("₹12,40,500", PopTextSpecs.heroAmount)
                        }
                    }
                    HStack(spacing: PopSpace.md) {
                        StickerInfoCard { PopText("Info, blue", PopTextSpecs.body) }
                        StickerInfoCard(fill: PopColors.mint) { PopText("Info, mint", PopTextSpecs.body) }
                    }
                    // Gradient fills come from tokens (PopGradients).
                    HStack(spacing: PopSpace.md) {
                        ForEach(PopGradients.byName.keys.sorted(), id: \.self) { name in
                            StickerCard(gradient: PopGradients.byName[name], padding: PopSpace.lg) {
                                PopText(name, PopTextSpecs.chipSelected).lineLimit(1).frame(maxWidth: .infinity)
                            }
                        }
                    }
                    PopHintCard("Goals you add show up here. Tap Add goal to start one.", systemImage: "lightbulb.fill")
                }

                GallerySection(title: "Buttons") {
                    StickerButton("Save") { snack.show("Saved") }
                    StickerButton("Save (disabled)") {}.disabled(true)
                    StickerButton("Saving", busy: true) {}
                    PopWrap {
                        PopTextButton("Cancel") {}
                        PopTextButton("Skip", underline: true) {}
                        PopTextButton("Disabled") {}.disabled(true)
                    }
                    PopWrap(spacing: PopSpace.md, runSpacing: PopSpace.md) {
                        PopIconButton(systemImage: "chevron.left", label: "Back") {}
                        PopIconButton(systemImage: "mic.fill", label: "Voice", fill: PopColors.pink) {}
                        PopIconButton(systemImage: "slider.horizontal.3", label: "Filters on", fill: PopColors.yellow, selected: true) {}
                        PopIconButton(systemImage: "xmark", label: "Close") {}.disabled(true)
                    }
                }

                GallerySection(title: "PopChip") {
                    VStack(alignment: .leading, spacing: PopSpace.sm) {
                        PopWrap {
                            ForEach(["Food", "Travel", "Bills"], id: \.self) { c in
                                PopChip(c, selected: chip == c) { chip = c }
                            }
                            PopChip("Mint", selected: true, fill: PopColors.mint, systemImage: "leaf.fill") {}
                        }
                        PopWrap {
                            PopChip("Disabled", selected: false) {}.disabled(true)
                            ForEach(tags, id: \.self) { t in
                                PopChip(t, selected: false, onRemove: { tags.removeAll { $0 == t } }) {}
                            }
                        }
                    }
                    .popTourTarget("chips")
                }

                GallerySection(title: "PopSegmented") {
                    PopSegmented(["Expense", "Income", "Transfer"], selection: $segment, label: { $0 })
                    PopSegmented(["Month", "Year"], selection: .constant("Month"), label: { $0 }).disabled(true)
                }

                GallerySection(title: "PopSwitch") {
                    StickerCard(padding: 0) {
                        VStack(spacing: 0) {
                            PopFieldRow("Reminders", divider: false) {
                                HStack { Spacer(); PopSwitch(isOn: $switchOn, label: "Reminders") }
                            }
                            PopFieldRow("Sync", divider: false) {
                                HStack { Spacer(); PopSwitch(isOn: $syncOn, label: "Sync").disabled(true) }
                            }
                        }
                    }
                }

                GallerySection(title: "Text fields") {
                    PopTextField("Add a note", text: $note, label: "Note")
                    PopTextField("Who was it?", text: $payee, label: "Payee", error: "Add who you paid.")
                    PopTextField("Account", text: $account, label: "Account").disabled(true)
                    PopSearchField("Search transactions", text: $query, onCancel: { query = "" })
                    PopAmountField(value: $amount, label: "Expense")
                    StickerCard(padding: 0) {
                        VStack(spacing: 0) {
                            PopFieldRow("Paid to") { PopText("Chai Point", PopTextSpecs.rowTitle) }
                            PopFieldRow("Account", showChevron: true, divider: false, action: {}) { PopText("HDFC ·· 4821", PopTextSpecs.rowTitle) }
                        }
                    }
                }

                GallerySection(title: "Tag input") {
                    PopTagInput(tags: $tripTags, label: "Tags")
                }

                GallerySection(title: "Select and menu") {
                    PopSelect(accounts, selection: $account, label: "Account")
                    PopSelect(accounts, selection: $paidFrom, label: "Paid from", hint: "Choose an account",
                              error: "Choose where the money came from.")
                    HStack {
                        PopText("Chai Point", PopTextSpecs.rowTitle)
                        Spacer()
                        PopMenu([
                            .item("Edit", systemImage: "pencil") { snack.show("Edit opens here") },
                            .item("Duplicate", systemImage: "doc.on.doc") { snack.show("Duplicated") },
                            .divider,
                            .item("Delete", systemImage: "trash", destructive: true) { snack.show("Deleted", actionLabel: "Undo") },
                        ]) { toggle in
                            PopIconButton(systemImage: "ellipsis", label: "More for Chai Point", action: toggle)
                        }
                    }
                }

                GallerySection(title: "Checkbox and radio") {
                    StickerCard(padding: 0) {
                        VStack(spacing: 0) {
                            PopCheckboxRow("Include transfers", caption: "Moving money between your own accounts", isOn: $transfers)
                            Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider)
                            PopCheckboxRow("Hide small amounts", isOn: $hideSmall)
                            Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider)
                            PopCheckboxRow("Sync", state: .on) {}.disabled(true)
                        }
                    }
                    StickerCard(padding: 0) {
                        VStack(spacing: 0) {
                            ForEach(["Week", "Month", "Year"], id: \.self) { p in
                                if p != "Week" { Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider) }
                                PopRadioRow(p, value: p, selection: $period)
                            }
                        }
                    }
                }

                GallerySection(title: "Dates") {
                    PopDateTiles((0...4).reversed().map { Calendar(identifier: .gregorian).date(byAdding: .day, value: -$0, to: galleryToday)! },
                                 selection: $date, today: galleryToday) { pickDate = true }
                    StickerCard { PopCalendar(selection: $date, today: galleryToday, in: Date.distantPast...galleryToday) }
                }

                GallerySection(title: "Slider") {
                    HStack {
                        PopText("Monthly budget", PopTextSpecs.fieldLabel)
                        Spacer()
                        PopText(PopFormat.formatInr(Int64(budget * 100)), PopTextSpecs.rowAmount)
                    }
                    PopSlider("Monthly budget", value: $budget, in: 0...20000, step: 500) { PopFormat.formatInr(Int64($0 * 100)) }
                    PopSlider("Locked", value: .constant(0.3)).disabled(true)
                }

                GallerySection(title: "Number keypad") {
                    StickerCard(fill: PopColors.yellow) { PopText("₹" + (typed.isEmpty ? "0" : typed), PopTextSpecs.amountEntry).frame(maxWidth: .infinity, alignment: .leading) }
                    PopKeypad { typed = applyPopKey(typed, $0) }
                }

                GallerySection(title: "Stepper") {
                    HStack {
                        PopText("Split between", PopTextSpecs.input)
                        Spacer()
                        PopStepper("People", value: $people, in: 1...20)
                    }
                }

                GallerySection(title: "Settings rows") {
                    StickerCard(padding: 0) {
                        VStack(spacing: 0) {
                            PopSettingsRow("Language", systemImage: "character.bubble", value: "English") {}
                            Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider)
                            PopSettingsRow("Daily reminder", subtitle: "At 9 pm", systemImage: "bell", isOn: $reminder)
                            Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider)
                            PopSettingsRow("Export data", systemImage: "square.and.arrow.up") {}
                            Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider)
                            PopSettingsRow("Version", systemImage: "info.circle", value: "0.1.0")
                        }
                    }
                }

                GallerySection(title: "Empty and error screens") {
                    StickerCard {
                        PopEmptyState(systemImage: "list.bullet.rectangle", title: "No transactions yet",
                                      message: "Add your first one with Type it, Say it or Scan it.", actionLabel: "Add a transaction")
                    }
                    StickerCard {
                        PopEmptyState(systemImage: "icloud.slash", title: "Couldn't load prices",
                                      message: "Check your connection and try again. Your own data is safe on this phone.",
                                      fill: PopColors.orange, actionLabel: "Try again", secondaryLabel: "Not now")
                    }
                }

                GallerySection(title: "Expandable cards") {
                    PopExpandable("Where does my data go?", initiallyExpanded: true) {
                        PopText("Nowhere. Everything stays on this phone unless you export it.", PopTextSpecs.body)
                    }
                    PopExpandable("Food, Nov 2026", subtitle: "₹3,240 across 14 transactions") {
                        PopText("Chai Point ₹1,120 · Swiggy ₹980 · BigBasket ₹1,140", PopTextSpecs.body)
                    }
                }

                GallerySection(title: "Banners") {
                    PopBanner("Your last backup was 30 days ago.", title: "Back up soon", tone: .warning, actionLabel: "Back up now", onDismiss: {})
                    PopBanner("Prices update every morning at 9.")
                    PopBanner("All caught up: nothing needs a category.", tone: .success)
                }

                GallerySection(title: "Loading") {
                    PopSkeletonList(rows: 2)
                    HStack(spacing: PopSpace.md) {
                        PopSpinner()
                        PopText("Fetching prices…", PopTextSpecs.body)
                    }
                }

                GallerySection(title: "Tabs") {
                    PopTabs(["Spending", "Income", "Accounts", "Goals"], selection: $tab)
                }

                GallerySection(title: "Top app bar") {
                    // In an app the compact bar tops a sub-screen and the large one tops the content.
                    PopTopBar("Insights", large: true) {
                        PopIconButton(systemImage: "calendar", label: "Pick month") {}
                        PopIconButton(systemImage: "gearshape", label: "Settings") {}
                    }
                    .galleryFrame()
                    PopTopBar("Food budget", onBack: {}) {
                        PopIconButton(systemImage: "pencil", label: "Edit") {}
                    }
                    .galleryFrame()
                    PopTopBar("Scrolled under", scrolled: true, onBack: {}).galleryFrame()
                }

                GallerySection(title: "Avatars") {
                    HStack(spacing: PopSpace.md) {
                        PopAvatar("Asha Rao", size: 56)
                        PopAvatar("Ravi Kumar")
                        PopAvatar("Priya")
                        PopAvatar("Home Loan")
                        PopAvatar("Neel Shah", size: 32)
                    }
                }

                GallerySection(title: "Badges and category dots") {
                    PopWrap(spacing: PopSpace.md, runSpacing: PopSpace.md) {
                        StickerBadge("UPI")
                        StickerBadge("Unsure", fill: PopColors.orange)
                        StickerBadge("+12.4%", fill: PopColors.mint)
                        StickerBadge("COMING SOON", fill: PopColors.lilac)
                    }
                    PopWrap(spacing: PopSpace.md, runSpacing: PopSpace.md) {
                        CategoryDot(systemImage: "cup.and.saucer.fill", fill: PopColors.orange)
                        CategoryDot(systemImage: "cart.fill", fill: PopColors.mint)
                        CategoryDot(systemImage: "car.fill", fill: PopColors.blue)
                        CategoryDot(systemImage: "bolt.fill", fill: PopColors.lilac)
                        CategoryDot(systemImage: "bag.fill", fill: PopColors.pink)
                        CategoryDot(systemImage: "ellipsis", fill: PopColors.white)
                    }
                }

                GallerySection(title: "StickerList") {
                    StickerCard(padding: 0) {
                        VStack(spacing: 0) {
                            StickerListRow("Chai Point", subtitle: "Today · 1:12 pm · HDFC",
                                           amount: PopFormat.formatInr(-12000, sign: .always),
                                           leading: AnyView(CategoryDot(systemImage: "cup.and.saucer.fill", fill: PopColors.orange)),
                                           badge: AnyView(StickerBadge("UPI")))
                            Rectangle().fill(PopColors.divider).frame(height: PopBorder.divider)
                            StickerListRow("Salary", subtitle: "15 Nov 2026 · HDFC",
                                           amount: PopFormat.formatInr(12_500_000, sign: .always),
                                           leading: AnyView(CategoryDot(systemImage: "briefcase.fill", fill: PopColors.mint)),
                                           selected: true)
                        }
                    }
                }

                GallerySection(title: "Tooltip") {
                    HStack(spacing: 0) {
                        PopText("Spent this month", PopTextSpecs.rowTitle)
                        PopTooltip("Includes UPI, card and cash payments. Transfers between your accounts are left out.") {
                            Image(systemName: "info.circle").font(.system(size: 18, weight: .bold)).frame(width: 48, height: 48)
                        }
                    }
                }

                GallerySection(title: "Stat tiles") {
                    HStack(alignment: .top, spacing: PopSpace.md) {
                        PopStatTile("Net worth", value: "₹12.4L", change: "3.1%", caption: "This month")
                        PopStatTile("Spent", value: "₹4,461", change: "8%", trend: .downGood, fill: PopColors.yellow)
                    }
                }

                GallerySection(title: "Progress and charts") {
                    PopProgressBar(value: 0.8, fill: PopColors.orange, label: "Food budget")
                    PopText("₹8,000 of ₹10,000 · 80% used", PopTextSpecs.caption)
                    StickerCard {
                        HStack(spacing: PopSpace.lg) {
                            PopDonut(slices, label: "Spending by category", size: 140, thickness: 30) {
                                PopText("₹51.2k", PopTextSpecs.rowAmount)
                            }
                            PopLegend(slices)
                        }
                    }
                    StickerCard {
                        PopBarChart(
                            [("Jun", 38.0), ("Jul", 42), ("Aug", 31), ("Sep", 47), ("Oct", 52), ("Nov", 29)].enumerated().map { i, m in
                                PopDatum(m.0, value: m.1, color: i == 5 ? PopColors.yellow : PopColors.blue)
                            },
                            label: "Spend by month", highlightIndex: 5
                        )
                    }
                }

                GallerySection(title: "Overlays") {
                    PopWrap(spacing: PopSpace.md, runSpacing: PopSpace.md) {
                        PopChip("Sheet", selected: false) { showSheet = true }
                        PopChip("Dialog", selected: false) { showDialog = true }
                        PopChip("Snackbar", selected: false) { snack.show("Saved") }
                        PopChip("Tour", selected: false) {
                            tour.start([
                                PopTourStep(target: "chips", title: "Pick a category", message: "Tap a chip to choose it. Chips you pick get a fill and a thicker outline."),
                                PopTourStep(target: "nav", title: "Add anything", message: "The pink button adds an expense, income or transfer."),
                            ])
                        }
                    }
                    PopTourCard(step: 1, count: 3, title: "Say it", message: "Speak an expense like \"450 for lunch\". It is read on the phone and not kept.", onSkip: {}) {}
                }

                GallerySection(title: "Quick add") {
                    PopQuickAddRow(onType: {}, onSay: {}, onScan: {})
                }

                GallerySection(title: "Navigation") {
                    PopNavBar(
                        items: [
                            PopNavItem(systemImage: "house.fill", label: "Home"),
                            PopNavItem(systemImage: "list.bullet.rectangle", label: "Activity"),
                            PopNavItem(systemImage: "chart.pie.fill", label: "Insights"),
                            PopNavItem(systemImage: "banknote.fill", label: "Wealth"),
                        ],
                        selection: $nav, onAdd: {}
                    )
                    .clipShape(RoundedRectangle(cornerRadius: PopRadius.card))
                    .overlay(RoundedRectangle(cornerRadius: PopRadius.card).strokeBorder(PopColors.ink, lineWidth: PopBorder.regular))
                    .popTourTarget("nav")
                }
            }
            .padding(PopSpace.screen)
            .padding(.bottom, PopSpace.xxl)
            .popContentWidth()
        }
        .background(PaperBackground())
        .popSnackbarHost(snack)
        .popBottomSheet(isPresented: $showSheet) {
            PopSheet("Rename account", primaryLabel: "Save", onPrimary: { showSheet = false }, error: "Names need at least one letter.") {
                PopTextField("Account name", text: $name)
            }
        }
        .popDialog(isPresented: $showDialog) {
            PopDialog("Delete this transaction?",
                      message: "It goes from this phone straight away. You can undo for a few seconds.",
                      primaryLabel: "Delete",
                      onPrimary: { showDialog = false; snack.show("Deleted", actionLabel: "Undo") },
                      onCancel: { showDialog = false })
        }
        .popBottomSheet(isPresented: $pickDate) {
            PopDatePickerSheet(selection: $date, today: galleryToday, in: Date.distantPast...galleryToday) { pickDate = false }
        }
        .popTourOverlay(tour)
        .popOverlayHost()
    }
}

struct PopGallery_Previews: PreviewProvider {
    static var previews: some View { PopGallery() }
}
