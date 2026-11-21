import 'package:flutter/widgets.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

/// A card with a thick ink outline and a hard offset shadow.
///
/// White by default. Use [StickerCard.hero] for the yellow headline card
/// (net worth, month spend) and [StickerCard.info] for blue, lilac or mint
/// information cards.
class StickerCard extends StatelessWidget {
  const StickerCard({
    super.key,
    required this.child,
    this.color = PopColors.white,
    this.padding = const EdgeInsets.all(PopSpace.card),
    this.radius = PopRadius.card,
    this.shadow = PopShadow.regular,
    this.shadowColor = PopColors.ink,
    this.tiltDegrees = 0,
    this.onTap,
    this.semanticLabel,
    this.gradient,
  }) : assert(
         tiltDegrees >= -PopTilt.cardMax && tiltDegrees <= PopTilt.cardMax,
         'Cards tilt at most ±3°',
       );

  /// The yellow headline card with the large shadow and an optional tilt.
  const StickerCard.hero({
    super.key,
    required this.child,
    this.color = PopColors.yellow,
    this.padding = const EdgeInsets.all(PopSpace.xl),
    this.tiltDegrees = 0,
    this.onTap,
    this.semanticLabel,
    this.gradient,
  }) : radius = PopRadius.card,
       shadow = PopShadow.large,
       shadowColor = PopColors.ink;

  /// A blue, lilac or mint card for information and hints.
  const StickerCard.info({
    super.key,
    required this.child,
    this.color = PopColors.blue,
    this.padding = const EdgeInsets.all(PopSpace.card),
    this.onTap,
    this.semanticLabel,
    this.gradient,
  }) : radius = PopRadius.card,
       shadow = PopShadow.regular,
       shadowColor = PopColors.ink,
       tiltDegrees = 0;

  final Widget child;
  final Color color;

  /// A gradient fill from [PopGradients]; replaces [color] when set.
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Offset shadow;
  final Color shadowColor;

  /// A slight rotation makes a card read as a stuck-on sticker. Keep it
  /// within ±3°, and leave text-heavy cards straight.
  final double tiltDegrees;

  /// Makes the whole card tappable, with the press-down feedback.
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Fill and shadow behind; the outline in front, so content (dividers,
    // selected rows) never paints over it; content clipped to the corners.
    Widget surface(Offset shadowOffset) => DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: popHardShadow(shadowOffset, color: shadowColor),
      ),
      position: DecorationPosition.background,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: popOutline(),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    final card = onTap == null
        ? surface(shadow)
        : PopPressable(
            onTap: onTap,
            shadow: shadow,
            semanticLabel: semanticLabel,
            builder: (context, s, _) => surface(s),
          );
    return PopTilted(degrees: tiltDegrees, child: card);
  }
}

/// The lilac empty-state card: one or two sentences saying what will appear
/// here and how to start.
class PopHintCard extends StatelessWidget {
  const PopHintCard({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.action,
    this.color = PopColors.lilac,
  });

  final String message;
  final String? title;
  final Widget? icon;

  /// Usually a [PopTextButton].
  final Widget? action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return StickerCard.info(
      color: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            IconTheme.merge(
              data: const IconThemeData(
                color: PopColors.ink,
                size: PopSize.iconNav,
              ),
              child: icon!,
            ),
            const SizedBox(width: PopSpace.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  PopText(title!, spec: PopTextSpecs.rowTitle),
                  const SizedBox(height: PopSpace.xs),
                ],
                PopText(message, spec: PopTextSpecs.body),
                if (action != null) ...<Widget>[
                  const SizedBox(height: PopSpace.sm),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
