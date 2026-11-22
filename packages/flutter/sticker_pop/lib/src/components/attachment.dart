import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

/// A place to attach a file, like a receipt photo. Empty, it is a dashed
/// tile (paper fill, 2 dashed ink outline, radius 18) with an icon, a 15/800
/// label and a caption; tapping it should open the platform picker
/// ([onPick] – the library doesn't pick files itself). Filled ([fileName]
/// set), it is a white sticker with a thumbnail ([preview]) or file icon,
/// the name, an optional size and a remove button.
class PopAttachmentTile extends StatelessWidget {
  const PopAttachmentTile({
    super.key,
    required this.onPick,
    this.label = 'Add a receipt',
    this.caption = 'Photo or PDF',
    this.icon = Icons.add_a_photo_rounded,
    this.fileName,
    this.fileSize,
    this.preview,
    this.onRemove,
  });

  final VoidCallback onPick;
  final String label;
  final String caption;
  final IconData icon;
  final String? fileName;
  final String? fileSize;

  /// A small thumbnail (e.g. an Image) shown when filled.
  final Widget? preview;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (fileName == null) {
      return Semantics(
        button: true,
        label: '$label, $caption',
        onTap: onPick,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPick,
          child: CustomPaint(
            painter: _DashedBorder(),
            child: Container(
              constraints: const BoxConstraints(minHeight: 96),
              padding: const EdgeInsets.all(PopSpace.lg),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: PopSize.iconTile, color: PopColors.ink),
                  const SizedBox(height: PopSpace.xs),
                  PopText(label, spec: PopTextSpecs.tileLabel, textAlign: TextAlign.center),
                  PopText(caption, spec: PopTextSpecs.caption, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(PopSpace.md, PopSpace.md, PopSpace.xs, PopSpace.md),
      decoration: BoxDecoration(
        color: PopColors.white,
        borderRadius: BorderRadius.circular(PopRadius.tile),
        border: popOutline(),
        boxShadow: popHardShadow(PopShadow.small),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(PopRadius.badge),
            child: SizedBox.square(
              dimension: 48,
              child: preview ?? const ColoredBox(color: PopColors.paper, child: Icon(Icons.description_rounded, size: PopSize.iconTile, color: PopColors.ink)),
            ),
          ),
          const SizedBox(width: PopSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PopText(fileName!, spec: PopTextSpecs.rowTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (fileSize != null) PopText(fileSize!, spec: PopTextSpecs.caption),
              ],
            ),
          ),
          if (onRemove != null)
            Semantics(
              button: true,
              label: 'Remove $fileName',
              onTap: onRemove,
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRemove,
                child: const SizedBox.square(dimension: 44, child: Icon(Icons.close_rounded, size: 20, color: PopColors.ink)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(PopRadius.tile)).deflate(PopBorder.thin / 2);
    canvas.drawRRect(rrect, Paint()..color = PopColors.paper);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = PopColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = PopBorder.thin;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 12) {
        canvas.drawPath(m.extractPath(d, d + 7), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => false;
}
