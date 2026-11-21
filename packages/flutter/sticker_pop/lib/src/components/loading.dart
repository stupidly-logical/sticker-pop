import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../tokens/pop_tokens.g.dart';
import 'badges_and_lists.dart';

/// A placeholder shape shown while content loads: divider-coloured, no
/// outline, gently pulsing (still under reduced motion). Group skeletons in
/// a [PopSkeletonGroup] so screen readers hear "Loading" once.
class PopSkeleton extends StatefulWidget {
  /// A text line, 14 high.
  const PopSkeleton.line({super.key, this.width, this.height = PopSize.skeletonLine})
    : radius = PopRadius.skeletonLine,
      circle = false;

  /// A circle, e.g. where a category dot will be.
  const PopSkeleton.circle({super.key, double size = PopSize.categoryDot})
    : width = size,
      height = size,
      radius = 0,
      circle = true;

  /// A block, e.g. where a card or chart will be.
  const PopSkeleton.block({super.key, this.width, required this.height, this.radius = PopRadius.card}) : circle = false;

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  State<PopSkeleton> createState() => _PopSkeletonState();
}

class _PopSkeletonState extends State<PopSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: PopMotion.pulse);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _pulse.stop();
      _pulse.value = 0;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.55).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: PopColors.divider,
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.circle ? null : BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

/// Wraps skeletons so assistive tech announces [label] once.
class PopSkeletonGroup extends StatelessWidget {
  const PopSkeletonGroup({super.key, required this.child, this.label = 'Loading'});

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(label: label, liveRegion: true, container: true, child: child);
}

/// A [StickerList] of skeleton rows: a circle and two lines each, the shape
/// of the rows that will replace them.
class PopSkeletonList extends StatelessWidget {
  const PopSkeletonList({super.key, this.rows = 3});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return PopSkeletonGroup(
      child: StickerList(
        children: <Widget>[
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PopSpace.lg, vertical: 12),
              child: Row(
                children: <Widget>[
                  const PopSkeleton.circle(),
                  const SizedBox(width: PopSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FractionallySizedBox(widthFactor: i.isEven ? 0.6 : 0.45, child: const PopSkeleton.line()),
                        const SizedBox(height: PopSpace.sm),
                        const FractionallySizedBox(widthFactor: 0.8, child: PopSkeleton.line(height: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(width: PopSpace.md),
                  const PopSkeleton.line(width: 56),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A small spinner for short waits: a 24 divider ring with a turning ink
/// arc. Under reduced motion the arc stays still. For buttons, prefer the
/// button's own busy label ("Saving…").
class PopSpinner extends StatefulWidget {
  const PopSpinner({super.key, this.size = PopSize.spinner, this.semanticLabel = 'Loading'});

  final double size;
  final String semanticLabel;

  @override
  State<PopSpinner> createState() => _PopSpinnerState();
}

class _PopSpinnerState extends State<PopSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: PopMotion.spin);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _spin.stop();
    } else if (!_spin.isAnimating) {
      _spin.repeat();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      child: RotationTransition(
        turns: _spin,
        child: CustomPaint(size: Size.square(widget.size), painter: _SpinnerPainter()),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width / 8;
    final rect = Offset.zero & size;
    final inset = rect.deflate(stroke / 2);
    canvas.drawCircle(rect.center, inset.width / 2, Paint()..color = PopColors.divider..style = PaintingStyle.stroke..strokeWidth = stroke);
    canvas.drawArc(
      inset,
      -math.pi / 2,
      math.pi / 2,
      false,
      Paint()..color = PopColors.ink..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => false;
}
