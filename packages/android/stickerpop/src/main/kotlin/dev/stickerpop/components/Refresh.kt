package dev.stickerpop.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.customActions
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.Velocity
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopShadow
import kotlinx.coroutines.launch

private val IndicatorSize = 44.dp
private val Trigger = 64.dp
private val MaxPull = 96.dp

/**
 * The pull-to-refresh sticker: a 44 white circle with a 2 ink outline and a
 * 3 hard shadow. While pulling, an ink ring fills with [progress] (0 to 1,
 * full means "let go to refresh"); with [progress] null it spins.
 */
@Composable
fun PopRefreshIndicator(progress: Float?, modifier: Modifier = Modifier) {
    Box(modifier.size(IndicatorSize + PopShadow.small), contentAlignment = Alignment.TopStart) {
        Box(Modifier.offset(PopShadow.small, PopShadow.small).size(IndicatorSize).background(PopColors.ink, CircleShape))
        Box(
            Modifier.size(IndicatorSize).background(PopColors.white, CircleShape).border(PopBorder.thin, PopColors.ink, CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            if (progress == null) {
                PopSpinner(size = 20.dp, label = "Refreshing")
            } else {
                Canvas(Modifier.size(20.dp).clearAndSetSemantics {}) {
                    val w = size.width / 8
                    drawCircle(PopColors.divider, radius = (size.minDimension - w) / 2, style = Stroke(w))
                    drawArc(PopColors.ink, -90f, 360f * progress.coerceIn(0f, 1f), false, topLeft = Offset(w / 2, w / 2),
                        size = Size(size.width - w, size.height - w), style = Stroke(w, cap = StrokeCap.Round))
                }
            }
        }
    }
}

/**
 * Wraps a scrolling list so pulling down from the top refreshes it. The
 * [PopRefreshIndicator] follows the pull (half the finger's travel, up to
 * 96); letting go past 64 calls [onRefresh] and the indicator spins at 64
 * until it returns. Screen readers get a "Refresh" action instead.
 */
@Composable
fun PopPullToRefresh(onRefresh: suspend () -> Unit, modifier: Modifier = Modifier, content: @Composable () -> Unit) {
    val scope = rememberCoroutineScope()
    val density = LocalDensity.current
    val trigger = with(density) { Trigger.toPx() }
    val max = with(density) { MaxPull.toPx() }
    var pull by remember { mutableFloatStateOf(0f) }
    var refreshing by remember { mutableStateOf(false) }
    val refresh = {
        if (!refreshing) {
            refreshing = true
            pull = trigger
            scope.launch {
                try { onRefresh() } finally { refreshing = false; pull = 0f }
            }
        }
    }
    val connection = remember(trigger, max) {
        object : NestedScrollConnection {
            override fun onPreScroll(available: Offset, source: NestedScrollSource): Offset {
                if (refreshing || pull <= 0f || available.y >= 0f) return Offset.Zero
                val next = (pull + available.y / 2).coerceAtLeast(0f)
                val used = (next - pull) * 2
                pull = next
                return Offset(0f, used)
            }

            override fun onPostScroll(consumed: Offset, available: Offset, source: NestedScrollSource): Offset {
                if (refreshing || source != NestedScrollSource.UserInput || available.y <= 0f) return Offset.Zero
                pull = (pull + available.y / 2).coerceAtMost(max)
                return Offset(0f, available.y)
            }

            override suspend fun onPreFling(available: Velocity): Velocity {
                if (refreshing || pull <= 0f) return Velocity.Zero
                if (pull >= trigger) refresh() else pull = 0f
                return available
            }
        }
    }
    Box(
        modifier
            .clipToBounds()
            .nestedScroll(connection)
            .semantics { customActions = listOf(CustomAccessibilityAction("Refresh") { refresh(); true }) },
    ) {
        content()
        if (refreshing || pull > 0f) {
            val top = with(density) { (if (refreshing) trigger else pull).toDp() } - IndicatorSize
            PopRefreshIndicator(if (refreshing) null else pull / trigger, Modifier.align(Alignment.TopCenter).offset(y = top))
        }
    }
}
