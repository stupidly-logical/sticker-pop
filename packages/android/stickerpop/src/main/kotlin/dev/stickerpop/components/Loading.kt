package dev.stickerpop.components

import android.provider.Settings
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalInspectionMode
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace

/** True when the system asks for less motion (animator duration scale 0), or in previews and screenshots. */
@Composable
fun popReduceMotion(): Boolean {
    if (LocalInspectionMode.current) return true
    val context = LocalContext.current
    return remember(context) {
        runCatching { Settings.Global.getFloat(context.contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1f) == 0f }.getOrDefault(false)
    }
}

@Composable
private fun pulseAlpha(): Float {
    if (popReduceMotion()) return 1f
    val t = rememberInfiniteTransition(label = "skeleton")
    val a by t.animateFloat(1f, 0.55f, infiniteRepeatable(tween(PopMotion.pulseMillis, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "pulse")
    return a
}

/** A placeholder text line, 14 high: divider-coloured, no outline, pulsing (still under reduced motion). */
@Composable
fun PopSkeletonLine(modifier: Modifier = Modifier, width: Dp? = null, height: Dp = PopSize.skeletonLine) {
    val a = pulseAlpha()
    Box(
        modifier
            .then(if (width != null) Modifier.width(width) else Modifier.fillMaxWidth())
            .height(height)
            .alpha(a)
            .background(PopColors.divider, RoundedCornerShape(PopRadius.skeletonLine)),
    )
}

/** A placeholder circle, e.g. where a category dot will be. */
@Composable
fun PopSkeletonCircle(modifier: Modifier = Modifier, size: Dp = PopSize.categoryDot) {
    val a = pulseAlpha()
    Box(modifier.size(size).alpha(a).background(PopColors.divider, CircleShape))
}

/** A placeholder block, e.g. where a card or chart will be. */
@Composable
fun PopSkeletonBlock(height: Dp, modifier: Modifier = Modifier, radius: Dp = PopRadius.card) {
    val a = pulseAlpha()
    Box(modifier.fillMaxWidth().height(height).alpha(a).background(PopColors.divider, RoundedCornerShape(radius)))
}

/** A [StickerList] of skeleton rows (circle and two lines), announced once as "Loading". */
@Composable
fun PopSkeletonList(modifier: Modifier = Modifier, rows: Int = 3, label: String = "Loading") {
    Box(modifier.semantics { contentDescription = label; liveRegion = LiveRegionMode.Polite }) {
        StickerList(Modifier.clearAndSetSemantics {}, rows = List(rows) { i ->
            @Composable {
                Row(Modifier.fillMaxWidth().padding(horizontal = PopSpace.lg, vertical = 12.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(PopSpace.md)) {
                    PopSkeletonCircle()
                    Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
                        PopSkeletonLine(Modifier.fillMaxWidth(if (i % 2 == 0) 0.6f else 0.45f))
                        PopSkeletonLine(Modifier.fillMaxWidth(0.8f), height = 10.dp)
                    }
                    PopSkeletonLine(width = 56.dp)
                }
            }
        })
    }
}

/** A 24 divider ring with a turning ink arc, for short waits. Still under reduced motion. */
@Composable
fun PopSpinner(modifier: Modifier = Modifier, size: Dp = PopSize.spinner, label: String = "Loading") {
    val angle = if (popReduceMotion()) 0f else {
        val t = rememberInfiniteTransition(label = "spinner")
        val v by t.animateFloat(0f, 360f, infiniteRepeatable(tween(PopMotion.spinMillis, easing = LinearEasing)), label = "spin")
        v
    }
    Canvas(modifier.size(size).rotate(angle).semantics { contentDescription = label; liveRegion = LiveRegionMode.Polite }) {
        val w = this.size.width / 8
        drawCircle(PopColors.divider, radius = (this.size.minDimension - w) / 2, style = Stroke(w))
        drawArc(PopColors.ink, -90f, 90f, false, topLeft = androidx.compose.ui.geometry.Offset(w / 2, w / 2),
            size = androidx.compose.ui.geometry.Size(this.size.width - w, this.size.height - w), style = Stroke(w, cap = StrokeCap.Round))
    }
}
