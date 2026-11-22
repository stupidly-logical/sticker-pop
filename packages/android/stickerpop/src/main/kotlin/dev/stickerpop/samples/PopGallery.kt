package dev.stickerpop.samples

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.rounded.AccountBalance
import androidx.compose.material.icons.rounded.Bolt
import androidx.compose.material.icons.rounded.CloudOff
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.IosShare
import androidx.compose.material.icons.rounded.Notifications
import androidx.compose.material.icons.rounded.Translate
import androidx.compose.ui.draw.clip
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material.icons.rounded.CalendarMonth
import androidx.compose.material.icons.rounded.ContentCopy
import androidx.compose.material.icons.rounded.CreditCard
import androidx.compose.material.icons.rounded.Delete
import androidx.compose.material.icons.rounded.Edit
import androidx.compose.material.icons.rounded.Payments
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.DirectionsCar
import androidx.compose.material.icons.rounded.DocumentScanner
import androidx.compose.material.icons.rounded.Eco
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.Insights
import androidx.compose.material.icons.rounded.Keyboard
import androidx.compose.material.icons.rounded.Lightbulb
import androidx.compose.material.icons.rounded.LocalCafe
import androidx.compose.material.icons.rounded.Mic
import androidx.compose.material.icons.rounded.MoreHoriz
import androidx.compose.material.icons.automirrored.rounded.ReceiptLong
import androidx.compose.material.icons.rounded.Savings
import androidx.compose.material.icons.rounded.ShoppingBag
import androidx.compose.material.icons.rounded.ShoppingCart
import androidx.compose.material.icons.rounded.Tune
import androidx.compose.material.icons.rounded.Work
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import dev.stickerpop.PaperBackground
import dev.stickerpop.popContentWidth
import dev.stickerpop.components.*
import dev.stickerpop.format.PopFormat
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopGradients
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs
import dev.stickerpop.tokens.PopTilt

@Composable
private fun Section(title: String, content: @Composable ColumnScope.() -> Unit) {
    Column(Modifier.padding(top = PopSpace.section + PopSpace.sm), verticalArrangement = Arrangement.spacedBy(PopSpace.md)) {
        PopText(title, PopTextSpecs.sectionHeading, Modifier.semantics { heading() })
        content()
    }
}

private val slices = listOf(
    PopDatum("Food", 32f, PopColors.orange),
    PopDatum("Groceries", 24f, PopColors.mint),
    PopDatum("Transport", 18f, PopColors.blue),
    PopDatum("Bills", 16f, PopColors.lilac),
    PopDatum("Shopping", 10f, PopColors.pink),
)

/**
 * Every Sticker Pop component in each of its states (rest, selected,
 * disabled, error), plus colour swatches. [onOpenHome] opens the Home sample.
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun PopGallery(onOpenHome: () -> Unit = {}) {
    var segment by remember { mutableStateOf("Expense") }
    var chip by remember { mutableStateOf("Food") }
    var switchOn by remember { mutableStateOf(true) }
    var nav by remember { mutableIntStateOf(0) }
    val tags = remember { mutableStateListOf("Office", "Trip") }
    var note by remember { mutableStateOf("") }
    var payee by remember { mutableStateOf("") }
    var amount by remember { mutableStateOf("1250.50") }
    var account by remember { mutableStateOf<String?>("hdfc") }
    var transfers by remember { mutableStateOf(true) }
    var query by remember { mutableStateOf("") }
    var tab by remember { mutableIntStateOf(0) }
    var reminder by remember { mutableStateOf(true) }
    var budget by remember { mutableStateOf(12000f) }
    var people by remember { mutableIntStateOf(2) }
    var typed by remember { mutableStateOf("450") }
    var tripTags by remember { mutableStateOf(listOf("Goa", "Family")) }
    val today = java.time.LocalDate.of(2026, 11, 21)
    var date by remember { mutableStateOf(today) }
    var pickDate by remember { mutableStateOf(false) }
    var period by remember { mutableStateOf("Month") }
    var showSheet by remember { mutableStateOf(false) }
    var showDialog by remember { mutableStateOf(false) }
    val snack = rememberPopSnackbarState()
    val tour = rememberPopTourState()

    Box(Modifier.fillMaxSize()) {
        PaperBackground(Modifier.fillMaxSize()) {
            Column(
                Modifier
                    .fillMaxSize()
                    .statusBarsPadding()
                    .verticalScroll(rememberScrollState())
                    .padding(PopSpace.screen)
                    .popContentWidth(),
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    PopText("Sticker Pop", PopTextSpecs.welcomeTitle, Modifier.weight(1f))
                    PopIconButton(Icons.Rounded.Home, "Open the Home sample", onOpenHome, fill = PopColors.yellow)
                }
                PopText("A bold, friendly design system", PopTextSpecs.body)

                Section("Colour") {
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(PopSpace.md), verticalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                        listOf(
                            "paper" to PopColors.paper, "ink" to PopColors.ink, "inkMuted" to PopColors.inkMuted,
                            "white" to PopColors.white, "divider" to PopColors.divider, "yellow" to PopColors.yellow,
                            "pink" to PopColors.pink, "blue" to PopColors.blue, "mint" to PopColors.mint,
                            "lilac" to PopColors.lilac, "orange" to PopColors.orange,
                        ).forEach { (name, color) ->
                            val onInk = color == PopColors.ink || color == PopColors.inkMuted
                            Box(
                                Modifier.size(96.dp, 64.dp).background(color, RoundedCornerShape(18.dp))
                                    .border(2.5.dp, PopColors.ink, RoundedCornerShape(18.dp)).padding(PopSpace.sm),
                                contentAlignment = Alignment.BottomStart,
                            ) { PopText(name, PopTextSpecs.chipSelected, color = if (onInk) PopColors.white else PopColors.ink) }
                        }
                    }
                }

                Section("Type") {
                    PopText("Screen title 34", PopTextSpecs.screenTitle)
                    PopText("₹1,25,000", PopTextSpecs.heroAmount)
                    PopText("Sheet title 22", PopTextSpecs.sheetTitle)
                    PopText("Row title 16", PopTextSpecs.rowTitle)
                    PopText("Body 15 for sentences people read.", PopTextSpecs.body)
                    PopText("Caption 13 in muted ink", PopTextSpecs.caption)
                    PopText("Section label", PopTextSpecs.sectionLabel)
                }

                Section("StickerCard") {
                    StickerCard(Modifier.fillMaxWidth()) { PopText("Default: white, 4/4 shadow", PopTextSpecs.body) }
                    StickerHeroCard(Modifier.fillMaxWidth()) {
                        PopText("Net worth", PopTextSpecs.sectionLabel)
                        PopText("₹12,40,500", PopTextSpecs.heroAmount)
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                        StickerInfoCard(Modifier.weight(1f)) { PopText("Info, blue", PopTextSpecs.body) }
                        StickerInfoCard(Modifier.weight(1f), fill = PopColors.mint) { PopText("Info, mint", PopTextSpecs.body) }
                    }
                    // Gradient fills come from tokens (PopGradients).
                    Row(horizontalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                        PopGradients.byName.forEach { (name, g) ->
                            StickerCard(Modifier.weight(1f), gradient = g, padding = androidx.compose.foundation.layout.PaddingValues(horizontal = PopSpace.sm, vertical = PopSpace.lg)) {
                                Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) { PopText(name, PopTextSpecs.chipSelected, maxLines = 1) }
                            }
                        }
                    }
                    PopHintCard("Goals you add show up here. Tap Add goal to start one.", icon = Icons.Rounded.Lightbulb)
                }

                Section("Buttons") {
                    StickerButton("Save", { snack.show("Saved") })
                    StickerButton("Save (disabled)", {}, enabled = false)
                    StickerButton("Saving", {}, busy = true)
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
                        PopTextButton("Cancel", {})
                        PopTextButton("Skip", {}, underline = true)
                        PopTextButton("Disabled", {}, enabled = false)
                    }
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(PopSpace.md), verticalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                        PopIconButton(Icons.AutoMirrored.Rounded.ArrowBack, "Back", {})
                        PopIconButton(Icons.Rounded.Mic, "Voice", {}, fill = PopColors.pink)
                        PopIconButton(Icons.Rounded.Tune, "Filters on", {}, fill = PopColors.yellow, selected = true)
                        PopIconButton(Icons.Rounded.Close, "Close", {}, enabled = false)
                    }
                }

                Section("PopChip") {
                    FlowRow(
                        Modifier.popTourTarget(tour, "chips"),
                        horizontalArrangement = Arrangement.spacedBy(PopSpace.sm),
                        verticalArrangement = Arrangement.spacedBy(PopSpace.sm),
                    ) {
                        listOf("Food", "Travel", "Bills").forEach { PopChip(it, chip == it, { chip = it }) }
                        PopChip("Mint", true, {}, fill = PopColors.mint, icon = Icons.Rounded.Eco)
                        PopChip("Disabled", false, {}, enabled = false)
                        tags.toList().forEach { t -> PopChip(t, false, {}, onRemove = { tags.remove(t) }) }
                    }
                }

                Section("PopSegmented") {
                    PopSegmented(listOf("Expense", "Income", "Transfer"), segment, { it }, { segment = it })
                    PopSegmented(listOf("Month", "Year"), "Month", { it }, {}, enabled = false)
                }

                Section("PopSwitch") {
                    StickerCard(Modifier.fillMaxWidth(), padding = androidx.compose.foundation.layout.PaddingValues(0.dp)) {
                        listOf<@Composable () -> Unit>(
                            { PopFieldRow("Reminders") { Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.CenterEnd) { PopSwitch(switchOn, { switchOn = it }, "Reminders") } } },
                            { PopFieldRow("Sync", divider = false) { Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.CenterEnd) { PopSwitch(false, {}, "Sync", enabled = false) } } },
                        ).forEach { it() }
                    }
                }

                Section("Text fields") {
                    PopTextField(note, { note = it }, hint = "Add a note", label = "Note")
                    PopTextField(payee, { payee = it }, hint = "Who was it?", label = "Payee", error = "Add who you paid.")
                    PopTextField("HDFC ·· 4821", {}, label = "Account", enabled = false)
                    PopSearchField(query, { query = it }, hint = "Search transactions", onCancel = { query = "" })
                    PopAmountField(amount, { amount = it }, label = "Expense")
                    // A details card: field rows draw their own dividers.
                    StickerCard(Modifier.fillMaxWidth(), padding = androidx.compose.foundation.layout.PaddingValues(0.dp)) {
                        PopFieldRow("Paid to") { PopText("Chai Point", PopTextSpecs.rowTitle) }
                        PopFieldRow("Account", showChevron = true, divider = false, onClick = {}) { PopText("HDFC ·· 4821", PopTextSpecs.rowTitle) }
                    }
                }

                Section("Pull to refresh") {
                    Row(horizontalArrangement = Arrangement.spacedBy(PopSpace.lg)) {
                        PopRefreshIndicator(0.6f)
                        PopRefreshIndicator(null)
                    }
                }

                Section("Date range") {
                    StickerCard {
                        PopRangeCalendar(java.time.LocalDate.of(2026, 11, 12), java.time.LocalDate.of(2026, 11, 18), { _, _ -> }, java.time.LocalDate.of(2026, 11, 21))
                    }
                }

                Section("Attachment") {
                    PopAttachmentTile(onPick = {})
                    PopAttachmentTile(onPick = {}, fileName = "chai-point-receipt.jpg", fileSize = "412 KB", onRemove = {})
                }

                Section("Tag input") {
                    PopTagInput(tripTags, { tripTags = it }, label = "Tags")
                }

                Section("Select and menu") {
                    val accounts = listOf(
                        PopSelectOption("hdfc", "HDFC", Icons.Rounded.AccountBalance, caption = "Savings ·· 4821"),
                        PopSelectOption("icici", "ICICI", Icons.Rounded.CreditCard, caption = "Credit card ·· 4411"),
                        PopSelectOption("cash", "Cash", Icons.Rounded.Payments),
                    )
                    PopSelect(accounts, account, { account = it }, label = "Account")
                    PopSelect(accounts, null, {}, label = "Paid from", hint = "Choose an account", error = "Choose where the money came from.")
                    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        PopText("Chai Point", PopTextSpecs.rowTitle, Modifier.weight(1f))
                        PopMenu(
                            listOf(
                                PopMenuItem("Edit", Icons.Rounded.Edit) { snack.show("Edit opens here") },
                                PopMenuItem("Duplicate", Icons.Rounded.ContentCopy) { snack.show("Duplicated") },
                                PopMenuDivider,
                                PopMenuItem("Delete", Icons.Rounded.Delete, destructive = true) { snack.show("Deleted", "Undo") },
                            ),
                        ) { toggle, _ -> PopIconButton(Icons.Rounded.MoreHoriz, "More for Chai Point", onClick = toggle) }
                    }
                }

                Section("Checkbox and radio") {
                    StickerList(rows = listOf(
                        { PopCheckboxRow("Include transfers", transfers, { transfers = it }, caption = "Moving money between your own accounts") },
                        { PopCheckboxRow("Hide small amounts", false, { }) },
                        { PopCheckboxRow("Sync", true, null) },
                    ))
                    StickerList(rows = listOf("Week", "Month", "Year").map { p -> @Composable { PopRadioRow(p, period == p, { period = p }) } })
                }

                Section("Dates") {
                    PopDateTiles((4 downTo 0).map { today.minusDays(it.toLong()) }, date, { date = it }, today, onMore = { pickDate = true })
                    StickerCard(Modifier.fillMaxWidth()) { PopCalendar(date, { date = it }, today, lastDate = today) }
                    if (pickDate) PopDatePickerSheet(today, date, { date = it; pickDate = false }, { pickDate = false }, lastDate = today)
                }

                Section("Slider") {
                    Row(Modifier.fillMaxWidth()) {
                        PopText("Monthly budget", PopTextSpecs.fieldLabel, Modifier.weight(1f))
                        PopText(PopFormat.formatInr((budget * 100).toLong()), PopTextSpecs.rowAmount)
                    }
                    PopSlider(budget, { budget = it }, "Monthly budget", range = 0f..20000f, step = 500f, valueLabel = { PopFormat.formatInr((it * 100).toLong()) })
                    PopSlider(0.3f, null, "Locked")
                }

                Section("Number keypad") {
                    StickerCard(Modifier.fillMaxWidth(), fill = PopColors.yellow) { PopText("₹" + typed.ifEmpty { "0" }, PopTextSpecs.amountEntry) }
                    PopKeypad({ typed = applyPopKey(typed, it) })
                }

                Section("PIN entry") {
                    PopPinField("12", Modifier.fillMaxWidth())
                    PopPinField("4821", Modifier.fillMaxWidth(), error = "That PIN doesn't match. 2 tries left.")
                    PopPinField("583", Modifier.fillMaxWidth(), length = 6, obscure = false, label = "Code")
                }

                Section("Stepper") {
                    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        PopText("Split between", PopTextSpecs.input, Modifier.weight(1f))
                        PopStepper(people, { people = it }, "People", range = 1..20)
                    }
                }

                Section("Settings rows") {
                    StickerList(rows = listOf(
                        { PopSettingsRow("Language", icon = Icons.Rounded.Translate, value = "English", onClick = {}) },
                        { PopSettingsRow("Daily reminder", subtitle = "At 9 pm", icon = Icons.Rounded.Notifications, checked = reminder, onCheckedChange = { reminder = it }) },
                        { PopSettingsRow("Export data", icon = Icons.Rounded.IosShare, onClick = {}) },
                        { PopSettingsRow("Version", icon = Icons.Rounded.Info, value = "0.1.0") },
                    ))
                }

                Section("Empty and error screens") {
                    StickerCard(Modifier.fillMaxWidth()) {
                        PopEmptyState(Icons.AutoMirrored.Rounded.ReceiptLong, "No transactions yet", "Add your first one with Type it, Say it or Scan it.", actionLabel = "Add a transaction")
                    }
                    StickerCard(Modifier.fillMaxWidth()) {
                        PopEmptyState(Icons.Rounded.CloudOff, "Couldn't load prices", "Check your connection and try again. Your own data is safe on this phone.",
                            fill = PopColors.orange, actionLabel = "Try again", secondaryLabel = "Not now")
                    }
                }

                Section("Expandable cards") {
                    PopExpandable("Where does my data go?", initiallyExpanded = true) {
                        PopText("Nowhere. Everything stays on this phone unless you export it.", PopTextSpecs.body)
                    }
                    PopExpandable("Food, Nov 2026", subtitle = "₹3,240 across 14 transactions") {
                        PopText("Chai Point ₹1,120 · Swiggy ₹980 · BigBasket ₹1,140", PopTextSpecs.body)
                    }
                }

                Section("Banners") {
                    PopBanner("Your last backup was 30 days ago.", title = "Back up soon", tone = PopBannerTone.Warning, actionLabel = "Back up now", onDismiss = {})
                    PopBanner("Prices update every morning at 9.")
                    PopBanner("All caught up: nothing needs a category.", tone = PopBannerTone.Success)
                }

                Section("Loading") {
                    PopSkeletonList(rows = 2)
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                        PopSpinner()
                        PopText("Fetching prices…", PopTextSpecs.body)
                    }
                }

                Section("Tabs") {
                    PopTabs(listOf("Spending", "Income", "Accounts", "Goals"), tab, { tab = it })
                }

                Section("Top app bar") {
                    // In an app the compact bar tops a sub-screen and the large one tops the content.
                    val frame = RoundedCornerShape(18.dp)
                    Box(Modifier.fillMaxWidth().clip(frame).border(2.dp, PopColors.divider, frame)) {
                        PopTopBar("Insights", large = true) {
                            PopIconButton(Icons.Rounded.CalendarMonth, "Pick month", onClick = {})
                            PopIconButton(Icons.Rounded.Settings, "Settings", onClick = {})
                        }
                    }
                    Box(Modifier.fillMaxWidth().clip(frame).border(2.dp, PopColors.divider, frame)) {
                        PopTopBar("Food budget", onBack = {}, statusBarPadding = false) {
                            PopIconButton(Icons.Rounded.Edit, "Edit", onClick = {})
                        }
                    }
                    Box(Modifier.fillMaxWidth().clip(frame).border(2.dp, PopColors.divider, frame)) {
                        PopTopBar("Scrolled under", onBack = {}, scrolled = true, statusBarPadding = false)
                    }
                }

                Section("Avatars") {
                    Row(horizontalArrangement = Arrangement.spacedBy(PopSpace.md), verticalAlignment = Alignment.CenterVertically) {
                        PopAvatar("Asha Rao", size = 56.dp)
                        PopAvatar("Ravi Kumar")
                        PopAvatar("Priya")
                        PopAvatar("Home Loan")
                        PopAvatar("Neel Shah", size = 32.dp)
                    }
                }

                Section("Badges and category dots") {
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(PopSpace.md), verticalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                        StickerBadge("UPI")
                        StickerBadge("Unsure", fill = PopColors.orange)
                        StickerBadge("+12.4%", fill = PopColors.mint)
                        StickerBadge("COMING SOON", fill = PopColors.lilac)
                    }
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                        CategoryDot(Icons.Rounded.LocalCafe, PopColors.orange)
                        CategoryDot(Icons.Rounded.ShoppingCart, PopColors.mint)
                        CategoryDot(Icons.Rounded.DirectionsCar, PopColors.blue)
                        CategoryDot(Icons.Rounded.Bolt, PopColors.lilac)
                        CategoryDot(Icons.Rounded.ShoppingBag, PopColors.pink)
                        CategoryDot(Icons.Rounded.MoreHoriz, PopColors.white)
                    }
                }

                Section("StickerList") {
                    StickerList(
                        rows = listOf(
                            {
                                StickerListRow(
                                    "Chai Point", subtitle = "Today · 1:12 pm · HDFC",
                                    amount = PopFormat.formatInr(-12000, PopFormat.Sign.Always),
                                    leading = { CategoryDot(Icons.Rounded.LocalCafe, PopColors.orange) },
                                    badge = { StickerBadge("UPI") }, onClick = {},
                                )
                            },
                            {
                                StickerListRow(
                                    "Salary", subtitle = "15 Nov 2026 · HDFC",
                                    amount = PopFormat.formatInr(12500000, PopFormat.Sign.Always),
                                    leading = { CategoryDot(Icons.Rounded.Work, PopColors.mint) },
                                    selected = true, onClick = {},
                                )
                            },
                        ),
                    )
                }

                Section("Tooltip") {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        PopText("Spent this month", PopTextSpecs.rowTitle, Modifier.weight(1f, fill = false))
                        PopTooltip("Includes UPI, card and cash payments. Transfers between your accounts are left out.") {
                            Box(Modifier.size(48.dp), contentAlignment = Alignment.Center) { PopIcon(Icons.Rounded.Info, 22.dp) }
                        }
                    }
                }

                Section("Stat tiles") {
                    Row(horizontalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                        PopStatTile("Net worth", "₹12.4L", Modifier.weight(1f), change = "3.1%", caption = "This month")
                        PopStatTile("Spent", "₹4,461", Modifier.weight(1f), change = "8%", trend = PopTrend.DownGood, fill = PopColors.yellow)
                    }
                }

                Section("Progress and charts") {
                    PopProgressBar(0.8f, fill = PopColors.orange, label = "Food budget")
                    PopText("₹8,000 of ₹10,000 · 80% used", PopTextSpecs.caption)
                    StickerCard(Modifier.fillMaxWidth()) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            PopDonut(slices, "Spending by category", size = 140.dp, thickness = 30.dp) { PopText("₹51.2k", PopTextSpecs.rowAmount) }
                            Spacer(Modifier.size(PopSpace.lg))
                            PopLegend(slices, Modifier.weight(1f))
                        }
                    }
                    StickerCard(Modifier.fillMaxWidth()) {
                        PopBarChart(
                            listOf("Jun" to 38f, "Jul" to 42f, "Aug" to 31f, "Sep" to 47f, "Oct" to 52f, "Nov" to 29f)
                                .mapIndexed { i, (m, v) -> PopDatum(m, v, if (i == 5) PopColors.yellow else PopColors.blue) },
                            "Spend by month", highlightIndex = 5,
                        )
                    }
                }

                Section("Overlays") {
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(PopSpace.md), verticalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                        PopChip("Sheet", false, { showSheet = true })
                        PopChip("Dialog", false, { showDialog = true })
                        PopChip("Snackbar", false, { snack.show("Saved") })
                        PopChip("Tour", false, {
                            tour.start(
                                listOf(
                                    PopTourStep("chips", "Pick a category", "Tap a chip to choose it. Chips you pick get a fill and a thicker outline."),
                                    PopTourStep("nav", "Add anything", "The pink button adds an expense, income or transfer."),
                                ),
                            )
                        })
                    }
                    PopTourCard(1, 3, "Say it", "Speak an expense like \"450 for lunch\". It is read on the phone and not kept.", {}, onSkip = {})
                }

                Section("Quick add") {
                    PopQuickAddRow(
                        listOf(
                            PopQuickAddTile("Type it", Icons.Rounded.Keyboard, PopColors.white, -1.5f) {},
                            PopQuickAddTile("Say it", Icons.Rounded.Mic, PopColors.pink, 1.5f) {},
                            PopQuickAddTile("Scan it", Icons.Rounded.DocumentScanner, PopColors.mint, -1f) {},
                        ),
                    )
                }

                Section("Navigation") {
                    StickerCard(Modifier.fillMaxWidth().popTourTarget(tour, "nav"), shadow = 0.dp, padding = androidx.compose.foundation.layout.PaddingValues(0.dp)) {
                        PopNavBar(
                            listOf(
                                PopNavItem(Icons.Rounded.Home, "Home"),
                                PopNavItem(Icons.AutoMirrored.Rounded.ReceiptLong, "Activity"),
                                PopNavItem(Icons.Rounded.Insights, "Insights"),
                                PopNavItem(Icons.Rounded.Savings, "Wealth"),
                            ),
                            nav, { nav = it }, {},
                        )
                    }
                }
                Spacer(Modifier.height(PopSpace.xxl))
            }
        }
        PopSnackbarHost(snack)
        PopTourOverlay(tour)
        if (showSheet) {
            var name by remember { mutableStateOf("") }
            PopBottomSheet(onDismiss = { showSheet = false }) {
                PopSheet(
                    "Rename account",
                    error = "Names need at least one letter.",
                    primaryLabel = "Save",
                    onPrimary = { showSheet = false },
                ) { PopTextField(name, { name = it }, hint = "Account name") }
            }
        }
        if (showDialog) {
            PopDialog(
                "Delete this transaction?",
                "It goes from this phone straight away. You can undo for a few seconds.",
                "Delete",
                onPrimary = { showDialog = false; snack.show("Deleted", "Undo") },
                onDismiss = { showDialog = false },
            )
        }
    }
}
