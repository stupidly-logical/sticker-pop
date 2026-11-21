import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'buttons.dart';

/// Tour progress: 10-high dots, 22 wide for the current step, pink once
/// reached, each with a 2 ink outline.
class PopProgressDots extends StatelessWidget {
  const PopProgressDots({super.key, required this.count, required this.current});

  final int count;

  /// Zero-based.
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step ${current + 1} of $count',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < count; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 6),
            AnimatedContainer(
              duration: PopMotion.toggle,
              width: i == current ? PopSize.progressDotCurrent : PopSize.progressDot,
              height: PopSize.progressDot,
              decoration: BoxDecoration(
                color: i <= current ? PopColors.pink : PopColors.white,
                borderRadius: BorderRadius.circular(PopSize.progressDot / 2),
                border: popOutline(PopBorder.thin),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The yellow coach-mark card: progress dots and "Skip", a title, a body
/// and "Next" or "Got it".
class PopTourCard extends StatelessWidget {
  const PopTourCard({
    super.key,
    required this.step,
    required this.count,
    required this.title,
    required this.body,
    required this.onNext,
    this.onSkip,
    this.tiltDegrees,
  });

  /// Zero-based.
  final int step;
  final int count;
  final String title;
  final String body;
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  /// Defaults to alternating −1.5° / +1.5° by step.
  final double? tiltDegrees;

  @override
  Widget build(BuildContext context) {
    final last = step == count - 1;
    return PopTilted(
      degrees: tiltDegrees ?? (step.isEven ? PopTilt.hero : PopTilt.heroAlt),
      child: Container(
        padding: const EdgeInsets.all(PopSpace.xl),
        decoration: BoxDecoration(
          color: PopColors.yellow,
          borderRadius: BorderRadius.circular(PopRadius.card),
          border: popOutline(),
          boxShadow: popHardShadow(PopShadow.large),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                PopProgressDots(count: count, current: step),
                const Spacer(),
                if (onSkip != null && !last)
                  PopTextButton(label: 'Skip', onPressed: onSkip, underline: true),
              ],
            ),
            const SizedBox(height: PopSpace.sm),
            Semantics(header: true, child: PopText(title, spec: PopTextSpecs.sheetTitle)),
            const SizedBox(height: PopSpace.xs),
            PopText(body, spec: PopTextSpecs.body),
            const SizedBox(height: PopSpace.lg),
            StickerButton(label: last ? 'Got it' : 'Next', onPressed: onNext),
          ],
        ),
      ),
    );
  }
}

/// One stop on a tour.
@immutable
class PopTourStep {
  const PopTourStep({required this.target, required this.title, required this.body});

  /// The real control to spotlight.
  final GlobalKey target;
  final String title;
  final String body;
}

/// Runs a coach-mark tour over the current screen. Completes with `true`
/// when the last step is acknowledged, `false` if the user skipped.
Future<bool> showPopTour(BuildContext context, List<PopTourStep> steps) {
  assert(steps.isNotEmpty, 'A tour needs at least one step');
  final overlay = Overlay.of(context);
  final result = Completer<bool>();
  var index = 0;
  late final OverlayEntry entry;

  void close(bool finished) {
    entry.remove();
    result.complete(finished);
  }

  entry = OverlayEntry(
    builder: (context) => _PopTourOverlay(
      step: steps[index],
      index: index,
      count: steps.length,
      onNext: () {
        if (index == steps.length - 1) {
          close(true);
        } else {
          index++;
          entry.markNeedsBuild();
        }
      },
      onSkip: () => close(false),
    ),
  );
  overlay.insert(entry);
  return result.future;
}

class _PopTourOverlay extends StatelessWidget {
  const _PopTourOverlay({
    required this.step,
    required this.index,
    required this.count,
    required this.onNext,
    required this.onSkip,
  });

  final PopTourStep step;
  final int index;
  final int count;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final box = step.target.currentContext?.findRenderObject() as RenderBox?;
    final screen = MediaQuery.sizeOf(context);
    final rect = box == null
        ? Rect.fromCenter(center: screen.center(Offset.zero), width: 0, height: 0)
        : (box.localToGlobal(Offset.zero) & box.size).inflate(8);
    final below = rect.center.dy < screen.height / 2;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            onTap: () {},
            child: CustomPaint(painter: PopSpotlightPainter(rect)),
          ),
        ),
        Positioned(
          left: PopSpace.lg,
          right: PopSpace.lg,
          top: below ? rect.bottom + PopSpace.lg : null,
          bottom: below ? null : screen.height - rect.top + PopSpace.lg,
          child: Material(
            type: MaterialType.transparency,
            child: PopTourCard(
              step: index,
              count: count,
              title: step.title,
              body: step.body,
              onNext: onNext,
              onSkip: onSkip,
            ),
          ),
        ),
      ],
    );
  }
}

/// Dims the screen under a 72% ink scrim with a rounded cut-out (radius 18)
/// around [hole], outlined 3 in yellow.
class PopSpotlightPainter extends CustomPainter {
  const PopSpotlightPainter(this.hole);

  final Rect hole;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(hole, const Radius.circular(PopRadius.spotlight));
    final scrim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(rrect);
    canvas.drawPath(scrim, Paint()..color = PopColors.scrim);
    if (!hole.isEmpty) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = PopColors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = PopBorder.spotlight,
      );
    }
  }

  @override
  bool shouldRepaint(PopSpotlightPainter old) => old.hole != hole;
}
