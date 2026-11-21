package dev.stickerpop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowRight
import androidx.compose.material.icons.rounded.CalendarMonth
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import dev.stickerpop.sticker
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.YearMonth

private val weekdays = listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
private val months = listOf("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")

/**
 * A strip of date tiles for quick picks: small stickers with the weekday over
 * the day number. The chosen tile is yellow; today reads "Today". [onMore]
 * adds a last tile that opens the calendar.
 */
@Composable
fun PopDateTiles(
    dates: List<LocalDate>,
    selected: LocalDate?,
    onSelect: (LocalDate) -> Unit,
    today: LocalDate,
    modifier: Modifier = Modifier,
    onMore: (() -> Unit)? = null,
    moreLabel: String = "Pick a date",
) {
    Row(modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
        dates.forEach { d ->
            DateTile(d == selected, "${d.dayOfMonth} ${months[d.monthValue - 1]}", { onSelect(d) }) {
                PopText(if (d == today) "Today" else weekdays[d.dayOfWeek.value - 1], PopTextSpecs.sectionLabel, color = if (d == selected) PopColors.ink else PopColors.inkMuted)
                PopText("${d.dayOfMonth}", PopTextSpecs.sectionHeading)
            }
        }
        if (onMore != null) DateTile(false, moreLabel, onMore) { PopIcon(Icons.Rounded.CalendarMonth, PopSize.iconTile) }
    }
}

@Composable
private fun DateTile(selected: Boolean, label: String, onClick: () -> Unit, content: @Composable () -> Unit) {
    val shape = RoundedCornerShape(PopRadius.tile)
    Column(
        Modifier
            .size(PopSize.dateTileWidth + PopShadow.small, PopSize.dateTileHeight + PopShadow.small)
            .clickable(remember { MutableInteractionSource() }, indication = null, role = Role.Button, onClick = onClick)
            .clearAndSetSemantics { contentDescription = label; this.selected = selected; role = Role.Button; onClick { onClick(); true } },
    ) {
        Column(
            Modifier
                .size(PopSize.dateTileWidth, PopSize.dateTileHeight)
                .sticker(if (selected) PopColors.yellow else PopColors.white, shape, PopRadius.tile, border = if (selected) PopBorder.regular else PopBorder.thin, shadow = PopShadow.small),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) { content() }
    }
}

/**
 * A month calendar: month and year with previous / next buttons, weekday
 * initials and 40 day circles. The chosen day is yellow with a 2.5 outline;
 * today has a 2 ink ring; days outside [firstDate]–[lastDate] are muted.
 */
@Composable
fun PopCalendar(
    selected: LocalDate?,
    onSelect: (LocalDate) -> Unit,
    today: LocalDate,
    modifier: Modifier = Modifier,
    firstDate: LocalDate? = null,
    lastDate: LocalDate? = null,
    firstDayOfWeek: DayOfWeek = DayOfWeek.MONDAY,
) {
    var month by remember { mutableStateOf(YearMonth.from(selected ?: today)) }
    val allowed = { d: LocalDate -> (firstDate == null || !d.isBefore(firstDate)) && (lastDate == null || !d.isAfter(lastDate)) }
    Column(modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
            PopText("${months[month.monthValue - 1]} ${month.year}", PopTextSpecs.sectionHeading, Modifier.weight(1f).semantics { heading() })
            PopIconButton(Icons.AutoMirrored.Rounded.KeyboardArrowLeft, "Previous month", onClick = { month = month.minusMonths(1) },
                enabled = firstDate == null || month.minusMonths(1).atEndOfMonth() >= firstDate)
            PopIconButton(Icons.AutoMirrored.Rounded.KeyboardArrowRight, "Next month", onClick = { month = month.plusMonths(1) },
                enabled = lastDate == null || month.plusMonths(1).atDay(1) <= lastDate)
        }
        Row(Modifier.fillMaxWidth()) {
            repeat(7) { i ->
                Box(Modifier.weight(1f).clearAndSetSemantics {}, contentAlignment = Alignment.Center) {
                    PopText(weekdays[(firstDayOfWeek.value - 1 + i) % 7].take(1), PopTextSpecs.sectionLabel)
                }
            }
        }
        val lead = (month.atDay(1).dayOfWeek.value - firstDayOfWeek.value + 7) % 7
        val cells = List(lead) { null } + (1..month.lengthOfMonth()).map { month.atDay(it) }
        cells.chunked(7).forEach { week ->
            Row(Modifier.fillMaxWidth()) {
                (0 until 7).forEach { i ->
                    val d = week.getOrNull(i)
                    Box(Modifier.weight(1f).aspectRatio(1f), contentAlignment = Alignment.Center) {
                        if (d != null) {
                            val isSel = d == selected
                            val ok = allowed(d)
                            Box(
                                Modifier
                                    .size(PopSize.calendarDay)
                                    .then(if (isSel) Modifier.background(PopColors.yellow, CircleShape).border(PopBorder.regular, PopColors.ink, CircleShape)
                                    else if (d == today) Modifier.border(PopBorder.thin, PopColors.ink, CircleShape) else Modifier)
                                    .clickable(remember { MutableInteractionSource() }, indication = null, enabled = ok, role = Role.Button) { onSelect(d) }
                                    .semantics { contentDescription = "${d.dayOfMonth} ${months[d.monthValue - 1]} ${d.year}" + if (d == today) ", today" else ""; this.selected = isSel },
                                contentAlignment = Alignment.Center,
                            ) {
                                PopText("${d.dayOfMonth}", if (isSel) PopTextSpecs.rowTitle else PopTextSpecs.input, color = if (ok) PopColors.ink else PopColors.inkMuted)
                            }
                        }
                    }
                }
            }
        }
    }
}

/** A [PopCalendar] in a bottom sheet. Picking a day calls [onPick]. */
@Composable
fun PopDatePickerSheet(
    today: LocalDate,
    selected: LocalDate?,
    onPick: (LocalDate) -> Unit,
    onDismiss: () -> Unit,
    title: String = "Pick a date",
    firstDate: LocalDate? = null,
    lastDate: LocalDate? = null,
) {
    PopBottomSheet(onDismiss = onDismiss) {
        PopSheet(title) { PopCalendar(selected, onPick, today, firstDate = firstDate, lastDate = lastDate) }
    }
}
