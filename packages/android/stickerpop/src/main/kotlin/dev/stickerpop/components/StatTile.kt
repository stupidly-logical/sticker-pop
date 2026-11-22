package dev.stickerpop.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/** Which way a [PopStatTile]'s change went, and whether that's good. */
enum class PopTrend { UpGood, UpBad, DownGood, DownBad }

/**
 * A headline number on a dashboard: a 13/800 caps label, a 28/800 tabular
 * figure, an optional change badge ("+12.4%", mint when good, orange when
 * not) and an optional caption. A StickerCard, white by default.
 */
@Composable
fun PopStatTile(
    label: String,
    value: String,
    modifier: Modifier = Modifier,
    change: String? = null,
    trend: PopTrend = PopTrend.UpGood,
    caption: String? = null,
    fill: Color = PopColors.white,
    onClick: (() -> Unit)? = null,
) {
    val up = trend == PopTrend.UpGood || trend == PopTrend.UpBad
    val good = trend == PopTrend.UpGood || trend == PopTrend.DownGood
    val spoken = listOfNotNull(label, value, change?.let { (if (up) "up " else "down ") + it }, caption).joinToString(", ")
    StickerCard(modifier.fillMaxWidth().clearAndSetSemantics { contentDescription = spoken }, fill = fill, onClick = onClick) {
        Column(verticalArrangement = Arrangement.spacedBy(PopSpace.xs)) {
            PopText(label, PopTextSpecs.sectionLabel)
            PopText(value, PopTextSpecs.cardFigure)
            if (change != null) StickerBadge((if (up) "+" else "−") + change, fill = if (good) PopColors.mint else PopColors.orange)
            if (caption != null) PopText(caption, PopTextSpecs.caption)
        }
    }
}
