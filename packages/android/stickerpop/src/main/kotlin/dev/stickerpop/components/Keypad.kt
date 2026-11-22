package dev.stickerpop.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.Backspace
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.Role
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * Applies one keypad key ("0"–"9", "." or "⌫") to an amount being typed:
 * one decimal point, at most [decimals] decimal places, no leading zeros, at
 * most [maxDigits] digits before the point.
 */
fun applyPopKey(current: String, key: String, decimals: Int = 2, maxDigits: Int = 9): String {
    if (key == "⌫") return current.dropLast(1)
    if (key == ".") return if (decimals == 0 || '.' in current) current else if (current.isEmpty()) "0." else "$current."
    if (key.length != 1 || !key[0].isDigit()) return current
    val dot = current.indexOf('.')
    if (dot >= 0 && current.length - dot - 1 >= decimals) return current
    if (dot < 0 && current.removePrefix("0").length >= maxDigits) return current
    if (current == "0") return key
    return current + key
}

/**
 * A number keypad for entering amounts, in place of the system keyboard: a
 * 3 × 4 grid of white sticker keys (1–9, ".", 0, backspace) with 26/800
 * digits, 56 high, 3/3 shadow. Combine with [applyPopKey].
 */
@Composable
fun PopKeypad(onKey: (String) -> Unit, modifier: Modifier = Modifier, decimal: Boolean = true) {
    val haptics = LocalHapticFeedback.current
    val rows = listOf(listOf("1", "2", "3"), listOf("4", "5", "6"), listOf("7", "8", "9"), listOf(".", "0", "⌫"))
    Column(modifier.fillMaxWidth().padding(end = PopShadow.small, bottom = PopShadow.small), verticalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
        rows.forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(PopSpace.sm)) {
                row.forEach { k ->
                    Box(Modifier.weight(1f).height(PopSize.keypadKey)) {
                        if (k != "." || decimal) {
                            val label = when (k) { "⌫" -> "Delete"; "." -> "Decimal point"; else -> k }
                            StickerCard(
                                Modifier.fillMaxWidth().height(PopSize.keypadKey).clearAndSetSemantics {
                                    contentDescription = label; role = Role.Button
                                    onClick { onKey(k); true }
                                },
                                radius = PopRadius.tile, shadow = PopShadow.small, padding = PaddingValues(),
                                onClick = { haptics.performHapticFeedback(HapticFeedbackType.TextHandleMove); onKey(k) },
                            ) {
                                Box(Modifier.fillMaxWidth().height(PopSize.keypadKey), contentAlignment = Alignment.Center) {
                                    if (k == "⌫") PopIcon(Icons.AutoMirrored.Rounded.Backspace, PopSize.iconTile, tint = PopColors.ink)
                                    else PopText(k, PopTextSpecs.keypadKey)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
