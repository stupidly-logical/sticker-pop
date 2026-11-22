package dev.stickerpop.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * Shows a PIN or one-time code being typed: a row of [length] boxes (48 × 56,
 * radius 14). Filled boxes show an ink dot ([obscure]) or the digit; the next
 * box has a 2.5 outline. With [error] the boxes turn orange and the message
 * shows below. Feed it from a [PopKeypad] (decimal = false).
 */
@Composable
fun PopPinField(value: String, modifier: Modifier = Modifier, length: Int = 4, obscure: Boolean = true, error: String? = null, label: String = "PIN") {
    val bad = error != null
    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(PopSpace.md)) {
        Row(
            Modifier.clearAndSetSemantics { contentDescription = label; stateDescription = "${value.length} of $length entered"; liveRegion = LiveRegionMode.Polite },
            horizontalArrangement = Arrangement.spacedBy(PopSpace.sm),
        ) {
            repeat(length) { i ->
                val fill by animateColorAsState(if (bad) PopColors.orange else PopColors.white, tween(PopMotion.toggleMillis), label = "pin")
                val shape = RoundedCornerShape(PopRadius.field)
                Box(
                    Modifier
                        .weight(1f, fill = false)
                        .widthIn(max = 48.dp)
                        .size(48.dp, 56.dp)
                        .height(56.dp)
                        .background(fill, shape)
                        .border(if (!bad && i == value.length) PopBorder.regular else PopBorder.thin, PopColors.ink, shape),
                    contentAlignment = Alignment.Center,
                ) {
                    if (i < value.length) {
                        if (obscure) Box(Modifier.size(14.dp).background(PopColors.ink, CircleShape))
                        else PopText(value[i].toString(), PopTextSpecs.keypadKey)
                    }
                }
            }
        }
        if (error != null) PopFormError(error)
    }
}
