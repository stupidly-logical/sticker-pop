package dev.stickerpop.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.triStateToggleable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.state.ToggleableState
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * A checkbox: a 24 rounded square (radius 7). Unchecked it is white with a
 * 2 ink outline; checked it fills mint with a 2.5 outline and an ink tick.
 * [ToggleableState.Indeterminate] shows a dash (some, not all). Padded to a
 * 48 tap target. Pair it with a label: usually use [PopCheckboxRow].
 */
@Composable
fun PopCheckbox(state: ToggleableState, onClick: (() -> Unit)?, label: String, modifier: Modifier = Modifier) {
    Box(
        modifier
            .size(PopSize.tapTarget)
            .triStateToggleable(state, remember { MutableInteractionSource() }, indication = null, enabled = onClick != null, role = Role.Checkbox) { onClick?.invoke() }
            .semantics { contentDescription = label },
        contentAlignment = Alignment.Center,
    ) { PopCheckboxMark(state, enabled = onClick != null) }
}

/** Convenience for a plain on/off checkbox. */
@Composable
fun PopCheckbox(checked: Boolean, onCheckedChange: ((Boolean) -> Unit)?, label: String, modifier: Modifier = Modifier) =
    PopCheckbox(ToggleableState(checked), onCheckedChange?.let { { it(!checked) } }, label, modifier)

/** The checkbox drawing on its own (no tap handling). */
@Composable
fun PopCheckboxMark(state: ToggleableState, enabled: Boolean = true, modifier: Modifier = Modifier) {
    val on = state != ToggleableState.Off
    val fill by animateColorAsState(
        when {
            !enabled -> if (on) PopColors.divider else PopColors.paper
            on -> PopColors.mint
            else -> PopColors.white
        },
        tween(PopMotion.toggleMillis), label = "checkbox fill",
    )
    val mark = if (enabled) PopColors.ink else PopColors.inkMuted
    val shape = RoundedCornerShape(PopRadius.checkbox)
    Canvas(
        modifier
            .size(PopSize.checkbox)
            .background(fill, shape)
            .border(if (on) PopBorder.regular else PopBorder.thin, PopColors.ink, shape),
    ) {
        val w = size.width
        val h = size.height
        val stroke = Stroke(2.6.dp.toPx(), cap = StrokeCap.Round, join = StrokeJoin.Round)
        when (state) {
            ToggleableState.On -> drawPath(
                Path().apply { moveTo(w * 0.24f, h * 0.52f); lineTo(w * 0.43f, h * 0.7f); lineTo(w * 0.77f, h * 0.32f) },
                mark, style = stroke,
            )
            ToggleableState.Indeterminate -> drawLine(mark, Offset(w * 0.28f, h * 0.5f), Offset(w * 0.72f, h * 0.5f), stroke.width, StrokeCap.Round)
            ToggleableState.Off -> Unit
        }
    }
}

/**
 * A radio button: a 24 circle. Unselected it is white with a 2 ink outline;
 * selected it fills yellow with a 2.5 outline and a 10 ink dot. Usually use
 * [PopRadioRow].
 */
@Composable
fun PopRadio(selected: Boolean, onClick: (() -> Unit)?, label: String, modifier: Modifier = Modifier) {
    Box(
        modifier
            .size(PopSize.tapTarget)
            .selectable(selected, remember { MutableInteractionSource() }, indication = null, enabled = onClick != null, role = Role.RadioButton) { onClick?.invoke() }
            .semantics { contentDescription = label },
        contentAlignment = Alignment.Center,
    ) { PopRadioMark(selected, enabled = onClick != null) }
}

/** The radio drawing on its own (no tap handling). */
@Composable
fun PopRadioMark(selected: Boolean, enabled: Boolean = true, modifier: Modifier = Modifier) {
    val fill by animateColorAsState(
        when {
            !enabled -> if (selected) PopColors.divider else PopColors.paper
            selected -> PopColors.yellow
            else -> PopColors.white
        },
        tween(PopMotion.toggleMillis), label = "radio fill",
    )
    Box(
        modifier
            .size(PopSize.checkbox)
            .background(fill, CircleShape)
            .border(if (selected) PopBorder.regular else PopBorder.thin, PopColors.ink, CircleShape),
        contentAlignment = Alignment.Center,
    ) {
        if (selected) Box(Modifier.size(PopSize.radioDot).background(if (enabled) PopColors.ink else PopColors.inkMuted, CircleShape))
    }
}

/** A tappable row with a checkbox, a 16/700 label and an optional caption. The whole row toggles. */
@Composable
fun PopCheckboxRow(label: String, state: ToggleableState, onClick: (() -> Unit)?, modifier: Modifier = Modifier, caption: String? = null) {
    ChoiceRow(
        modifier.triStateToggleable(state, remember { MutableInteractionSource() }, indication = null, enabled = onClick != null, role = Role.Checkbox) { onClick?.invoke() },
        label, caption, onClick != null,
    ) { PopCheckboxMark(state, enabled = onClick != null) }
}

/** Convenience for a plain on/off checkbox row. */
@Composable
fun PopCheckboxRow(label: String, checked: Boolean, onCheckedChange: ((Boolean) -> Unit)?, modifier: Modifier = Modifier, caption: String? = null) =
    PopCheckboxRow(label, ToggleableState(checked), onCheckedChange?.let { { it(!checked) } }, modifier, caption)

/** A tappable row with a radio, a 16/700 label and an optional caption. */
@Composable
fun PopRadioRow(label: String, selected: Boolean, onClick: (() -> Unit)?, modifier: Modifier = Modifier, caption: String? = null) {
    ChoiceRow(
        modifier.selectable(selected, remember { MutableInteractionSource() }, indication = null, enabled = onClick != null, role = Role.RadioButton) { onClick?.invoke() },
        label, caption, onClick != null,
    ) { PopRadioMark(selected, enabled = onClick != null) }
}

@Composable
private fun ChoiceRow(modifier: Modifier, label: String, caption: String?, enabled: Boolean, control: @Composable () -> Unit) {
    Row(
        modifier
            .fillMaxWidth()
            .heightIn(min = PopSize.rowMin)
            .padding(horizontal = PopSpace.lg, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(PopSpace.md),
    ) {
        control()
        Column(Modifier.weight(1f)) {
            PopText(label, PopTextSpecs.input, color = if (enabled) PopColors.ink else PopColors.inkMuted)
            if (caption != null) PopText(caption, PopTextSpecs.caption)
        }
    }
}
