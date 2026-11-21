package dev.stickerpop.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * A row of tabs for switching between views of one screen. Unselected tabs
 * are plain 15/700 muted text; the selected one sits in a yellow pill with a
 * 2 ink outline and 800 text. Scrolls sideways when the tabs don't fit.
 */
@Composable
fun PopTabs(tabs: List<String>, selected: Int, onSelect: (Int) -> Unit, modifier: Modifier = Modifier) {
    Row(modifier.horizontalScroll(rememberScrollState()).selectableGroup(), horizontalArrangement = Arrangement.spacedBy(PopSpace.xs)) {
        tabs.forEachIndexed { i, t ->
            val on = i == selected
            val fill by animateColorAsState(if (on) PopColors.yellow else Color.Transparent, tween(PopMotion.toggleMillis), label = "tab")
            val shape = RoundedCornerShape(PopRadius.pill)
            Box(
                Modifier
                    .heightIn(min = PopSize.chip)
                    .widthIn(min = PopSize.tapTarget)
                    .background(fill, shape)
                    .border(PopBorder.thin, if (on) PopColors.ink else Color.Transparent, shape)
                    .selectable(on, remember { MutableInteractionSource() }, indication = null, role = Role.Tab) { onSelect(i) }
                    .padding(horizontal = PopSpace.lg),
                contentAlignment = Alignment.Center,
            ) {
                PopText(t, if (on) PopTextSpecs.segmentSelected else PopTextSpecs.segment, color = if (on) PopColors.ink else PopColors.inkMuted, maxLines = 1)
            }
        }
    }
}
