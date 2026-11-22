package dev.stickerpop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.focusable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.key
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.ProgressBarRangeInfo
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.disabled
import androidx.compose.ui.semantics.progressBarRangeInfo
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.setProgress
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import kotlin.math.roundToInt

/**
 * A slider for picking a number in a range, like a budget limit: a white
 * track 18 high with a 2 ink outline, filled mint (or [fill]) up to a 28
 * white sticker knob with a 3/3 shadow. Drag or tap to set it; arrow keys
 * step it by [step] (default: 1/20 of the range).
 */
@Composable
fun PopSlider(
    value: Float,
    onValueChange: ((Float) -> Unit)?,
    label: String,
    modifier: Modifier = Modifier,
    range: ClosedFloatingPointRange<Float> = 0f..1f,
    step: Float? = null,
    fill: Color = PopColors.mint,
    valueLabel: (Float) -> String = { if (it == it.roundToInt().toFloat()) it.roundToInt().toString() else "%.1f".format(it) },
) {
    val span = range.endInclusive - range.start
    val keyStep = step ?: (span / 20f)
    fun snap(v: Float): Float {
        var x = v.coerceIn(range)
        if (step != null && step > 0f) x = (range.start + ((x - range.start) / step).roundToInt() * step).coerceIn(range)
        return x
    }
    val current by rememberUpdatedState(value)
    val set = { v: Float -> val x = snap(v); if (x != current) onValueChange?.invoke(x) }
    val enabled = onValueChange != null
    val t = if (span == 0f) 0f else ((value - range.start) / span).coerceIn(0f, 1f)
    val source = remember { MutableInteractionSource() }
    val focused by source.collectIsFocusedAsState()
    val knobPx = with(LocalDensity.current) { PopSize.sliderKnob.toPx() }
    BoxWithConstraints(
        modifier
            .fillMaxWidth()
            .height(PopSize.tapTarget)
            .semantics {
                contentDescription = label
                stateDescription = valueLabel(value)
                progressBarRangeInfo = ProgressBarRangeInfo(value, range, if (step != null && step > 0f) (span / step).roundToInt() - 1 else 0)
                if (enabled) setProgress { set(it); true } else disabled()
            }
            .focusable(enabled, source)
            .onKeyEvent {
                if (!enabled || it.type != KeyEventType.KeyDown) return@onKeyEvent false
                when (it.key) {
                    Key.DirectionRight, Key.DirectionUp -> { set(current + keyStep); true }
                    Key.DirectionLeft, Key.DirectionDown -> { set(current - keyStep); true }
                    else -> false
                }
            },
        contentAlignment = Alignment.CenterStart,
    ) {
        val widthPx = constraints.maxWidth.toFloat()
        val fromX = { x: Float -> set(range.start + ((x - knobPx / 2) / (widthPx - knobPx)).coerceIn(0f, 1f) * span) }
        val gestures = if (enabled) Modifier
            .pointerInput(widthPx) { detectTapGestures { fromX(it.x) } }
            .pointerInput(widthPx) { detectHorizontalDragGestures { change, _ -> fromX(change.position.x) } } else Modifier
        Box(Modifier.fillMaxWidth().fillMaxHeight().then(gestures), contentAlignment = Alignment.CenterStart) {
            val inset = PopSize.sliderKnob / 2 - PopSize.progressBar / 2
            val trackShape = RoundedCornerShape(PopRadius.progressTrack)
            Box(
                Modifier
                    .padding(horizontal = inset)
                    .fillMaxWidth()
                    .height(PopSize.progressBar)
                    .background(if (enabled) PopColors.white else PopColors.paper, trackShape)
                    .clip(trackShape)
                    .drawBehind {
                        val knob = PopSize.sliderKnob.toPx()
                        val w = t * (widthPx - knob) + PopSize.progressBar.toPx() / 2
                        drawRect(if (enabled) fill else PopColors.divider, size = Size(w, size.height))
                    }
                    .border(PopBorder.thin, PopColors.ink, trackShape),
            )
            val x = with(LocalDensity.current) { (t * (widthPx - knobPx)).toDp() }
            Box(
                Modifier
                    .offset(x = x)
                    .size(PopSize.sliderKnob + PopShadow.small)
                    .drawBehind {
                        val k = PopSize.sliderKnob.toPx()
                        val s = PopShadow.small.toPx()
                        if (enabled) drawCircle(PopColors.ink, k / 2, Offset(k / 2 + s, k / 2 + s))
                        drawCircle(PopColors.white, k / 2, Offset(k / 2, k / 2))
                        val b = (if (focused) PopBorder.spotlight else PopBorder.regular).toPx()
                        drawCircle(PopColors.ink, k / 2 - b / 2, Offset(k / 2, k / 2), style = androidx.compose.ui.graphics.drawscope.Stroke(b))
                    },
            )
        }
    }
}
