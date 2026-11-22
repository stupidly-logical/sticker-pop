package dev.stickerpop.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * A whole-screen state for when there's nothing to show yet, or something
 * went wrong: a 96 sticker tile with a 44 icon, tilted −4°, then a 22/800
 * title, a short 15/600 message and up to two actions, all centred. Lilac
 * for empty (the default), orange for errors and offline.
 */
@Composable
fun PopEmptyState(
    icon: ImageVector,
    title: String,
    message: String,
    modifier: Modifier = Modifier,
    fill: Color = PopColors.lilac,
    actionLabel: String? = null,
    onAction: () -> Unit = {},
    secondaryLabel: String? = null,
    onSecondary: () -> Unit = {},
) {
    Box(modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
        Column(Modifier.widthIn(max = 340.dp).padding(PopSpace.xl), horizontalAlignment = Alignment.CenterHorizontally) {
            StickerCard(Modifier.size(PopSize.stateTile).clearAndSetSemantics {}, fill = fill, shadow = PopShadow.large, tilt = -4f, padding = PaddingValues()) {
                Box(Modifier.size(PopSize.stateTile), contentAlignment = Alignment.Center) { PopIcon(icon, 44.dp) }
            }
            Spacer(Modifier.height(PopSpace.xxl))
            PopText(title, PopTextSpecs.sheetTitle, Modifier.semantics { heading() }, align = TextAlign.Center)
            Spacer(Modifier.height(PopSpace.sm))
            PopText(message, PopTextSpecs.body, color = PopColors.inkMuted, align = TextAlign.Center)
            if (actionLabel != null) {
                Spacer(Modifier.height(PopSpace.xl))
                StickerButton(actionLabel, onAction)
            }
            if (secondaryLabel != null) {
                Spacer(Modifier.height(PopSpace.sm))
                PopTextButton(secondaryLabel, onSecondary)
            }
        }
    }
}
