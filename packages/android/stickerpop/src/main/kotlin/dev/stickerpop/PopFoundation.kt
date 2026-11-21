package dev.stickerpop

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.text.ExperimentalTextApi
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopTextSpec
import dev.stickerpop.tokens.PopTilt

/** Bricolage Grotesque, one variable font with the `wght` axis set per weight. */
@OptIn(ExperimentalTextApi::class)
val BricolageGrotesque: FontFamily = FontFamily(
    listOf(600, 700, 800).map { w ->
        Font(
            resId = R.font.bricolage_grotesque,
            weight = FontWeight(w),
            variationSettings = FontVariation.Settings(FontVariation.weight(w)),
        )
    },
)

/** The [TextStyle] for one role of the type scale. Weights under 600 are raised to 600. */
fun popTextStyle(spec: PopTextSpec, color: Color = spec.color): TextStyle = TextStyle(
    fontFamily = BricolageGrotesque,
    fontSize = spec.size,
    fontWeight = if (spec.weight.weight < 600) FontWeight(600) else spec.weight,
    letterSpacing = spec.letterSpacing,
    lineHeight = spec.lineHeight?.let { spec.size * it } ?: TextStyle.Default.lineHeight,
    fontFeatureSettings = if (spec.tabular) "tnum" else null,
    color = color,
)

/** Upper-cases [text] when the role is an ALL CAPS one. */
fun popCaps(spec: PopTextSpec, text: String): String = if (spec.caps) text.uppercase() else text

/** Underline helper for text buttons. */
fun TextStyle.underlined(): TextStyle = copy(textDecoration = TextDecoration.Underline)

/**
 * Draws a sticker: a solid, blur-free shadow offset down-right, the fill, and
 * the ink outline. [shadow] of 0.dp draws no shadow.
 */
fun Modifier.sticker(
    fill: Color,
    shape: Shape,
    radius: Dp,
    border: Dp = PopBorder.regular,
    shadow: Dp = 4.dp,
    shadowColor: Color = PopColors.ink,
    brush: Brush? = null,
): Modifier = this
    .drawBehind {
        if (shadow > 0.dp) {
            val s = shadow.toPx()
            drawRoundRect(
                color = shadowColor,
                topLeft = Offset(s, s),
                size = Size(size.width, size.height),
                cornerRadius = CornerRadius(radius.toPx()),
            )
        }
    }
    .then(if (brush != null) Modifier.background(brush, shape) else Modifier.background(fill, shape))
    .border(border, PopColors.ink, shape)

/** Tilts content as if stuck on by hand. Clamped to ±6°. */
fun Modifier.popTilt(degrees: Float): Modifier =
    if (degrees == 0f) this else rotate(degrees.coerceIn(-PopTilt.max, PopTilt.max))

/** Cream paper with the dot grid, behind every screen. */
@Composable
fun PaperBackground(modifier: Modifier = Modifier, content: @Composable BoxScope.() -> Unit) {
    Box(modifier.background(PopColors.paper)) {
        Canvas(Modifier.fillMaxSize()) {
            val step = PopSize.paperDotStep.toPx()
            val r = PopSize.paperDotRadius.toPx()
            var y = step / 2
            while (y < size.height) {
                var x = step / 2
                while (x < size.width) {
                    drawCircle(PopColors.paperDot, r, Offset(x, y))
                    x += step
                }
                y += step
            }
        }
        content()
    }
}

/** The widest a single column of content gets (tablets, desktop). */
val PopMaxContentWidth = 600.dp

/** Centres content and caps it at [PopMaxContentWidth] on wide screens. */
fun Modifier.popContentWidth(): Modifier = fillMaxWidth().wrapContentWidth().widthIn(max = PopMaxContentWidth)
