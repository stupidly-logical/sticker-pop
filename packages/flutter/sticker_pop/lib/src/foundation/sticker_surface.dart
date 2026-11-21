import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/pop_tokens.g.dart';

/// Rotates [child] by [degrees], as if stuck on by hand. Zero is a no-op.
///
/// Tilt is a garnish: badges, a hero card, the add button. Never tilt lists,
/// inputs or long text, and never beyond ±[PopTilt.max]°.
class PopTilted extends StatelessWidget {
  const PopTilted({super.key, required this.degrees, required this.child})
    : assert(
        degrees >= -PopTilt.max && degrees <= PopTilt.max,
        'Sticker Pop never tilts beyond ±6°',
      );

  final double degrees;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (degrees == 0) return child;
    return Transform.rotate(angle: degrees * math.pi / 180, child: child);
  }
}

/// The hard, blur-free shadow every sticker surface casts.
List<BoxShadow> popHardShadow(Offset offset, {Color color = PopColors.ink}) {
  if (offset == Offset.zero) return const <BoxShadow>[];
  return <BoxShadow>[BoxShadow(color: color, offset: offset)];
}

/// The solid ink outline.
Border popOutline([double width = PopBorder.regular]) =>
    Border.all(color: PopColors.ink, width: width);

/// Wraps a tappable sticker so a press reads as pushing the sticker down
/// onto the page: it moves by its shadow offset and the shadow disappears.
///
/// This is Sticker Pop's only touch feedback; there are no ripples.
class PopPressable extends StatefulWidget {
  const PopPressable({
    super.key,
    required this.onTap,
    required this.shadow,
    required this.builder,
    this.semanticLabel,
    this.selected,
    this.excludeSemantics = false,
  });

  final VoidCallback? onTap;

  /// The resting shadow offset; while pressed the sticker moves by it.
  final Offset shadow;

  /// Builds the sticker for the current shadow offset.
  final Widget Function(BuildContext context, Offset shadow, bool pressed)
  builder;
  final String? semanticLabel;
  final bool? selected;
  final bool excludeSemantics;

  @override
  State<PopPressable> createState() => _PopPressableState();
}

class _PopPressableState extends State<PopPressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final pressed = enabled && _pressed;
    final shadow = pressed ? Offset.zero : widget.shadow;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      excludeSemantics: widget.excludeSemantics,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        child: Transform.translate(
          offset: pressed ? widget.shadow : Offset.zero,
          child: widget.builder(context, shadow, pressed),
        ),
      ),
    );
  }
}

/// The cream paper with a dot grid that sits behind every screen.
class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PopColors.paper,
      child: CustomPaint(painter: const PaperDotPainter(), child: child),
    );
  }
}

/// Paints the paper dot grid: radius 1.3 dots every 18, offset half a step.
class PaperDotPainter extends CustomPainter {
  const PaperDotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const step = PopSize.paperDotStep;
    final paint = Paint()..color = PopColors.paperDot;
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), PopSize.paperDotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Screen padding: 20 at the sides on phones; on wider screens the content
/// is centred and capped at [maxContentWidth] so cards and rows don't
/// stretch across a tablet.
EdgeInsets popScreenPadding(BuildContext context, {double top = 0, double bottom = 0}) {
  final width = MediaQuery.sizeOf(context).width;
  final side = width > maxContentWidth + PopSpace.screen * 2 ? (width - maxContentWidth) / 2 : PopSpace.screen;
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}

/// The widest a single column of content gets (tablets, web, desktop).
const double maxContentWidth = 600;
