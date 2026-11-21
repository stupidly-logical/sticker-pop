package dev.stickerpop.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.MutableTransitionState
import androidx.compose.animation.core.tween
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import dev.stickerpop.sticker
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopMotion
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs
import kotlinx.coroutines.delay

/**
 * The body of a bottom sheet: paper fill, a 2.5 ink line on top, top radius
 * 24. Title, content, then the inline [error] and the primary button last.
 */
@Composable
fun PopSheet(
    title: String,
    modifier: Modifier = Modifier,
    primaryLabel: String? = null,
    onPrimary: () -> Unit = {},
    primaryEnabled: Boolean = true,
    error: String? = null,
    trailing: (@Composable () -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit,
) {
    val shape = RoundedCornerShape(topStart = PopRadius.sheet, topEnd = PopRadius.sheet)
    Column(
        modifier
            .fillMaxWidth()
            .clip(shape)
            .background(PopColors.paper)
            .drawBehind {
                drawLine(PopColors.ink, Offset(0f, 0f), Offset(size.width, 0f), PopBorder.regular.toPx())
            }
            .navigationBarsPadding()
            .imePadding()
            .padding(start = PopSpace.xl, end = PopSpace.xl, top = PopSpace.xl, bottom = PopSpace.xxl),
        verticalArrangement = Arrangement.spacedBy(PopSpace.lg),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            PopText(title, PopTextSpecs.sheetTitle, Modifier.weight(1f).semantics { heading() })
            trailing?.invoke()
        }
        Column(
            Modifier.weight(1f, fill = false).verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(PopSpace.lg),
            content = content,
        )
        if (error != null) PopFormError(error)
        if (primaryLabel != null) StickerButton(primaryLabel, onPrimary, enabled = primaryEnabled)
    }
}

/** Shows [content] (usually a [PopSheet]) as a modal bottom sheet, up to 90% of the screen high. */
@Composable
fun PopBottomSheet(onDismiss: () -> Unit, content: @Composable () -> Unit) {
    val maxHeight = LocalConfiguration.current.screenHeightDp.dp * PopSize.sheetMaxHeightFraction
    val visible = remember { MutableTransitionState(false).apply { targetState = true } }
    Dialog(onDismissRequest = onDismiss, properties = DialogProperties(usePlatformDefaultWidth = false, decorFitsSystemWindows = false)) {
        Box(
            Modifier
                .fillMaxSize()
                .clickable(remember { MutableInteractionSource() }, indication = null, onClick = onDismiss),
            contentAlignment = Alignment.BottomCenter,
        ) {
            AnimatedVisibility(visible, enter = slideInVertically(tween(PopMotion.sheetMillis)) { it }) {
                Box(
                    Modifier
                        .heightIn(max = maxHeight)
                        .clickable(remember { MutableInteractionSource() }, indication = null) {},
                ) { content() }
            }
        }
    }
}

/**
 * A dialog: a paper sticker with the large 6/6 shadow, 20 in from the screen
 * edges. Title, body, the primary button, then a "Cancel" text button.
 */
@Composable
fun PopDialog(
    title: String,
    body: String,
    primaryLabel: String,
    onPrimary: () -> Unit,
    onDismiss: () -> Unit,
    cancelLabel: String = "Cancel",
) {
    Dialog(onDismissRequest = onDismiss, properties = DialogProperties(usePlatformDefaultWidth = false)) {
        Column(
            Modifier
                .padding(PopSpace.xl)
                .fillMaxWidth()
                .sticker(PopColors.paper, RoundedCornerShape(PopRadius.card), PopRadius.card, shadow = PopShadow.large)
                .verticalScroll(rememberScrollState())
                .padding(PopSpace.xl),
            verticalArrangement = Arrangement.spacedBy(PopSpace.sm),
        ) {
            PopText(title, PopTextSpecs.sheetTitle, Modifier.semantics { heading() })
            PopText(body, PopTextSpecs.body)
            Spacer(Modifier.height(PopSpace.md))
            StickerButton(primaryLabel, onPrimary)
            Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                PopTextButton(cancelLabel, onDismiss)
            }
        }
    }
}

/** One snackbar message. */
data class PopSnack(val message: String, val actionLabel: String? = null, val onAction: () -> Unit = {})

/**
 * State for [PopSnackbarHost]. Snackbars are only for confirmations such as
 * "Saved" and "Deleted · Undo": 3 s, or 6 s with an action. Never for form
 * errors.
 */
@Stable
class PopSnackbarState {
    var current by mutableStateOf<PopSnack?>(null)
        private set
    private var serial by mutableStateOf(0)
    internal val key: Int get() = serial

    fun show(message: String, actionLabel: String? = null, onAction: () -> Unit = {}) {
        current = PopSnack(message, actionLabel, onAction)
        serial++
    }

    fun dismiss() {
        current = null
    }
}

@Composable
fun rememberPopSnackbarState(): PopSnackbarState = remember { PopSnackbarState() }

/** Floating ink snackbar, radius 16, 15/700 white text with a yellow action. Place it at the bottom of a screen. */
@Composable
fun BoxScope.PopSnackbarHost(state: PopSnackbarState, modifier: Modifier = Modifier) {
    val snack = state.current ?: return
    LaunchedEffect(state.key) {
        delay((if (snack.actionLabel == null) PopMotion.snackbarMillis else PopMotion.snackbarWithActionMillis).toLong())
        state.dismiss()
    }
    Row(
        modifier
            .align(Alignment.BottomCenter)
            .padding(PopSpace.lg)
            .fillMaxWidth()
            .clip(RoundedCornerShape(PopRadius.snackbar))
            .background(PopColors.ink)
            .padding(horizontal = PopSpace.lg, vertical = 14.dp)
            .semantics { liveRegion = LiveRegionMode.Polite },
        verticalAlignment = Alignment.CenterVertically,
    ) {
        PopText(snack.message, PopTextSpecs.snackbar, Modifier.weight(1f))
        if (snack.actionLabel != null) {
            PopText(
                snack.actionLabel,
                PopTextSpecs.textButton,
                Modifier.clickable {
                    snack.onAction()
                    state.dismiss()
                },
                color = PopColors.yellow,
            )
        }
    }
}
