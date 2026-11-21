package dev.stickerpop.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Cancel
import androidx.compose.material.icons.rounded.Search
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import dev.stickerpop.popTextStyle
import dev.stickerpop.sticker
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * A search box: a text field (white, 2 ink outline, radius 14, 48 high) with
 * a search icon, a ✕ that clears it while it has text, and an optional
 * "Cancel" text button after it ([onCancel]).
 */
@Composable
fun PopSearchField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    hint: String = "Search",
    onSearch: (String) -> Unit = {},
    onCancel: (() -> Unit)? = null,
    cancelLabel: String = "Cancel",
) {
    val source = remember { MutableInteractionSource() }
    val focused by source.collectIsFocusedAsState()
    val shape = RoundedCornerShape(PopRadius.field)
    Row(modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(PopSpace.md)) {
        Row(
            Modifier
                .weight(1f)
                .heightIn(min = PopSize.tapTarget)
                .sticker(PopColors.white, shape, PopRadius.field, border = if (focused) PopBorder.regular else PopBorder.thin, shadow = 0.dp)
                .padding(start = PopSpace.md, end = PopSpace.xs),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(PopSpace.sm),
        ) {
            PopIcon(Icons.Rounded.Search, PopSize.iconNav)
            Box(Modifier.weight(1f)) {
                if (value.isEmpty()) PopText(hint, PopTextSpecs.inputHint, maxLines = 1)
                BasicTextField(
                    value, onValueChange,
                    textStyle = popTextStyle(PopTextSpecs.input),
                    cursorBrush = SolidColor(PopColors.ink),
                    singleLine = true,
                    interactionSource = source,
                    keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                    keyboardActions = KeyboardActions(onSearch = { onSearch(value) }),
                    modifier = Modifier.fillMaxWidth(),
                )
            }
            if (value.isNotEmpty()) {
                Box(
                    Modifier
                        .size(40.dp)
                        .clickable(remember { MutableInteractionSource() }, indication = null, role = Role.Button) { onValueChange("") }
                        .semantics { contentDescription = "Clear search" },
                    contentAlignment = Alignment.Center,
                ) { PopIcon(Icons.Rounded.Cancel, 20.dp) }
            }
        }
        if (onCancel != null) PopTextButton(cancelLabel, onCancel)
    }
}
