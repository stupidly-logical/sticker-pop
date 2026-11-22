package dev.stickerpop.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.selection.toggleable
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowRight
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * A row for settings lists, inside a [StickerList]: an optional 22 icon, a
 * 16/700 title with an optional subtitle, and on the right either a switch
 * ([checked] + [onCheckedChange]) or an optional muted [value] and a chevron
 * when it opens something ([onClick]). The whole row is the tap target.
 */
@Composable
fun PopSettingsRow(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    icon: ImageVector? = null,
    value: String? = null,
    onClick: (() -> Unit)? = null,
    checked: Boolean? = null,
    onCheckedChange: ((Boolean) -> Unit)? = null,
) {
    val source = remember { MutableInteractionSource() }
    val interactive = when {
        checked != null && onCheckedChange != null -> Modifier.toggleable(checked, source, indication = null, role = Role.Switch) { onCheckedChange(it) }
        checked == null && onClick != null -> Modifier.clickable(source, indication = null, role = Role.Button, onClick = onClick)
        else -> Modifier
    }
    Row(
        modifier
            .fillMaxWidth()
            .heightIn(min = PopSize.rowMin)
            .then(interactive)
            .padding(start = PopSpace.lg, end = if (checked != null) PopSpace.md else PopSpace.sm, top = 8.dp, bottom = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(PopSpace.md),
    ) {
        icon?.let { PopIcon(it, PopSize.iconNav) }
        Column(Modifier.weight(1f)) {
            PopText(title, PopTextSpecs.input)
            if (subtitle != null) PopText(subtitle, PopTextSpecs.caption)
        }
        if (checked != null) {
            Row(Modifier.clearAndSetSemantics {}) { PopSwitch(checked, { onCheckedChange?.invoke(it) }, title, enabled = onCheckedChange != null) }
        } else {
            if (value != null) PopText(value, PopTextSpecs.input, color = PopColors.inkMuted, maxLines = 1, modifier = Modifier.widthIn(max = 160.dp))
            if (onClick != null) PopIcon(Icons.AutoMirrored.Rounded.KeyboardArrowRight, 26.dp) else Spacer(Modifier.width(PopSpace.xs))
        }
    }
}
