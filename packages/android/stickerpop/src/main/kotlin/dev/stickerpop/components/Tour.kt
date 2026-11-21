package dev.stickerpop.components

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.ClipOp
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.clipPath
import androidx.compose.ui.layout.boundsInRoot
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import dev.stickerpop.popTilt
import dev.stickerpop.sticker
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs
import dev.stickerpop.tokens.PopTilt

/** Tour progress: 10-high dots, 22 wide for the current step, pink once reached. */
@Composable
fun PopProgressDots(count: Int, current: Int, modifier: Modifier = Modifier) {
    Row(
        modifier.semantics { contentDescription = "Step ${current + 1} of $count" },
        horizontalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        repeat(count) { i ->
            val width by animateDpAsState(
                if (i == current) PopSize.progressDotCurrent else PopSize.progressDot,
                tween(PopMotion.toggleMillis), label = "dot",
            )
            val shape = RoundedCornerShape(PopSize.progressDot / 2)
            Box(
                Modifier
                    .size(width, PopSize.progressDot)
                    .background(if (i <= current) PopColors.pink else PopColors.white, shape)
                    .border(PopBorder.thin, PopColors.ink, shape),
            )
        }
    }
}

/** The yellow coach-mark card: dots and "Skip", title, body, then "Next" or "Got it". */
@Composable
fun PopTourCard(
    step: Int,
    count: Int,
    title: String,
    body: String,
    onNext: () -> Unit,
    modifier: Modifier = Modifier,
    onSkip: (() -> Unit)? = null,
    tilt: Float = if (step % 2 == 0) PopTilt.hero else PopTilt.heroAlt,
) {
    val last = step == count - 1
    Column(
        modifier
            .popTilt(tilt)
            .fillMaxWidth()
            .sticker(PopColors.yellow, RoundedCornerShape(PopRadius.card), PopRadius.card, shadow = PopShadow.large)
            .padding(PopSpace.xl),
        verticalArrangement = Arrangement.spacedBy(PopSpace.sm),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            PopProgressDots(count, step)
            Spacer(Modifier.weight(1f))
            if (onSkip != null && !last) PopTextButton("Skip", onSkip, underline = true)
        }
        PopText(title, PopTextSpecs.sheetTitle, Modifier.semantics { heading() })
        PopText(body, PopTextSpecs.body)
        Spacer(Modifier.height(PopSpace.sm))
        StickerButton(if (last) "Got it" else "Next", onNext)
    }
}

/** One stop on a tour; [target] matches a [Modifier.popTourTarget] key. */
data class PopTourStep(val target: String, val title: String, val body: String)

/** Tracks tour targets and the current step. */
@Stable
class PopTourState {
    internal val bounds = mutableStateMapOf<String, Rect>()
    var steps by mutableStateOf<List<PopTourStep>>(emptyList())
        private set
    var index by mutableStateOf(-1)
        private set
    val isRunning: Boolean get() = index in steps.indices

    fun start(steps: List<PopTourStep>) {
        this.steps = steps
        index = if (steps.isEmpty()) -1 else 0
    }

    fun next() {
        index = if (index + 1 < steps.size) index + 1 else -1
    }

    fun stop() {
        index = -1
    }
}

@Composable
fun rememberPopTourState(): PopTourState = remember { PopTourState() }

/** Marks a real control the tour can spotlight. */
fun Modifier.popTourTarget(state: PopTourState, key: String): Modifier =
    onGloballyPositioned { state.bounds[key] = it.boundsInRoot() }

/**
 * Dims the screen under a 72% ink scrim with a rounded cut-out (radius 18,
 * yellow 3 outline) around the current target, and places the tour card on
 * the roomier side. Put it last in a full-screen Box.
 */
@Composable
fun PopTourOverlay(state: PopTourState, onFinished: (completed: Boolean) -> Unit = {}) {
    if (!state.isRunning) return
    val step = state.steps[state.index]
    val density = LocalDensity.current
    val pad = with(density) { 8.dp.toPx() }
    val hole = state.bounds[step.target]?.inflate(pad)
    Box(
        Modifier
            .fillMaxSize()
            .clickable(remember { MutableInteractionSource() }, indication = null) {},
    ) {
        Canvas(Modifier.fillMaxSize()) {
            val radius = CornerRadius(PopRadius.spotlight.toPx())
            if (hole != null) {
                val cut = Path().apply { addRoundRect(androidx.compose.ui.geometry.RoundRect(hole, radius)) }
                clipPath(cut, ClipOp.Difference) { drawRect(PopColors.scrim) }
                drawRoundRect(
                    PopColors.yellow, hole.topLeft, hole.size, radius,
                    style = Stroke(PopBorder.spotlight.toPx()),
                )
            } else {
                drawRect(PopColors.scrim)
            }
        }
        BoxWithConstraints(Modifier.fillMaxSize()) {
            val screenHeight = constraints.maxHeight.toFloat()
            // The card goes on the roomier side of the spotlight, 16 from it.
            val below = hole == null || hole.center.y < screenHeight / 2
            val topPad = with(density) { if (hole != null && below) hole.bottom.toDp() + PopSpace.lg else PopSpace.lg }
            val bottomPad = with(density) { if (hole != null && !below) (screenHeight - hole.top).toDp() + PopSpace.lg else PopSpace.lg }
            Box(
                Modifier
                    .fillMaxSize()
                    .padding(start = PopSpace.lg, end = PopSpace.lg, top = topPad, bottom = bottomPad),
                contentAlignment = if (below) Alignment.TopCenter else Alignment.BottomCenter,
            ) {
                PopTourCard(
                    step = state.index,
                    count = state.steps.size,
                    title = step.title,
                    body = step.body,
                    onNext = {
                        val last = state.index == state.steps.size - 1
                        state.next()
                        if (last) onFinished(true)
                    },
                    onSkip = {
                        state.stop()
                        onFinished(false)
                    },
                )
            }
        }
    }
}
