package dev.stickerpop.samples

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Bolt
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.DirectionsCar
import androidx.compose.material.icons.rounded.DocumentScanner
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.Insights
import androidx.compose.material.icons.rounded.Keyboard
import androidx.compose.material.icons.rounded.LocalCafe
import androidx.compose.material.icons.rounded.Mic
import androidx.compose.material.icons.rounded.MoreHoriz
import androidx.compose.material.icons.automirrored.rounded.ReceiptLong
import androidx.compose.material.icons.rounded.Savings
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material.icons.rounded.ShoppingBag
import androidx.compose.material.icons.rounded.ShoppingCart
import androidx.compose.material.icons.rounded.Work
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import dev.stickerpop.PaperBackground
import dev.stickerpop.popContentWidth
import dev.stickerpop.components.CategoryDot
import dev.stickerpop.components.PopAmountField
import dev.stickerpop.components.PopBottomSheet
import dev.stickerpop.components.PopChip
import dev.stickerpop.components.PopHintCard
import dev.stickerpop.components.PopIconButton
import dev.stickerpop.components.PopNavBar
import dev.stickerpop.components.PopNavItem
import dev.stickerpop.components.PopProgressBar
import dev.stickerpop.components.PopQuickAddRow
import dev.stickerpop.components.PopQuickAddTile
import dev.stickerpop.components.PopSectionLabel
import dev.stickerpop.components.PopSegmented
import dev.stickerpop.components.PopSheet
import dev.stickerpop.components.PopSnackbarHost
import dev.stickerpop.components.PopText
import dev.stickerpop.components.PopTextButton
import dev.stickerpop.components.PopTextField
import dev.stickerpop.components.StickerBadge
import dev.stickerpop.components.StickerHeroCard
import dev.stickerpop.components.StickerList
import dev.stickerpop.components.StickerListRow
import dev.stickerpop.components.rememberPopSnackbarState
import dev.stickerpop.format.PopFormat
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs
import dev.stickerpop.tokens.PopTilt
import java.time.LocalDateTime

/** One transaction in the Home sample. Negative paise are money out. */
data class SampleTransaction(
    val title: String,
    val category: String,
    val paise: Long,
    val time: LocalDateTime,
    val account: String? = null,
    val upi: Boolean = false,
    val unsure: Boolean = false,
)

/** The sample's own categories. Mapping data to icons and colours is an app's job. */
private val categories: Map<String, Pair<ImageVector, Color>> = mapOf(
    "food" to (Icons.Rounded.LocalCafe to PopColors.orange),
    "groceries" to (Icons.Rounded.ShoppingCart to PopColors.mint),
    "transport" to (Icons.Rounded.DirectionsCar to PopColors.blue),
    "bills" to (Icons.Rounded.Bolt to PopColors.lilac),
    "shopping" to (Icons.Rounded.ShoppingBag to PopColors.pink),
    "salary" to (Icons.Rounded.Work to PopColors.mint),
)

@Composable
private fun Dot(category: String) {
    val (icon, color) = categories[category] ?: (Icons.Rounded.MoreHoriz to PopColors.white)
    CategoryDot(icon, color)
}

/** A fixed clock for screenshots and tests: 18 Nov 2026, 1:12 pm. */
val PopSampleNow: LocalDateTime = LocalDateTime.of(2026, 11, 18, 13, 12)

fun sampleTransactions(now: LocalDateTime): List<SampleTransaction> = listOf(
    SampleTransaction("Chai Point", "food", -12000, now.minusMinutes(40), "HDFC", upi = true),
    SampleTransaction("Uber", "transport", -34650, now.minusHours(4), "ICICI", upi = true),
    SampleTransaction("BigBasket", "groceries", -184520, now.minusDays(1).minusHours(2), "HDFC", unsure = true),
    SampleTransaction("Salary", "salary", 12500000, now.minusDays(3), "HDFC"),
    SampleTransaction("Electricity bill", "bills", -215000, now.minusDays(5), "SBI"),
)

/**
 * A sample Home screen for an expense app, built only from Sticker Pop
 * components: the yellow month card, Type it / Say it / Scan it, a Recent
 * list and the bottom navigation with the tilted pink add button.
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun PopHomeSample(
    now: LocalDateTime = LocalDateTime.now(),
    transactions: List<SampleTransaction> = sampleTransactions(now),
) {
    var tab by remember { mutableIntStateOf(0) }
    var adding by remember { mutableStateOf(false) }
    val snack = rememberPopSnackbarState()
    val spent = transactions.filter { it.paise < 0 }.sumOf { -it.paise }
    val budget = 4_000_000L

    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize()) {
            PaperBackground(Modifier.weight(1f)) {
                Column(
                    Modifier
                        .fillMaxSize()
                        .statusBarsPadding()
                        .verticalScroll(rememberScrollState())
                        .padding(start = PopSpace.screen, end = PopSpace.screen, top = PopSpace.md, bottom = PopSpace.xxl)
                        .popContentWidth(),
                    verticalArrangement = Arrangement.spacedBy(PopSpace.lg),
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        PopText("Home", PopTextSpecs.screenTitle, Modifier.weight(1f).semantics { heading() })
                        PopIconButton(Icons.Rounded.Settings, "Settings", { snack.show("Settings opens here") })
                    }
                    StickerHeroCard(tilt = PopTilt.hero, onClick = { snack.show("Month details open here") }) {
                        // Wraps instead of squeezing the label when space is tight.
                        FlowRow(
                            horizontalArrangement = Arrangement.spacedBy(PopSpace.sm),
                            verticalArrangement = Arrangement.spacedBy(PopSpace.xs),
                            itemVerticalAlignment = Alignment.CenterVertically,
                        ) {
                            PopText("Spent in ${PopFormat.formatPopMonth(now)}", PopTextSpecs.sectionLabel)
                            StickerBadge("${(spent * 100 / budget)}% of budget")
                        }
                        Spacer(Modifier.height(PopSpace.xs))
                        PopText(PopFormat.formatInr(spent), PopTextSpecs.heroAmount, maxLines = 1)
                        Spacer(Modifier.height(PopSpace.md))
                        PopProgressBar(spent.toFloat() / budget, fill = PopColors.pink, label = "Monthly budget used")
                        Spacer(Modifier.height(PopSpace.sm))
                        PopText(
                            "${PopFormat.formatInr(budget - spent)} left of ${PopFormat.formatInrCompact(budget)} · 12 days to go",
                            PopTextSpecs.body,
                        )
                    }
                    Spacer(Modifier.height(PopSpace.sm))
                    PopQuickAddRow(
                        listOf(
                            PopQuickAddTile("Type it", Icons.Rounded.Keyboard, PopColors.white, -1.5f) { adding = true },
                            PopQuickAddTile("Say it", Icons.Rounded.Mic, PopColors.pink, 1.5f) { snack.show("Say it opens here") },
                            PopQuickAddTile("Scan it", Icons.Rounded.DocumentScanner, PopColors.mint, -1f) { snack.show("Scan it opens here") },
                        ),
                    )
                    Spacer(Modifier.height(PopSpace.sm))
                    PopSectionLabel("Recent") { PopTextButton("See all", { tab = 1 }) }
                    if (transactions.isEmpty()) {
                        PopHintCard("Your spending shows up here. Add one with Type it, Say it or Scan it.")
                    } else {
                        StickerList(
                            rows = transactions.map { t ->
                                @Composable {
                                    val date = PopFormat.formatPopDate(t.time, now)
                                    StickerListRow(
                                        title = t.title,
                                        subtitle = listOfNotNull(date, if (date == "Today") PopFormat.formatPopTime(t.time) else null, t.account).joinToString(" · "),
                                        amount = PopFormat.formatInr(t.paise, PopFormat.Sign.Always),
                                        leading = { Dot(t.category) },
                                        badge = when {
                                            t.unsure -> { { StickerBadge("Unsure", fill = PopColors.orange) } }
                                            t.upi -> { { StickerBadge("UPI") } }
                                            else -> null
                                        },
                                        onClick = { snack.show(t.title) },
                                    )
                                }
                            },
                        )
                    }
                }
            }
            PopNavBar(
                items = listOf(
                    PopNavItem(Icons.Rounded.Home, "Home"),
                    PopNavItem(Icons.AutoMirrored.Rounded.ReceiptLong, "Activity"),
                    PopNavItem(Icons.Rounded.Insights, "Insights"),
                    PopNavItem(Icons.Rounded.Savings, "Wealth"),
                ),
                selected = tab,
                onSelect = { tab = it },
                onAdd = { adding = true },
            )
        }
        PopSnackbarHost(snack, Modifier.padding(bottom = 96.dp))
        if (adding) AddSheet(onClose = { adding = false }, onSaved = { adding = false; snack.show("Saved") })
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun AddSheet(onClose: () -> Unit, onSaved: () -> Unit) {
    var kind by remember { mutableStateOf("Expense") }
    var amount by remember { mutableStateOf("") }
    var note by remember { mutableStateOf("") }
    var category by remember { mutableStateOf("food") }
    var error by remember { mutableStateOf<String?>(null) }
    PopBottomSheet(onDismiss = onClose) {
        PopSheet(
            title = "Add a transaction",
            trailing = { PopIconButton(Icons.Rounded.Close, "Close", onClose) },
            error = error,
            primaryLabel = "Save",
            onPrimary = {
                if (amount.isBlank() || amount.toDoubleOrNull() == 0.0) error = "Enter an amount above ₹0." else onSaved()
            },
        ) {
            PopSegmented(listOf("Expense", "Income", "Transfer"), kind, { it }, { kind = it })
            PopAmountField(
                amount,
                { amount = it; error = null },
                fill = if (kind == "Income") PopColors.mint else PopColors.yellow,
                label = kind,
            )
            FlowRow(horizontalArrangement = Arrangement.spacedBy(PopSpace.sm), verticalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
                listOf("food", "groceries", "transport", "bills", "shopping").forEach { c ->
                    val (icon, color) = categories.getValue(c)
                    PopChip(c.replaceFirstChar { it.uppercase() }, category == c, { category = c }, fill = color, icon = icon)
                }
            }
            PopTextField(note, { note = it }, hint = "Add a note")
        }
    }
}
