import 'package:flutter/widgets.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

/// The primary action: full width, ink fill, white label, pink hard shadow.
///
/// Use one per screen or sheet, at the bottom. Pass `onPressed: null` for
/// the disabled state (muted fill).
class StickerButton extends StatelessWidget {
  const StickerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.shadowColor = PopColors.pink,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color shadowColor;

  /// Shows "label…" and ignores taps while work is in progress.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return PopPressable(
      onTap: enabled ? onPressed : null,
      shadow: PopShadow.regular,
      semanticLabel: label,
      excludeSemantics: true,
      builder: (context, shadow, _) => Container(
        height: PopSize.button,
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: PopSpace.lg),
        decoration: BoxDecoration(
          color: enabled ? PopColors.ink : PopColors.inkMuted,
          borderRadius: BorderRadius.circular(PopRadius.button),
          border: popOutline(),
          boxShadow: popHardShadow(shadow, color: shadowColor),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: PopText(
            busy ? '$label…' : label,
            spec: PopTextSpecs.buttonLabel,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

/// A secondary action in plain ink text: "Cancel", "Skip", "Show more".
class PopTextButton extends StatelessWidget {
  const PopTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.underline = false,
    this.size = 15,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool underline;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled ? PopColors.ink : PopColors.inkMuted;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: PopSize.tapTarget,
            minWidth: PopSize.tapTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PopSpace.xs),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: popText(size, weight: FontWeight.w800, color: color)
                    .copyWith(
                      decoration: underline ? TextDecoration.underline : null,
                      decorationThickness: underline ? 2 : null,
                      decorationColor: color,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A round sticker button holding one icon: back, settings, close.
///
/// [label] is required because icon-only controls need a screen-reader
/// label.
class PopIconButton extends StatelessWidget {
  const PopIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = PopColors.white,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return PopPressable(
      onTap: onTap,
      shadow: enabled ? PopShadow.small : Offset.zero,
      semanticLabel: label,
      selected: selected,
      excludeSemantics: true,
      builder: (context, shadow, _) => Container(
        width: PopSize.iconButton,
        height: PopSize.iconButton,
        decoration: BoxDecoration(
          color: enabled ? color : PopColors.paper,
          shape: BoxShape.circle,
          border: popOutline(selected ? 3 : PopBorder.regular),
          boxShadow: popHardShadow(shadow),
        ),
        child: Icon(
          icon,
          size: PopSize.iconNav,
          color: enabled ? PopColors.ink : PopColors.inkMuted,
        ),
      ),
    );
  }
}
