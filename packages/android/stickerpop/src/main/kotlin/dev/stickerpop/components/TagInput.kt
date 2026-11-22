package dev.stickerpop.components

import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.key
import androidx.compose.ui.input.key.onPreviewKeyEvent
import androidx.compose.ui.input.key.type
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
 * Tags typed into a field: removable chips inside a text-field box, then an
 * inline text field. Done or a comma adds what was typed; backspace in an
 * empty field removes the last tag. Duplicates (ignoring case) are skipped.
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun PopTagInput(tags: List<String>, onTagsChange: (List<String>) -> Unit, modifier: Modifier = Modifier, hint: String = "Add a tag", label: String? = null) {
    var text by remember { mutableStateOf("") }
    val source = remember { MutableInteractionSource() }
    val focused by source.collectIsFocusedAsState()
    fun add(raw: String) {
        val t = raw.replace(",", "").trim()
        text = ""
        if (t.isNotEmpty() && tags.none { it.equals(t, ignoreCase = true) }) onTagsChange(tags + t)
    }
    Column(modifier, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        if (label != null) PopText(label, PopTextSpecs.fieldLabel)
        FlowRow(
            Modifier
                .fillMaxWidth()
                .heightIn(min = PopSize.tapTarget)
                .sticker(PopColors.white, RoundedCornerShape(PopRadius.field), PopRadius.field, border = if (focused) PopBorder.regular else PopBorder.thin, shadow = 0.dp)
                .padding(horizontal = PopSpace.sm, vertical = 6.dp),
            horizontalArrangement = Arrangement.spacedBy(PopSpace.sm),
            verticalArrangement = Arrangement.spacedBy(PopSpace.sm),
        ) {
            tags.forEach { t -> PopChip(t, false, {}, onRemove = { onTagsChange(tags - t) }) }
            BasicTextField(
                text,
                { v -> if (',' in v) add(v) else text = v },
                Modifier
                    .widthIn(min = 120.dp)
                    .align(Alignment.CenterVertically)
                    .padding(horizontal = 4.dp, vertical = 8.dp)
                    .onPreviewKeyEvent {
                        if (it.type == KeyEventType.KeyDown && it.key == Key.Backspace && text.isEmpty() && tags.isNotEmpty()) {
                            onTagsChange(tags.dropLast(1)); true
                        } else false
                    },
                textStyle = popTextStyle(PopTextSpecs.input),
                cursorBrush = SolidColor(PopColors.ink),
                singleLine = true,
                interactionSource = source,
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
                keyboardActions = KeyboardActions(onDone = { add(text) }),
                decorationBox = { inner -> if (text.isEmpty() && tags.isEmpty()) PopText(hint, PopTextSpecs.inputHint); inner() },
            )
        }
    }
}
