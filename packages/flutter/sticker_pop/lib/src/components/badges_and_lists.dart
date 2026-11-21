import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'sticker_card.dart';

/// A small tilted label: "UPI", "Unsure", "80%", "COMING SOON".
class StickerBadge extends StatelessWidget {
  const StickerBadge({
    super.key,
    required this.label,
    this.color = PopColors.white,
    this.tiltDegrees = PopTilt.badge,
    this.fontSize = 12,
    this.caps = false,
    this.gradient,
  });

  final String label;
  final Color color;

  /// A gradient fill from [PopGradients]; replaces [color] when set.
  final Gradient? gradient;
  final double tiltDegrees;

  /// 11 to 13.
  final double fontSize;

  /// Badges like "COMING SOON" are set in caps with +0.6 tracking.
  final bool caps;

  @override
  Widget build(BuildContext context) {
    return PopTilted(
      degrees: tiltDegrees,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(PopRadius.badge),
          border: popOutline(PopBorder.thin),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
          child: Text(
            caps ? label.toUpperCase() : label,
            semanticsLabel: label,
            style: popText(
              fontSize,
              weight: FontWeight.w800,
              letterSpacing: caps ? 0.6 : 0,
              tabular: true,
            ),
          ),
        ),
      ),
    );
  }
}

/// A round, tilted icon sticker in a bright, used to mark what a list row
/// is (a category, a type, an account). The mapping from your data to an
/// icon and colour belongs to your app.
class CategoryDot extends StatelessWidget {
  const CategoryDot({
    super.key,
    required this.icon,
    required this.color,
    this.tiltDegrees = PopTilt.categoryDot,
    this.size = PopSize.categoryDot,
  });

  final IconData icon;
  final Color color;
  final double tiltDegrees;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: PopTilted(
        degrees: tiltDegrees,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: popOutline(PopBorder.thin),
          ),
          child: Icon(icon, size: size * 0.48, color: PopColors.ink),
        ),
      ),
    );
  }
}

/// A sticker card holding rows separated by 2px divider lines.
class StickerList extends StatelessWidget {
  const StickerList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return StickerCard(
      // No padding: a selected row's fill reaches the outline on every edge.
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (final (index, child) in children.indexed) ...<Widget>[
            if (index > 0)
              const SizedBox(
                height: PopBorder.divider,
                width: double.infinity,
                child: ColoredBox(color: PopColors.divider),
              ),
            child,
          ],
        ],
      ),
    );
  }
}

/// One row in a [StickerList]: a category dot, a title over a muted second
/// line, and a right-aligned tabular amount.
class StickerListRow extends StatelessWidget {
  const StickerListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.amount,
    this.amountCaption,
    this.badge,
    this.onTap,
    this.selected = false,
  });

  final String title;
  final String? subtitle;

  /// Usually a [CategoryDot].
  final Widget? leading;

  /// The formatted amount, e.g. "−₹450" or "+₹52,000".
  final String? amount;

  /// A small muted line under the amount, e.g. "1:12 pm".
  final String? amountCaption;

  /// Shown after the title, e.g. a "UPI" [StickerBadge].
  final Widget? badge;
  final VoidCallback? onTap;

  /// Selected rows (multi-select) get a yellow fill.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      color: selected ? PopColors.yellow : null,
      constraints: const BoxConstraints(minHeight: PopSize.rowMin),
      padding: const EdgeInsets.symmetric(
        horizontal: PopSpace.lg,
        vertical: 11,
      ),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: PopSpace.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Wrap(
                  spacing: PopSpace.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    PopText(title, spec: PopTextSpecs.rowTitle),
                    ?badge,
                  ],
                ),
                if (subtitle != null)
                  PopText(subtitle!, spec: PopTextSpecs.caption),
              ],
            ),
          ),
          if (amount != null) ...<Widget>[
            const SizedBox(width: PopSpace.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PopText(amount!, spec: PopTextSpecs.rowAmount),
                if (amountCaption != null)
                  PopText(amountCaption!, spec: PopTextSpecs.caption),
              ],
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return Semantics(selected: selected, child: row);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: row,
      ),
    );
  }
}

/// A small caps section label: "NET WORTH", "RECENT".
class PopSectionLabel extends StatelessWidget {
  const PopSectionLabel(this.text, {super.key, this.trailing});

  final String text;

  /// Usually a [PopTextButton] such as "See all".
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: <Widget>[
          Expanded(child: PopText(text, spec: PopTextSpecs.sectionLabel)),
          ?trailing,
        ],
      ),
    );
  }
}
