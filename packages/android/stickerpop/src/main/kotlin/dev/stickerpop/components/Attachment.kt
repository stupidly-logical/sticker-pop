package dev.stickerpop.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AddAPhoto
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.Description
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import dev.stickerpop.tokens.PopBorder
import dev.stickerpop.tokens.PopColors
import dev.stickerpop.tokens.PopRadius
import dev.stickerpop.tokens.PopShadow
import dev.stickerpop.tokens.PopSize
import dev.stickerpop.tokens.PopSpace
import dev.stickerpop.tokens.PopTextSpecs

/**
 * A place to attach a file, like a receipt photo. Empty, it is a dashed tile
 * (paper, 2 dashed ink outline, radius 18) with an icon, label and caption;
 * tapping it calls [onPick], where you open the platform picker. Filled
 * ([fileName] set), it is a white sticker with a thumbnail ([preview]) or a
 * file icon, the name, an optional size and a remove button.
 */
@Composable
fun PopAttachmentTile(
    onPick: () -> Unit,
    modifier: Modifier = Modifier,
    label: String = "Add a receipt",
    caption: String = "Photo or PDF",
    icon: ImageVector = Icons.Rounded.AddAPhoto,
    fileName: String? = null,
    fileSize: String? = null,
    onRemove: (() -> Unit)? = null,
    preview: (@Composable () -> Unit)? = null,
) {
    if (fileName == null) {
        val shape = RoundedCornerShape(PopRadius.tile)
        Box(
            modifier
                .fillMaxWidth()
                .heightIn(min = 96.dp)
                .clip(shape)
                .clearAndSetSemantics { contentDescription = "$label, $caption"; role = Role.Button }
                .clickable(onClick = onPick),
            contentAlignment = Alignment.Center,
        ) {
            Canvas(Modifier.matchParentSize()) {
                val w = PopBorder.thin.toPx()
                val r = PopRadius.tile.toPx()
                drawRoundRect(PopColors.paper, cornerRadius = CornerRadius(r))
                drawRoundRect(
                    PopColors.ink,
                    topLeft = androidx.compose.ui.geometry.Offset(w / 2, w / 2),
                    size = androidx.compose.ui.geometry.Size(size.width - w, size.height - w),
                    cornerRadius = CornerRadius(r - w / 2),
                    style = Stroke(w, pathEffect = PathEffect.dashPathEffect(floatArrayOf(7.dp.toPx(), 5.dp.toPx()))),
                )
            }
            Column(Modifier.padding(PopSpace.lg), horizontalAlignment = Alignment.CenterHorizontally) {
                PopIcon(icon, PopSize.iconTile)
                Spacer(Modifier.size(PopSpace.xs))
                PopText(label, PopTextSpecs.tileLabel, align = TextAlign.Center)
                PopText(caption, PopTextSpecs.caption, align = TextAlign.Center)
            }
        }
        return
    }
    StickerCard(modifier.fillMaxWidth(), radius = PopRadius.tile, shadow = PopShadow.small,
        padding = PaddingValues(start = PopSpace.md, top = PopSpace.md, bottom = PopSpace.md, end = PopSpace.xs)) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Start) {
            Box(Modifier.size(48.dp).clip(RoundedCornerShape(PopRadius.badge)).background(PopColors.paper), contentAlignment = Alignment.Center) {
                if (preview != null) preview() else PopIcon(Icons.Rounded.Description, PopSize.iconTile)
            }
            Spacer(Modifier.width(PopSpace.md))
            Column(Modifier.weight(1f)) {
                PopText(fileName, PopTextSpecs.rowTitle, maxLines = 1)
                if (fileSize != null) PopText(fileSize, PopTextSpecs.caption)
            }
            if (onRemove != null) {
                Box(
                    Modifier.size(44.dp).clearAndSetSemantics { contentDescription = "Remove $fileName"; role = Role.Button }.clickable(onClick = onRemove),
                    contentAlignment = Alignment.Center,
                ) { PopIcon(Icons.Rounded.Close, 20.dp) }
            }
        }
    }
}
