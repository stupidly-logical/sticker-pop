import 'package:material_ui/material_ui.dart';

import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'badges_and_lists.dart';
import 'sticker_card.dart';

/// Which way a [PopStatTile]'s change went, and whether that's good.
enum PopTrend {
  /// "+" in a mint badge.
  upGood,

  /// "+" in an orange badge (e.g. spending went up).
  upBad,

  /// "−" in a mint badge (e.g. spending went down).
  downGood,

  /// "−" in an orange badge.
  downBad,
}

/// A headline number on a dashboard: a 13/800 caps label, a 28/800 tabular
/// figure, an optional change badge ("+12.4%", mint when good, orange when
/// not) and an optional caption. A StickerCard, white by default; usually
/// two side by side.
class PopStatTile extends StatelessWidget {
  const PopStatTile({
    super.key,
    required this.label,
    required this.value,
    this.change,
    this.trend = PopTrend.upGood,
    this.caption,
    this.color = PopColors.white,
    this.onTap,
  });

  final String label;

  /// The formatted figure, e.g. "₹51.2k".
  final String value;

  /// The formatted change, e.g. "12.4%"; the arrow comes from [trend].
  final String? change;
  final PopTrend trend;
  final String? caption;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final up = trend == PopTrend.upGood || trend == PopTrend.upBad;
    final good = trend == PopTrend.upGood || trend == PopTrend.downGood;
    final spoken = <String?>[label, value, if (change != null) '${up ? 'up' : 'down'} $change', caption].whereType<String>().join(', ');
    final card = StickerCard(
      color: color,
      onTap: onTap,
      semanticLabel: spoken,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PopText(label, spec: PopTextSpecs.sectionLabel),
            const SizedBox(height: PopSpace.xs),
            PopText(value, spec: PopTextSpecs.cardFigure),
            if (change != null || caption != null) const SizedBox(height: PopSpace.sm),
            if (change != null) StickerBadge(label: '${up ? '+' : '−'}$change', color: good ? PopColors.mint : PopColors.orange),
            if (caption != null) ...<Widget>[
              if (change != null) const SizedBox(height: PopSpace.xs),
              PopText(caption!, spec: PopTextSpecs.caption),
            ],
          ],
        ),
      ),
    );
    // A tappable card announces its own label; a plain one needs it here.
    return onTap != null ? card : Semantics(container: true, label: spoken, child: card);
  }
}
