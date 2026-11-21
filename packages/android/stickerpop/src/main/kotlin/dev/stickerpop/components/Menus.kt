package dev.stickerpop.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.MutableTransitionState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.focusable
import androidx.compose.foundation.hoverable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.interaction.collectIsHoveredAsState
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.ExpandMore
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.input.key.key
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntRect
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupPositionProvider
import androidx.compose.ui.window.PopupProperties
import dev.stickerpop.sticker
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

// ---------------------------------------------------------------------------
// Select

/** One choice in a [PopSelect]. */
data class PopSelectOption<T>(val value: T, val label: String, val icon: ImageVector? = null, val caption: String? = null)

/**
 * A dropdown: a field (white, 2 ink outline, radius 14) showing the chosen
 * option and a chevron. Tapping it opens a bottom sheet listing the options;
 * the chosen row is yellow with a tick. For two to five short options a
 * [PopSegmented] or chips are usually better.
 */
@Composable
fun <T> PopSelect(
    options: List<PopSelectOption<T>>,
    value: T?,
    onValueChange: (T) -> Unit,
    modifier: Modifier = Modifier,
    label: String? = null,
    hint: String = "Choose",
    sheetTitle: String? = null,
    error: String? = null,
    enabled: Boolean = true,
) {
    var open by remember { mutableStateOf(false) }
    val selected = options.firstOrNull { it.value == value }
    val source = remember { MutableInteractionSource() }
    val focused by source.collectIsFocusedAsState()
    val tint = if (enabled) PopColors.ink else PopColors.inkMuted
    Column(modifier, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        if (label != null) PopText(label, PopTextSpecs.fieldLabel)
        val shape = RoundedCornerShape(PopRadius.field)
        Row(
            Modifier
                .fillMaxWidth()
                .heightIn(min = PopSize.tapTarget)
                .sticker(if (enabled) PopColors.white else PopColors.paper, shape, PopRadius.field,
                    border = if (error != null || open || focused) PopBorder.regular else PopBorder.thin, shadow = 0.dp)
                .clip(shape)
                .clickable(source, indication = null, enabled = enabled, role = Role.DropdownList) { open = true }
                .semantics {
                    contentDescription = label ?: hint
                    stateDescription = selected?.label ?: hint
                }
                .padding(horizontal = PopSpace.md, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(PopSpace.sm),
        ) {
            selected?.icon?.let { PopIcon(it, PopSize.iconNav, tint = tint) }
            Box(Modifier.weight(1f)) {
                if (selected == null) PopText(hint, PopTextSpecs.inputHint, maxLines = 1)
                else PopText(selected.label, PopTextSpecs.input, color = tint, maxLines = 1)
            }
            PopIcon(Icons.Rounded.ExpandMore, PopSize.iconNav, tint = tint)
        }
        if (error != null) PopFormError(error)
    }
    if (open) {
        PopSelectSheet(
            title = sheetTitle ?: label ?: hint,
            options = options,
            selected = value,
            onPick = { open = false; onValueChange(it.value) },
            onDismiss = { open = false },
        )
    }
}

/** The [PopSelect] sheet on its own: a titled bottom sheet with the options in a sticker list. */
@Composable
fun <T> PopSelectSheet(
    title: String,
    options: List<PopSelectOption<T>>,
    selected: T?,
    onPick: (PopSelectOption<T>) -> Unit,
    onDismiss: () -> Unit,
) {
    PopBottomSheet(onDismiss = onDismiss) {
        PopSheet(title) {
            StickerList(rows = options.map { o ->
                @Composable {
                    PopOptionRow(o.label, onClick = { onPick(o) }, caption = o.caption, icon = o.icon, selected = o.value == selected)
                }
            })
        }
    }
}

/** A select-list row: optional icon, a 16 label (800 when chosen), optional caption, and a tick. The chosen row fills yellow to the edges. */
@Composable
fun PopOptionRow(label: String, onClick: () -> Unit, modifier: Modifier = Modifier, caption: String? = null, icon: ImageVector? = null, selected: Boolean = false) {
    Row(
        modifier
            .fillMaxWidth()
            .heightIn(min = PopSize.rowMin)
            .background(if (selected) PopColors.yellow else PopColors.white)
            .clickable(remember { MutableInteractionSource() }, indication = null, role = Role.Button, onClick = onClick)
            .semantics { this.selected = selected }
            .padding(horizontal = PopSpace.lg, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(PopSpace.md),
    ) {
        icon?.let { PopIcon(it, PopSize.iconNav) }
        Column(Modifier.weight(1f)) {
            PopText(label, if (selected) PopTextSpecs.rowTitle else PopTextSpecs.input)
            if (caption != null) PopText(caption, PopTextSpecs.caption)
        }
        if (selected) PopIcon(Icons.Rounded.Check, PopSize.iconNav)
    }
}

// ---------------------------------------------------------------------------
// Menu

/** An entry in a [PopMenu]. */
sealed interface PopMenuEntry

/** One action. [destructive] actions (Delete) are 800 and go last after a divider; they stay ink, never red. */
data class PopMenuItem(
    val label: String,
    val icon: ImageVector? = null,
    val destructive: Boolean = false,
    val enabled: Boolean = true,
    val onClick: () -> Unit,
) : PopMenuEntry

/** A 2 divider line between groups. */
data object PopMenuDivider : PopMenuEntry

/**
 * A small popover of actions anchored to [trigger] (usually a [PopIconButton]
 * with a "more" icon). A white sticker, radius 16, 4/4 shadow; rows are 48
 * high and turn yellow when hovered, focused or pressed. It opens below the
 * trigger, lined up with its trailing edge, and flips above when there is no
 * room. Back, a tap outside or picking an item closes it.
 */
@Composable
fun PopMenu(
    items: List<PopMenuEntry>,
    modifier: Modifier = Modifier,
    trigger: @Composable (toggle: () -> Unit, isOpen: Boolean) -> Unit,
) {
    var open by remember { mutableStateOf(false) }
    val visible = remember { MutableTransitionState(false) }
    visible.targetState = open
    Box(modifier) {
        trigger({ open = !open }, open)
        if (visible.currentState || visible.targetState) {
            val edge = with(LocalDensity.current) { PopSpace.sm.roundToPx() }
            Popup(
                popupPositionProvider = remember(edge) { PopMenuPosition(edge) },
                onDismissRequest = { open = false },
                properties = PopupProperties(focusable = true),
            ) {
                AnimatedVisibility(
                    visible,
                    enter = fadeIn(tween(PopMotion.fadeMillis)) + scaleIn(tween(PopMotion.fadeMillis), initialScale = 0.96f, transformOrigin = TransformOrigin(1f, 0f)),
                    exit = fadeOut(tween(PopMotion.fadeMillis)) + scaleOut(tween(PopMotion.fadeMillis), targetScale = 0.96f, transformOrigin = TransformOrigin(1f, 0f)),
                ) {
                    PopMenuPanel(items, onClose = { open = false })
                }
            }
        }
    }
}

/** Below the anchor, trailing edges lined up; above when there's no room; 8 from the window edges. */
private class PopMenuPosition(private val edge: Int) : PopupPositionProvider {
    override fun calculatePosition(anchorBounds: IntRect, windowSize: IntSize, layoutDirection: LayoutDirection, popupContentSize: IntSize): IntOffset {
        val maxX = (windowSize.width - popupContentSize.width - edge).coerceAtLeast(edge)
        val x = if (layoutDirection == LayoutDirection.Ltr) anchorBounds.right - popupContentSize.width else anchorBounds.left
        val below = anchorBounds.bottom + edge
        val y = if (below + popupContentSize.height <= windowSize.height - edge) below
        else (anchorBounds.top - edge - popupContentSize.height).coerceAtLeast(edge)
        return IntOffset(x.coerceIn(edge, maxX), y)
    }
}

/** The menu's sticker panel on its own. */
@Composable
fun PopMenuPanel(items: List<PopMenuEntry>, onClose: () -> Unit, modifier: Modifier = Modifier) {
    val shape = RoundedCornerShape(PopRadius.menu)
    val first = remember { FocusRequester() }
    val firstEnabled = items.indexOfFirst { it is PopMenuItem && it.enabled }
    Column(
        modifier
            .padding(end = PopShadow.regular, bottom = PopShadow.regular) // room for the hard shadow
            .widthIn(min = PopSize.menuMinWidth, max = PopSize.menuMaxWidth)
            .width(IntrinsicSize.Max)
            .heightIn(max = PopSize.menuMaxHeight)
            .sticker(PopColors.white, shape, PopRadius.menu)
            .clip(shape)
            .verticalScroll(rememberScrollState())
            .padding(vertical = 6.dp)
            .onKeyEvent { if (it.key == Key.Escape) { onClose(); true } else false },
    ) {
        items.forEachIndexed { i, entry ->
            when (entry) {
                PopMenuDivider -> Spacer(Modifier.padding(vertical = 6.dp).fillMaxWidth().height(PopBorder.divider).background(PopColors.divider))
                is PopMenuItem -> PopMenuRow(entry, onClose, if (i == firstEnabled) Modifier.focusRequester(first) else Modifier)
            }
        }
    }
    LaunchedEffect(Unit) { runCatching { first.requestFocus() } }
}

@Composable
private fun PopMenuRow(item: PopMenuItem, onClose: () -> Unit, modifier: Modifier) {
    val source = remember { MutableInteractionSource() }
    val hovered by source.collectIsHoveredAsState()
    val focused by source.collectIsFocusedAsState()
    val pressed by source.collectIsPressedAsState()
    val lit = item.enabled && (hovered || focused || pressed)
    val tint = if (item.enabled) PopColors.ink else PopColors.inkMuted
    Row(
        modifier
            .fillMaxWidth()
            .heightIn(min = PopSize.tapTarget)
            .background(if (lit) PopColors.yellow else PopColors.white)
            .hoverable(source, enabled = item.enabled)
            .focusable(item.enabled, source)
            .clickable(source, indication = null, enabled = item.enabled, role = Role.Button) { onClose(); item.onClick() }
            .padding(horizontal = PopSpace.lg, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(PopSpace.md),
    ) {
        item.icon?.let { PopIcon(it, PopSize.iconNav, tint = tint) }
        PopText(item.label, if (item.destructive) PopTextSpecs.tileLabel else PopTextSpecs.menuItem, color = tint)
    }
}
