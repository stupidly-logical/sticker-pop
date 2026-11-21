package dev.stickerpop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.ChevronRight
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import dev.stickerpop.popTextStyle
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

private val amountPattern = Regex("^\\d*\\.?\\d{0,2}$")

/**
 * The big amount entry: a bright card with a currency prefix at the same
 * 32/800 size. Choose [fill] by meaning (e.g. yellow for money out, mint for
 * money in). Only digits and up to two decimals are accepted.
 */
@Composable
fun PopAmountField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    fill: Color = PopColors.yellow,
    label: String = "Amount",
    currencySymbol: String = "₹",
    error: String? = null,
) {
    val style = popTextStyle(PopTextSpecs.amountEntry)
    Column(modifier, verticalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
        StickerCard(
            Modifier.fillMaxWidth(),
            fill = fill,
            padding = PaddingValues(start = PopSpace.lg, end = PopSpace.lg, top = PopSpace.md, bottom = PopSpace.sm),
        ) {
            PopText(label, PopTextSpecs.sectionLabel)
            Row(verticalAlignment = Alignment.CenterVertically) {
                PopText(currencySymbol, PopTextSpecs.amountEntry)
                Spacer(Modifier.width(PopSpace.xs))
                Box(Modifier.weight(1f), contentAlignment = Alignment.CenterStart) {
                    if (value.isEmpty()) PopText("0", PopTextSpecs.amountEntry, color = PopColors.inkMuted)
                    BasicTextField(
                        value = value,
                        onValueChange = { if (amountPattern.matches(it)) onValueChange(it) },
                        textStyle = style,
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        cursorBrush = SolidColor(PopColors.ink),
                        modifier = Modifier.fillMaxWidth().padding(vertical = 6.dp),
                    )
                }
            }
        }
        if (error != null) PopFormError(error)
    }
}

/**
 * One labelled line inside a details card: a 76-wide muted label column,
 * the value on the right, min height 52 and a 2px divider under each row.
 */
@Composable
fun PopFieldRow(
    label: String,
    modifier: Modifier = Modifier,
    showChevron: Boolean = false,
    divider: Boolean = true,
    onClick: (() -> Unit)? = null,
    content: @Composable () -> Unit,
) {
    Column(modifier.fillMaxWidth()) {
        Row(
            Modifier
                .fillMaxWidth()
                .heightIn(min = PopSize.rowMin)
                .then(if (onClick != null) Modifier.clickable(role = Role.Button, onClick = onClick) else Modifier)
                .padding(horizontal = 14.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            PopText(label, PopTextSpecs.fieldLabel, Modifier.width(PopSize.fieldLabelColumn))
            Box(Modifier.weight(1f)) { content() }
            if (showChevron) PopIcon(Icons.Rounded.ChevronRight, PopSize.iconNav)
        }
        if (divider) Spacer(Modifier.fillMaxWidth().height(PopBorder.divider).background(PopColors.divider))
    }
}
