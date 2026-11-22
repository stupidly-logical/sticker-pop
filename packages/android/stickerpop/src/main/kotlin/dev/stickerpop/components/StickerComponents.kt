package dev.stickerpop.components

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.ErrorOutline
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.foundation.Image
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.stickerpop.popCaps
import dev.stickerpop.popTextStyle
import dev.stickerpop.popTilt
import dev.stickerpop.sticker
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopGradient
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpec
import dev.stickerpop.tokens.PopTextSpecs
import dev.stickerpop.tokens.PopTilt

/**
 * Text in one role of the type scale. Amounts (the tabular roles) never
 * wrap: they stay on one line and shrink to fit.
 */
@Composable
fun PopText(
    text: String,
    spec: PopTextSpec,
    modifier: Modifier = Modifier,
    color: Color = spec.color,
    maxLines: Int = Int.MAX_VALUE,
    align: TextAlign? = null,
) {
    val style = popTextStyle(spec, color).let { if (align != null) it.copy(textAlign = align) else it }
    BasicText(
        text = popCaps(spec, text),
        style = style,
        modifier = modifier,
        maxLines = if (spec.tabular) 1 else maxLines,
        softWrap = !spec.tabular,
        overflow = if (spec.tabular) TextOverflow.Clip else TextOverflow.Ellipsis,
        autoSize = if (spec.tabular) TextAutoSize.StepBased(minFontSize = 10.sp, maxFontSize = style.fontSize) else null,
    )
}

/** An ink-tinted icon. */
@Composable
fun PopIcon(icon: ImageVector, size: Dp, modifier: Modifier = Modifier, tint: Color = PopColors.ink) {
    Image(
        painter = rememberVectorPainter(icon),
        contentDescription = null,
        colorFilter = ColorFilter.tint(tint),
        modifier = modifier.size(size),
    )
}

/** White (or bright) card with a 2.5 ink outline, radius 22 and a 4/4 hard shadow. */
@Composable
fun StickerCard(
    modifier: Modifier = Modifier,
    fill: Color = PopColors.white,
    radius: Dp = PopRadius.card,
    shadow: Dp = PopShadow.regular,
    tilt: Float = 0f,
    padding: PaddingValues = PaddingValues(PopSpace.card),
    onClick: (() -> Unit)? = null,
    gradient: PopGradient? = null,
    content: @Composable ColumnScope.() -> Unit,
) {
    val source = remember { MutableInteractionSource() }
    val pressed by source.collectIsPressedAsState()
    val shape = RoundedCornerShape(radius)
    val down = onClick != null && pressed
    Column(
        modifier
            .popTilt(tilt.coerceIn(-PopTilt.cardMax, PopTilt.cardMax))
            .offset(if (down) shadow else 0.dp, if (down) shadow else 0.dp)
            .sticker(fill, shape, radius, shadow = if (down) 0.dp else shadow, brush = gradient?.brush)
            .clip(shape)
            .then(if (onClick != null) Modifier.clickable(source, indication = null, onClick = onClick) else Modifier)
            .padding(padding),
        content = content,
    )
}

/** The yellow headline card: large 6/6 shadow, optional slight tilt. */
@Composable
fun StickerHeroCard(
    modifier: Modifier = Modifier,
    tilt: Float = PopTilt.hero,
    onClick: (() -> Unit)? = null,
    gradient: PopGradient? = null,
    content: @Composable ColumnScope.() -> Unit,
) = StickerCard(
    modifier, PopColors.yellow, shadow = PopShadow.large, tilt = tilt,
    padding = PaddingValues(PopSpace.xl), onClick = onClick, gradient = gradient, content = content,
)

/** A blue (or lilac or mint) card for information and hints. */
@Composable
fun StickerInfoCard(
    modifier: Modifier = Modifier,
    fill: Color = PopColors.blue,
    onClick: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit,
) = StickerCard(modifier, fill, onClick = onClick, content = content)

/**
 * The primary action: ink fill, white 18/800 label, pink 4/4 hard shadow.
 * One per screen. [busy] shows "Label…" and ignores taps.
 */
@Composable
fun StickerButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    busy: Boolean = false,
    shadowColor: Color = PopColors.pink,
) {
    val source = remember { MutableInteractionSource() }
    val pressed by source.collectIsPressedAsState()
    val shape = RoundedCornerShape(PopRadius.button)
    val active = enabled && !busy
    val down = active && pressed
    Box(
        modifier
            .fillMaxWidth()
            .height(PopSize.button)
            .offset(if (down) PopShadow.regular else 0.dp, if (down) PopShadow.regular else 0.dp)
            .sticker(
                if (active) PopColors.ink else PopColors.inkMuted, shape, PopRadius.button,
                shadow = if (down) 0.dp else PopShadow.regular, shadowColor = shadowColor,
            )
            .clickable(source, indication = null, enabled = active, role = Role.Button, onClick = onClick)
            .padding(horizontal = PopSpace.lg),
        contentAlignment = Alignment.Center,
    ) {
        PopText(if (busy) "$label…" else label, PopTextSpecs.buttonLabel, maxLines = 1)
    }
}

/** A secondary action in plain ink text: Cancel, Skip, Show more. */
@Composable
fun PopTextButton(label: String, onClick: () -> Unit, modifier: Modifier = Modifier, underline: Boolean = false, enabled: Boolean = true) {
    val style = popTextStyle(PopTextSpecs.textButton, if (enabled) PopColors.ink else PopColors.inkMuted)
    BasicText(
        label,
        style = if (underline) style.copy(textDecoration = androidx.compose.ui.text.style.TextDecoration.Underline) else style,
        modifier = modifier
            .heightIn(min = PopSize.tapTarget)
            .clickable(enabled = enabled, role = Role.Button, onClick = onClick)
            .padding(horizontal = PopSpace.xs, vertical = 14.dp),
    )
}

/** A 46 round sticker button with one 22 icon. [label] is read by screen readers. */
@Composable
fun PopIconButton(
    icon: ImageVector,
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    fill: Color = PopColors.white,
    enabled: Boolean = true,
    selected: Boolean = false,
) {
    val source = remember { MutableInteractionSource() }
    val pressed by source.collectIsPressedAsState()
    val down = enabled && pressed
    val shadow = if (!enabled || down) 0.dp else PopShadow.small
    Box(
        modifier
            .size(PopSize.iconButton)
            .offset(if (down) PopShadow.small else 0.dp, if (down) PopShadow.small else 0.dp)
            .sticker(
                if (enabled) fill else PopColors.paper, CircleShape, PopSize.iconButton / 2,
                border = if (selected) PopBorder.spotlight else PopBorder.regular, shadow = shadow,
            )
            .clickable(source, indication = null, enabled = enabled, role = Role.Button, onClick = onClick)
            .semantics {
                contentDescription = label
                this.selected = selected
            },
        contentAlignment = Alignment.Center,
    ) { PopIcon(icon, PopSize.iconNav, tint = if (enabled) PopColors.ink else PopColors.inkMuted) }
}

/** A selectable pill: selected gets a bright fill, a 2.5 outline, a 2/2 shadow and 800 text. */
@Composable
fun PopChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    fill: Color = PopColors.yellow,
    icon: ImageVector? = null,
    enabled: Boolean = true,
    onRemove: (() -> Unit)? = null,
) {
    val shape = RoundedCornerShape(PopRadius.pill)
    val fg = if (enabled) PopColors.ink else PopColors.inkMuted
    Row(
        modifier
            .heightIn(min = PopSize.chip)
            .sticker(
                fill = when { !enabled -> PopColors.paper; selected -> fill; else -> PopColors.white },
                shape = shape, radius = PopRadius.pill,
                border = if (selected) PopBorder.regular else PopBorder.thin,
                shadow = if (selected && enabled) PopShadow.chip else 0.dp,
            )
            .clip(shape)
            .selectable(selected, enabled = enabled, role = Role.Button, onClick = onClick)
            .padding(start = 14.dp, end = if (onRemove == null) 14.dp else 6.dp, top = 6.dp, bottom = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        if (icon != null) PopIcon(icon, PopSize.iconChip, tint = fg)
        // The label reserves the width of its bold (selected) form, so the chip
        // is the same size selected or not and its neighbours never move.
        Box(contentAlignment = Alignment.Center) {
            PopText(label, PopTextSpecs.chipSelected, Modifier.alpha(0f).clearAndSetSemantics {}, maxLines = 1)
            PopText(label, if (selected) PopTextSpecs.chipSelected else PopTextSpecs.chip, color = fg, maxLines = 1)
        }
        if (onRemove != null) {
            Box(
                Modifier
                    .clickable(role = Role.Button, onClick = onRemove)
                    .semantics { contentDescription = "Remove $label" }
                    .padding(4.dp),
            ) { PopIcon(Icons.Rounded.Close, PopSize.iconChip, tint = fg) }
        }
    }
}

/** Equal segments with one selected (pink by default): Expense | Income | Transfer. */
@Composable
fun <T> PopSegmented(
    values: List<T>,
    selected: T,
    label: (T) -> String,
    onChange: (T) -> Unit,
    modifier: Modifier = Modifier,
    fill: (T) -> Color = { PopColors.pink },
    enabled: Boolean = true,
) {
    val shape = RoundedCornerShape(PopRadius.tile)
    Row(
        modifier
            .fillMaxWidth()
            .sticker(if (enabled) PopColors.white else PopColors.paper, shape, PopRadius.tile, shadow = 0.dp)
            .clip(shape),
    ) {
        values.forEachIndexed { i, v ->
            if (i > 0) Spacer(Modifier.width(PopBorder.regular).height(PopSize.segment).background(PopColors.ink))
            val on = v == selected
            Box(
                Modifier
                    .weight(1f)
                    .height(PopSize.segment)
                    .background(if (on && enabled) fill(v) else Color.Transparent)
                    .selectable(on, enabled = enabled, role = Role.Tab) { onChange(v) },
                contentAlignment = Alignment.Center,
            ) {
                PopText(label(v), if (on) PopTextSpecs.segmentSelected else PopTextSpecs.segment,
                    color = if (enabled) PopColors.ink else PopColors.inkMuted, maxLines = 1)
            }
        }
    }
}

/** On/off switch: 52×30, white off, mint on, knob slides in 150 ms. */
@Composable
fun PopSwitch(checked: Boolean, onCheckedChange: (Boolean) -> Unit, label: String, modifier: Modifier = Modifier, enabled: Boolean = true) {
    val knobX by animateDpAsState(
        if (checked) PopSize.switchWidth - PopSize.switchKnob - PopBorder.regular * 2 - 4.dp else 0.dp,
        tween(PopMotion.toggleMillis), label = "knob",
    )
    val shape = RoundedCornerShape(PopRadius.switchTrack)
    Box(
        modifier
            .heightIn(min = PopSize.tapTarget)
            .toggleable(checked, enabled = enabled, role = Role.Switch, onValueChange = onCheckedChange)
            .semantics { contentDescription = label },
        contentAlignment = Alignment.Center,
    ) {
        Box(
            Modifier
                .size(PopSize.switchWidth, PopSize.switchHeight)
                .sticker(
                    when { !enabled -> PopColors.paper; checked -> PopColors.mint; else -> PopColors.white },
                    shape, PopRadius.switchTrack, shadow = 0.dp,
                )
                .padding(2.dp),
            contentAlignment = Alignment.CenterStart,
        ) {
            Box(
                Modifier
                    .offset(x = knobX)
                    .size(PopSize.switchKnob)
                    .background(if (enabled) PopColors.white else PopColors.divider, CircleShape)
                    .border(PopBorder.thin, PopColors.ink, CircleShape),
            )
        }
    }
}

/** White field, 2 outline (2.5 when focused or in error), radius 14. Errors show in ink with ⚠. */
@Composable
fun PopTextField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    hint: String? = null,
    label: String? = null,
    error: String? = null,
    enabled: Boolean = true,
) {
    Column(modifier, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        if (label != null) PopText(label, PopTextSpecs.fieldLabel)
        val shape = RoundedCornerShape(PopRadius.field)
        val source = remember { MutableInteractionSource() }
        val focused by source.collectIsFocusedAsState()
        Box(
            Modifier
                .fillMaxWidth()
                .heightIn(min = PopSize.tapTarget)
                .sticker(if (enabled) PopColors.white else PopColors.paper, shape, PopRadius.field,
                    border = if (error != null || focused) PopBorder.regular else PopBorder.thin, shadow = 0.dp)
                .padding(horizontal = PopSpace.md),
            contentAlignment = Alignment.CenterStart,
        ) {
            if (value.isEmpty() && hint != null) PopText(hint, PopTextSpecs.inputHint)
            BasicTextField(
                value, onValueChange, enabled = enabled,
                textStyle = popTextStyle(PopTextSpecs.input, if (enabled) PopColors.ink else PopColors.inkMuted),
                cursorBrush = SolidColor(PopColors.ink),
                interactionSource = source,
                modifier = Modifier.fillMaxWidth(),
            )
        }
        if (error != null) PopFormError(error)
    }
}

/** Inline form error, 14/800 ink with a ⚠ icon. Sits directly above the primary button. */
@Composable
fun PopFormError(message: String, modifier: Modifier = Modifier) {
    Row(modifier, horizontalArrangement = Arrangement.spacedBy(6.dp), verticalAlignment = Alignment.CenterVertically) {
        PopIcon(Icons.Rounded.ErrorOutline, 16.dp)
        PopText(message, PopTextSpecs.formError)
    }
}

/** Small tilted label: UPI, Unsure, 80%. */
@Composable
fun StickerBadge(
    label: String,
    modifier: Modifier = Modifier,
    fill: Color = PopColors.white,
    tilt: Float = PopTilt.badge,
    gradient: PopGradient? = null,
) {
    val shape = RoundedCornerShape(PopRadius.badge)
    Box(
        modifier
            .popTilt(tilt)
            .sticker(fill, shape, PopRadius.badge, border = PopBorder.thin, shadow = 0.dp, brush = gradient?.brush)
            .padding(horizontal = 9.dp, vertical = 2.dp),
    ) { PopText(label, PopTextSpecs.badge.copy(caps = false)) }
}

/** 42 round category icon, tilted −5°. */
@Composable
fun CategoryDot(icon: ImageVector, fill: Color, modifier: Modifier = Modifier, size: Dp = PopSize.categoryDot) {
    Box(
        modifier
            .popTilt(PopTilt.categoryDot)
            .size(size)
            .background(fill, CircleShape)
            .border(PopBorder.thin, PopColors.ink, CircleShape),
        contentAlignment = Alignment.Center,
    ) { PopIcon(icon, size * 0.48f) }
}

/** A card holding rows separated by 2 divider lines. */
@Composable
fun StickerList(modifier: Modifier = Modifier, rows: List<@Composable () -> Unit>) {
    // No padding: a selected row's fill reaches the outline on every edge.
    StickerCard(modifier.fillMaxWidth(), padding = PaddingValues(0.dp)) {
        rows.forEachIndexed { i, row ->
            if (i > 0) Spacer(Modifier.fillMaxWidth().height(PopBorder.divider).background(PopColors.divider))
            row()
        }
    }
}

/** One list row: dot, title over a muted second line, right-aligned tabular amount. */
@Composable
fun StickerListRow(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    amount: String? = null,
    leading: (@Composable () -> Unit)? = null,
    badge: (@Composable () -> Unit)? = null,
    amountCaption: String? = null,
    selected: Boolean = false,
    onClick: (() -> Unit)? = null,
) {
    Row(
        modifier
            .fillMaxWidth()
            .background(if (selected) PopColors.yellow else Color.Transparent)
            .semantics { this.selected = selected }
            .heightIn(min = PopSize.rowMin)
            .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier)
            .padding(horizontal = PopSpace.lg, vertical = 11.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(PopSpace.md),
    ) {
        leading?.invoke()
        Column(Modifier.weight(1f)) {
            Row(horizontalArrangement = Arrangement.spacedBy(PopSpace.sm), verticalAlignment = Alignment.CenterVertically) {
                PopText(title, PopTextSpecs.rowTitle, maxLines = 1)
                badge?.invoke()
            }
            if (subtitle != null) PopText(subtitle, PopTextSpecs.caption, maxLines = 1)
        }
        if (amount != null) {
            Column(horizontalAlignment = Alignment.End) {
                PopText(amount, PopTextSpecs.rowAmount)
                if (amountCaption != null) PopText(amountCaption, PopTextSpecs.caption)
            }
        }
    }
}

/** Goal or budget bar: white track 18 high, 2 outline, bright fill. */
@Composable
fun PopProgressBar(value: Float, modifier: Modifier = Modifier, fill: Color = PopColors.mint, label: String) {
    val v = value.coerceIn(0f, 1f)
    val shape = RoundedCornerShape(PopRadius.progressTrack)
    Box(
        modifier
            .fillMaxWidth()
            .height(PopSize.progressBar)
            .sticker(PopColors.white, shape, PopRadius.progressTrack, border = PopBorder.thin, shadow = 0.dp)
            .padding(PopBorder.thin)
            .clip(RoundedCornerShape(PopRadius.progressFill))
            .semantics { contentDescription = "$label, ${(v * 100).toInt()}%" },
    ) {
        Box(Modifier.fillMaxWidth(v).height(PopSize.progressBar).background(fill)) {
            // Straight ink cut at the leading edge, as on every platform.
            if (v > 0f && v < 1f) {
                Box(Modifier.align(Alignment.CenterEnd).width(PopBorder.thin).fillMaxHeight().background(PopColors.ink))
            }
        }
    }
}

/** One destination in [PopNavBar]. */
data class PopNavItem(val icon: ImageVector, val label: String)

/** Bottom navigation: four destinations and the tilted pink add button in the middle. */
@Composable
fun PopNavBar(items: List<PopNavItem>, selected: Int, onSelect: (Int) -> Unit, onAdd: () -> Unit, modifier: Modifier = Modifier) {
    require(items.size == 4) { "PopNavBar has four destinations plus Add" }
    Column(modifier.fillMaxWidth().background(PopColors.white)) {
        Spacer(Modifier.fillMaxWidth().height(PopBorder.regular).background(PopColors.ink))
        Row(Modifier.padding(horizontal = 8.dp, vertical = 10.dp), verticalAlignment = Alignment.CenterVertically) {
            @Composable
            fun RowScope.slot(i: Int) {
                val on = i == selected
                Column(
                    Modifier
                        .weight(1f)
                        .padding(horizontal = 2.dp)
                        .heightIn(min = PopSize.tapTarget)
                        .selectable(on, role = Role.Tab) { onSelect(i) },
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                ) {
                    val pill = RoundedCornerShape(PopRadius.navPill)
                    Box(
                        if (on) Modifier.sticker(PopColors.yellow, pill, PopRadius.navPill, PopBorder.thin, 0.dp).padding(horizontal = 10.dp, vertical = 2.dp)
                        else Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                    ) { PopIcon(items[i].icon, PopSize.iconNav, tint = if (on) PopColors.ink else PopColors.inkMuted) }
                    Spacer(Modifier.height(3.dp))
                    // Nav labels grow with system text up to 150%, then stop.
                    val density = LocalDensity.current
                    CompositionLocalProvider(LocalDensity provides Density(density.density, minOf(density.fontScale, 1.5f))) {
                        PopText(items[i].label, if (on) PopTextSpecs.navLabelSelected else PopTextSpecs.navLabel, maxLines = 1)
                    }
                }
            }
            slot(0); slot(1)
            // The add slot is as wide as the button plus room for tilt and shadow; the four
            // items share the rest, so on a narrow phone it never overlaps its neighbours.
            Box(Modifier.padding(start = PopSpace.sm, end = PopSpace.sm + PopShadow.regular), contentAlignment = Alignment.Center) { PopAddButton(onAdd) }
            slot(2); slot(3)
        }
    }
}

/** Pink sticker add button, radius 20, tilted −6°, with a 28 "+". */
@Composable
fun PopAddButton(onClick: () -> Unit, modifier: Modifier = Modifier, label: String = "Add transaction") {
    Box(modifier.popTilt(PopTilt.addButton).semantics { contentDescription = label }) {
        StickerCard(fill = PopColors.pink, radius = PopRadius.addButton, padding = PaddingValues(13.dp), onClick = onClick) {
            PopIcon(Icons.Rounded.Add, PopSize.iconAdd)
        }
    }
}

/** One quick-add tile. */
data class PopQuickAddTile(val label: String, val icon: ImageVector, val fill: Color, val tilt: Float, val onClick: () -> Unit)

/** Home's Type it / Say it / Scan it row: three equal tiles, 12 apart. */
@Composable
fun PopQuickAddRow(tiles: List<PopQuickAddTile>, modifier: Modifier = Modifier) {
    Row(modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(PopSpace.md)) {
        tiles.forEach { t ->
            StickerCard(
                Modifier.weight(1f), fill = t.fill, tilt = t.tilt,
                padding = PaddingValues(vertical = PopSpace.md, horizontal = PopSpace.xs), onClick = t.onClick,
            ) {
                Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
                    PopIcon(t.icon, PopSize.iconTile)
                    Spacer(Modifier.height(PopSpace.xs))
                    PopText(t.label, PopTextSpecs.tileLabel, maxLines = 1)
                }
            }
        }
    }
}
