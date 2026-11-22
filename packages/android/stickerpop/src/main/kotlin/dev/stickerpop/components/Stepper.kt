package dev.stickerpop.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.Remove
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.ProgressBarRangeInfo
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.progressBarRangeInfo
import androidx.compose.ui.semantics.setProgress
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopTextSpecs
import kotlin.math.roundToInt

/**
 * A small counter, like how many people split a bill: − and + sticker
 * buttons with the number between them in 20/800. Each button disables at
 * its limit; screen readers adjust it as one control.
 */
@Composable
fun PopStepper(value: Int, onValueChange: ((Int) -> Unit)?, label: String, modifier: Modifier = Modifier, range: IntRange = 0..99, step: Int = 1) {
    val canDown = onValueChange != null && value - step >= range.first
    val canUp = onValueChange != null && value + step <= range.last
    Row(
        modifier.clearAndSetSemantics {
            contentDescription = label
            stateDescription = "$value"
            progressBarRangeInfo = ProgressBarRangeInfo(value.toFloat(), range.first.toFloat()..range.last.toFloat(), (range.last - range.first) / step - 1)
            if (onValueChange != null) setProgress { onValueChange(it.roundToInt().coerceIn(range)); true }
        },
        verticalAlignment = Alignment.CenterVertically,
    ) {
        PopIconButton(Icons.Rounded.Remove, "Less", onClick = { onValueChange?.invoke(value - step) }, enabled = canDown)
        Box(Modifier.widthIn(min = 48.dp), contentAlignment = Alignment.Center) { PopText("$value", PopTextSpecs.sectionHeading) }
        PopIconButton(Icons.Rounded.Add, "More", onClick = { onValueChange?.invoke(value + step) }, enabled = canUp)
    }
}
