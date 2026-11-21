package dev.stickerpop.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * The bar at the top of a screen. Compact (the default) is for sub-screens:
 * a back sticker button when [onBack] is set, a one-line 22/800 title and up
 * to two [actions], 64 high. [large] is for main screens, at the top of the
 * scrolling content: the 34/800 screen title (up to two lines).
 *
 * When content scrolls under it ([scrolled], e.g. `scrollState.value > 0`),
 * it fills with paper and draws a 2.5 ink line along its bottom.
 */
@Composable
fun PopTopBar(
    title: String,
    modifier: Modifier = Modifier,
    onBack: (() -> Unit)? = null,
    backLabel: String = "Back",
    large: Boolean = false,
    scrolled: Boolean = false,
    statusBarPadding: Boolean = !large,
    actions: @Composable RowScope.() -> Unit = {},
) {
    val fill by animateColorAsState(if (scrolled) PopColors.paper else Color.Transparent, tween(PopMotion.fadeMillis), label = "bar fill")
    val line by animateColorAsState(if (scrolled) PopColors.ink else Color.Transparent, tween(PopMotion.fadeMillis), label = "bar line")
    Box(
        modifier
            .fillMaxWidth()
            .background(fill)
            .drawBehind {
                val y = size.height - PopBorder.regular.toPx() / 2
                drawLine(line, Offset(0f, y), Offset(size.width, y), PopBorder.regular.toPx())
            }
            .then(if (statusBarPadding) Modifier.statusBarsPadding() else Modifier)
            .heightIn(min = PopSize.topBar)
            .padding(horizontal = PopSpace.screen, vertical = if (large) PopSpace.sm else 0.dp)
            .padding(bottom = PopBorder.regular),
        contentAlignment = Alignment.CenterStart,
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
            if (onBack != null) {
                PopIconButton(Icons.AutoMirrored.Rounded.ArrowBack, backLabel, onClick = onBack)
                Spacer(Modifier.width(PopSpace.xs))
            }
            PopText(
                title,
                if (large) PopTextSpecs.screenTitle else PopTextSpecs.sheetTitle,
                Modifier.weight(1f).semantics { heading() },
                maxLines = if (large) 2 else 1,
            )
            Spacer(Modifier.width(PopSpace.xs))
            actions()
        }
    }
}
