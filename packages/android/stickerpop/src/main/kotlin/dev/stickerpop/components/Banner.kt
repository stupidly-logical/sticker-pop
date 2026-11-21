package dev.stickerpop.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.CheckCircleOutline
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.WarningAmber
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/** What a [PopBanner] is about; sets its fill and default icon. */
enum class PopBannerTone { Info, Warning, Success }

/**
 * A message that stays in the page until it's dealt with: a bright sticker
 * card (info blue, warning orange, success mint) with an icon, an optional
 * 16/800 title, a 15/600 message, an optional text-button action and an
 * optional close button. Never red.
 */
@Composable
fun PopBanner(
    message: String,
    modifier: Modifier = Modifier,
    title: String? = null,
    tone: PopBannerTone = PopBannerTone.Info,
    icon: ImageVector? = null,
    actionLabel: String? = null,
    onAction: () -> Unit = {},
    onDismiss: (() -> Unit)? = null,
) {
    val fill = when (tone) { PopBannerTone.Info -> PopColors.blue; PopBannerTone.Warning -> PopColors.orange; PopBannerTone.Success -> PopColors.mint }
    val glyph = icon ?: when (tone) { PopBannerTone.Info -> Icons.Rounded.Info; PopBannerTone.Warning -> Icons.Rounded.WarningAmber; PopBannerTone.Success -> Icons.Rounded.CheckCircleOutline }
    StickerCard(
        modifier.fillMaxWidth().semantics { liveRegion = LiveRegionMode.Polite },
        fill = fill,
        padding = PaddingValues(start = PopSpace.lg, top = PopSpace.md, end = PopSpace.sm, bottom = PopSpace.md),
    ) {
        Row(verticalAlignment = Alignment.Top) {
            PopIcon(glyph, PopSize.iconNav, Modifier.padding(top = 2.dp))
            Spacer(Modifier.width(PopSpace.md))
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                if (title != null) PopText(title, PopTextSpecs.rowTitle)
                PopText(message, PopTextSpecs.body)
                if (actionLabel != null) PopTextButton(actionLabel, onAction, underline = true)
            }
            if (onDismiss != null) {
                Box(
                    Modifier.size(40.dp)
                        .clickable(remember { MutableInteractionSource() }, indication = null, role = Role.Button, onClick = onDismiss)
                        .semantics { contentDescription = "Dismiss" },
                    contentAlignment = Alignment.Center,
                ) { PopIcon(Icons.Rounded.Close, 20.dp) }
            } else {
                Spacer(Modifier.width(PopSpace.sm))
            }
        }
    }
}
