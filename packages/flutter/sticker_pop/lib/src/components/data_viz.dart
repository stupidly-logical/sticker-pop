import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

/// A goal or budget bar: white track 18 high with a 2 ink outline, filled
/// with a bright clipped to radius 7.
///
/// Over 100% the fill stays full; say so in words next to the bar.
class PopProgressBar extends StatelessWidget {
  const PopProgressBar({
    super.key,
    required this.value,
    this.color = PopColors.mint,
    required this.semanticLabel,
  });

  /// 0 to 1. Values outside are clamped.
  final double value;
  final Color color;

  /// e.g. "Groceries budget, 80% used".
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(v * 100).round()}%',
      excludeSemantics: true,
      child: Container(
        height: PopSize.progressBar,
        decoration: BoxDecoration(
          color: PopColors.white,
          borderRadius: BorderRadius.circular(PopRadius.progressTrack),
          border: popOutline(PopBorder.thin),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PopRadius.progressFill),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  border: v > 0 && v < 1
                      ? const Border(right: BorderSide(color: PopColors.ink, width: PopBorder.thin))
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One slice, bar or legend entry.
@immutable
class PopDatum {
  const PopDatum({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;
}

/// A donut chart: one bright per slice, each outlined in 2.5 ink, around a
/// yellow centre disc that holds [center].
class PopDonut extends StatelessWidget {
  const PopDonut({
    super.key,
    required this.data,
    this.size = 180,
    this.thickness = 38,
    this.center,
    required this.semanticLabel,
  });

  final List<PopDatum> data;
  final double size;
  final double thickness;
  final Widget? center;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _DonutPainter(data, thickness),
          child: Center(child: center),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.data, this.thickness);

  final List<PopDatum> data;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<double>(0, (s, d) => s + d.value);
    final c = size.center(Offset.zero);
    final outer = size.shortestSide / 2 - PopBorder.regular / 2;
    final inner = outer - thickness;
    final stroke = Paint()
      ..color = PopColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = PopBorder.regular
      ..strokeJoin = StrokeJoin.round;

    if (total > 0) {
      var start = -math.pi / 2;
      for (final d in data) {
        final sweep = d.value / total * math.pi * 2;
        final path = Path()
          ..arcTo(Rect.fromCircle(center: c, radius: outer), start, sweep, true)
          ..arcTo(Rect.fromCircle(center: c, radius: inner), start + sweep, -sweep, false)
          ..close();
        canvas.drawPath(path, Paint()..color = d.color);
        canvas.drawPath(path, stroke);
        start += sweep;
      }
    } else {
      canvas.drawCircle(c, outer, Paint()..color = PopColors.white);
      canvas.drawCircle(c, outer, stroke);
    }
    // Yellow centre disc.
    final disc = inner - 8;
    canvas.drawCircle(c, disc, Paint()..color = PopColors.yellow);
    canvas.drawCircle(c, disc, stroke);
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.data != data || old.thickness != thickness;
}

/// Vertical bars with bright fills and ink outlines. No gridlines.
class PopBarChart extends StatelessWidget {
  const PopBarChart({
    super.key,
    required this.data,
    this.height = 140,
    this.highlightIndex,
    required this.semanticLabel,
  });

  final List<PopDatum> data;
  final double height;

  /// The bar to emphasise (e.g. this month): it gets a heavier outline and
  /// a hard shadow, so emphasis doesn't rely on colour.
  final int? highlightIndex;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final max = data.fold<double>(0, (m, d) => math.max(m, d.value));
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      // Bars live in a fixed-height area; labels sit below it and can grow
      // with the system text size without overflowing.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (i, d) in data.indexed)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: height,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: max == 0 ? 4 : math.max(4, d.value / max * height),
                          decoration: BoxDecoration(
                            color: d.color,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            border: popOutline(i == highlightIndex ? 3 : PopBorder.thin),
                            boxShadow: i == highlightIndex ? popHardShadow(PopShadow.chip) : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: PopText(
                        d.label,
                        spec: i == highlightIndex ? PopTextSpecs.navLabelSelected : PopTextSpecs.navLabel,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A chart legend: 12 square swatches (1.5 outline, radius 4), label 14/700
/// and percentage 14/800 tabular.
class PopLegend extends StatelessWidget {
  const PopLegend({super.key, required this.data});

  final List<PopDatum> data;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (s, d) => s + d.value);
    return Column(
      children: <Widget>[
        for (final d in data)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: <Widget>[
                Container(
                  width: PopSize.swatch,
                  height: PopSize.swatch,
                  decoration: BoxDecoration(
                    color: d.color,
                    borderRadius: BorderRadius.circular(PopRadius.swatch),
                    border: popOutline(PopBorder.swatch),
                  ),
                ),
                const SizedBox(width: PopSpace.sm),
                Expanded(child: PopText(d.label, spec: PopTextSpecs.legendLabel)),
                PopText(
                  total == 0 ? '0%' : '${(d.value / total * 100).round()}%',
                  spec: PopTextSpecs.legendValue,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
