package dev.stickerpop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntRect
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupPositionProvider
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpec
import kotlinx.coroutines.delay

/**
 * A short explanation in an ink bubble (white 13/700 text, radius 10) above
 * [content], shown on a tap ([tapToShow]) or long-press, hidden after 3 s.
 * Wrap something that isn't itself a button, usually a 22 ⓘ icon in a 48
 * square. Screen readers read [message] with the content.
 */
@Composable
fun PopTooltip(message: String, modifier: Modifier = Modifier, tapToShow: Boolean = true, content: @Composable () -> Unit) {
    var shown by remember { mutableStateOf(false) }
    val gap = with(LocalDensity.current) { PopSpace.sm.roundToPx() }
    Box(
        modifier
            .semantics { contentDescription = message }
            .pointerInput(tapToShow) { detectTapGestures(onTap = { if (tapToShow) shown = true }, onLongPress = { shown = true }) },
    ) {
        content()
        if (shown) {
            LaunchedEffect(Unit) { delay(PopMotion.snackbarMillis.toLong()); shown = false }
            Popup(popupPositionProvider = remember(gap) { AboveProvider(gap) }, onDismissRequest = { shown = false }) {
                Box(
                    Modifier
                        .widthIn(max = 280.dp)
                        .background(PopColors.ink, RoundedCornerShape(PopRadius.badge))
                        .padding(horizontal = PopSpace.md, vertical = PopSpace.sm),
                ) { PopText(message, PopTextSpec(size = 13.sp, weight = FontWeight(700), color = PopColors.white)) }
            }
        }
    }
}

/** Centred above the anchor (below it if there's no room), kept inside the window. */
private class AboveProvider(private val gap: Int) : PopupPositionProvider {
    override fun calculatePosition(anchorBounds: IntRect, windowSize: IntSize, layoutDirection: LayoutDirection, popupContentSize: IntSize): IntOffset {
        val x = (anchorBounds.center.x - popupContentSize.width / 2).coerceIn(gap, (windowSize.width - popupContentSize.width - gap).coerceAtLeast(gap))
        val above = anchorBounds.top - gap - popupContentSize.height
        return IntOffset(x, if (above >= gap) above else anchorBounds.bottom + gap)
    }
}
