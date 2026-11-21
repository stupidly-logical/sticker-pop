package dev.stickerpop.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs
import kotlin.math.max
import kotlin.math.roundToInt

/** One slice, bar or legend entry. */
data class PopDatum(val label: String, val value: Float, val color: Color)

/** Donut: one bright per slice, each outlined in 2.5 ink, around a yellow centre disc. */
@Composable
fun PopDonut(
    data: List<PopDatum>,
    contentDescription: String,
    modifier: Modifier = Modifier,
    size: Dp = 180.dp,
    thickness: Dp = 38.dp,
    center: (@Composable () -> Unit)? = null,
) {
    Box(modifier.size(size).semantics { this.contentDescription = contentDescription }, contentAlignment = Alignment.Center) {
        Canvas(Modifier.fillMaxSize()) {
            val total = data.sumOf { it.value.toDouble() }.toFloat()
            val stroke = PopBorder.regular.toPx()
            val outer = this.size.minDimension / 2 - stroke / 2
            val inner = outer - thickness.toPx()
            val c = this.center
            val ink = Stroke(width = stroke)
            if (total > 0f) {
                var start = -90f
                data.forEach { d ->
                    val sweep = d.value / total * 360f
                    val path = Path().apply {
                        arcTo(androidx.compose.ui.geometry.Rect(c, outer), start, sweep, true)
                        arcTo(androidx.compose.ui.geometry.Rect(c, inner), start + sweep, -sweep, false)
                        close()
                    }
                    drawPath(path, d.color)
                    drawPath(path, PopColors.ink, style = ink)
                    start += sweep
                }
            } else {
                drawCircle(PopColors.white, outer, c)
                drawCircle(PopColors.ink, outer, c, style = ink)
            }
            val disc = inner - 8.dp.toPx()
            drawCircle(PopColors.yellow, disc, c)
            drawCircle(PopColors.ink, disc, c, style = ink)
        }
        center?.invoke()
    }
}

/**
 * Vertical bars, bright fills, ink outlines, no gridlines. The bar at
 * [highlightIndex] gets a heavier outline and a 2/2 shadow, so emphasis
 * doesn't rely on colour.
 */
@Composable
fun PopBarChart(
    data: List<PopDatum>,
    contentDescription: String,
    modifier: Modifier = Modifier,
    height: Dp = 140.dp,
    highlightIndex: Int? = null,
) {
    val maxValue = data.maxOfOrNull { it.value } ?: 0f
    Row(
        modifier.fillMaxWidth().semantics { this.contentDescription = contentDescription },
        verticalAlignment = Alignment.Bottom,
    ) {
        data.forEachIndexed { i, d ->
            val on = i == highlightIndex
            val barHeight = if (maxValue == 0f) 4.dp else max(4f, d.value / maxValue * height.value).dp
            Column(Modifier.weight(1f).padding(horizontal = 4.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                val shape = RoundedCornerShape(topStart = 8.dp, topEnd = 8.dp)
                Box(Modifier.fillMaxWidth().height(barHeight)) {
                    if (on) {
                        Box(
                            Modifier.fillMaxSize().offset(PopShadow.chip, PopShadow.chip).background(PopColors.ink, shape),
                        )
                    }
                    Box(
                        Modifier.fillMaxSize().background(d.color, shape).border(if (on) 3.dp else PopBorder.thin, PopColors.ink, shape),
                    )
                }
                Spacer(Modifier.height(6.dp))
                PopText(d.label, if (on) PopTextSpecs.navLabelSelected else PopTextSpecs.navLabel, maxLines = 1)
            }
        }
    }
}

/** Legend: 12 square swatches (1.5 outline, radius 4), label 14/700, percentage 14/800 tabular. */
@Composable
fun PopLegend(data: List<PopDatum>, modifier: Modifier = Modifier) {
    val total = data.sumOf { it.value.toDouble() }
    Column(modifier, verticalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
        data.forEach { d ->
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
                val shape = RoundedCornerShape(PopRadius.swatch)
                Box(Modifier.size(PopSize.swatch).background(d.color, shape).border(PopBorder.swatch, PopColors.ink, shape))
                PopText(d.label, PopTextSpecs.legendLabel, Modifier.weight(1f))
                val pct = if (total == 0.0) 0 else (d.value / total * 100).roundToInt()
                PopText("$pct%", PopTextSpecs.legendValue)
            }
        }
    }
}
