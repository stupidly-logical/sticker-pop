package dev.stickerpop.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowRight
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

private val PageSize = 40.dp
private val PageGap = PopSpace.xs

/**
 * The page slots to show for [page] of [count] (both from 1): every page
 * when there are 7 or fewer, otherwise always 7 slots with null for "…",
 * e.g. 1 … 4 5 6 … 12. The same rule runs on every platform.
 */
fun popPageItems(page: Int, count: Int): List<Int?> = when {
    count <= 7 -> (1..count).toList()
    page <= 4 -> listOf(1, 2, 3, 4, 5, null, count)
    page >= count - 3 -> listOf(1, null) + (count - 4..count).toList()
    else -> listOf(1, null, page - 1, page, page + 1, null, count)
}

/**
 * Moves through pages of a long list: previous and next sticker icon
 * buttons around the page numbers (40, radius 12; the current page is
 * yellow with a 2.5 outline). Where the full row doesn't fit (under 404, so
 * on most phones) it shows "Page 3 of 12" between the arrows instead.
 */
@Composable
fun PopPagination(page: Int, count: Int, onChange: (Int) -> Unit, modifier: Modifier = Modifier) {
    val scale = LocalDensity.current.fontScale
    BoxWithConstraints(modifier.fillMaxWidth()) {
        val wide = maxWidth >= PopSize.iconButton * 2 + PageSize * 7 + PageGap * 8 && scale <= 1.3f
        Row(
            if (wide) Modifier else Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(PageGap),
        ) {
            PopIconButton(Icons.AutoMirrored.Rounded.KeyboardArrowLeft, "Previous page", { onChange(page - 1) }, enabled = page > 1)
            if (wide) {
                popPageItems(page, count).forEach { p ->
                    if (p == null) {
                        Box(Modifier.width(PageSize).clearAndSetSemantics {}, contentAlignment = Alignment.Center) { PopText("…", PopTextSpecs.segment) }
                    } else {
                        PageButton(p, count, p == page) { onChange(p) }
                    }
                }
            } else {
                PopText("Page $page of $count", PopTextSpecs.rowTitle, Modifier.weight(1f).semantics { liveRegion = LiveRegionMode.Polite }, align = TextAlign.Center)
            }
            PopIconButton(Icons.AutoMirrored.Rounded.KeyboardArrowRight, "Next page", { onChange(page + 1) }, enabled = page < count)
        }
    }
}

@Composable
private fun PageButton(page: Int, count: Int, current: Boolean, onClick: () -> Unit) {
    val shape = RoundedCornerShape(12.dp)
    val fill by animateColorAsState(if (current) PopColors.yellow else Color.Transparent, tween(PopMotion.toggleMillis), label = "page")
    Box(
        Modifier
            .size(PageSize)
            .background(fill, shape)
            .then(if (current) Modifier.border(PopBorder.regular, PopColors.ink, shape) else Modifier)
            .clickable(remember { MutableInteractionSource() }, indication = null, enabled = !current, onClick = onClick)
            .clearAndSetSemantics { contentDescription = "Page $page of $count"; role = Role.Button; selected = current },
        contentAlignment = Alignment.Center,
    ) {
        PopText("$page", if (current) PopTextSpecs.segmentSelected else PopTextSpecs.segment, maxLines = 1)
    }
}
