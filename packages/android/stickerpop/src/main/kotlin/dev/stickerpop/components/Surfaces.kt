package dev.stickerpop.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/** The lilac empty-state card: one or two sentences saying what will appear here and how to start. */
@Composable
fun PopHintCard(
    message: String,
    modifier: Modifier = Modifier,
    title: String? = null,
    icon: ImageVector? = null,
    fill: Color = PopColors.lilac,
    action: (@Composable () -> Unit)? = null,
) {
    StickerInfoCard(modifier.fillMaxWidth(), fill = fill) {
        Row(horizontalArrangement = Arrangement.spacedBy(PopSpace.md)) {
            if (icon != null) PopIcon(icon, PopSize.iconNav)
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(PopSpace.xs)) {
                if (title != null) PopText(title, PopTextSpecs.rowTitle)
                PopText(message, PopTextSpecs.body)
                action?.invoke()
            }
        }
    }
}

/** A small caps section label such as "RECENT", usually with a trailing text button. */
@Composable
fun PopSectionLabel(text: String, modifier: Modifier = Modifier, trailing: (@Composable () -> Unit)? = null) {
    Row(modifier.fillMaxWidth().semantics { heading() }, verticalAlignment = Alignment.CenterVertically) {
        PopText(text, PopTextSpecs.sectionLabel, Modifier.weight(1f))
        trailing?.invoke()
    }
}
