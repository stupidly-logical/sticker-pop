package dev.stickerpop.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.ExpandMore
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * A card that opens to show more: a header row (16/800 title, optional
 * subtitle, a chevron that flips) and a body that slides open. For FAQs,
 * breakdowns and details that most people won't need.
 */
@Composable
fun PopExpandable(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    initiallyExpanded: Boolean = false,
    onExpandedChange: (Boolean) -> Unit = {},
    content: @Composable ColumnScope.() -> Unit,
) {
    var open by rememberSaveable { mutableStateOf(initiallyExpanded) }
    val turn by animateFloatAsState(if (open) 180f else 0f, tween(PopMotion.sheetMillis), label = "chevron")
    StickerCard(modifier.fillMaxWidth(), padding = PaddingValues()) {
        Row(
            Modifier
                .fillMaxWidth()
                .heightIn(min = PopSize.rowMin)
                .clickable(remember { MutableInteractionSource() }, indication = null, role = Role.Button) { open = !open; onExpandedChange(open) }
                .semantics { stateDescription = if (open) "Expanded" else "Collapsed" }
                .padding(start = PopSpace.lg, end = PopSpace.md, top = 10.dp, bottom = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(Modifier.weight(1f)) {
                PopText(title, PopTextSpecs.rowTitle)
                if (subtitle != null) PopText(subtitle, PopTextSpecs.caption)
            }
            PopIcon(Icons.Rounded.ExpandMore, 26.dp, Modifier.rotate(turn))
        }
        AnimatedVisibility(open, enter = expandVertically(tween(PopMotion.sheetMillis)), exit = shrinkVertically(tween(PopMotion.sheetMillis))) {
            Column {
                Spacer(Modifier.fillMaxWidth().height(PopBorder.divider).background(PopColors.divider))
                Column(Modifier.padding(PopSpace.lg), content = content)
            }
        }
    }
}
