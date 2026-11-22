package dev.stickerpop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.stickerpop.popTextStyle
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopTextSpec

private val avatarFills = listOf(PopColors.yellow, PopColors.pink, PopColors.blue, PopColors.mint, PopColors.lilac, PopColors.orange)

/** Up to two initials: the first letters of the first and last words. */
fun popInitials(name: String): String {
    val words = name.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
    if (words.isEmpty()) return "?"
    val last = if (words.size > 1) words.last().first().toString() else ""
    return (words.first().first().toString() + last).uppercase()
}

/** The bright a name always gets, the same on every platform: the sum of its UTF-16 code units, modulo six. */
fun popAvatarColor(name: String): Color = avatarFills[name.trim().sumOf { it.code } % avatarFills.size]

/**
 * A person, payee or shared account: their initials in a bright circle with
 * a 2 ink outline, coloured from the name. Sizes: 32, 42 (default), 56.
 */
@Composable
fun PopAvatar(name: String, modifier: Modifier = Modifier, size: Dp = 42.dp, color: Color? = null) {
    val fontSize = with(LocalDensity.current) { (size * 0.38f).toPx().toSp() }
    Box(
        modifier
            .size(size)
            .background(color ?: popAvatarColor(name), CircleShape)
            .border(PopBorder.thin, PopColors.ink, CircleShape)
            .clearAndSetSemantics { contentDescription = name; role = Role.Image },
        contentAlignment = Alignment.Center,
    ) {
        // Fixed size: initials don't grow with the system text size.
        BasicText(popInitials(name), style = popTextStyle(PopTextSpec(size = fontSize / LocalDensity.current.fontScale, weight = FontWeight(800))))
    }
}
