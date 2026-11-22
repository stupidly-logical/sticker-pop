import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../tokens/pop_tokens.g.dart';

/// A slider for picking a number in a range, like a budget limit: a white
/// track 18 high with a 2 ink outline, filled mint (or [color]) up to a 28
/// white sticker knob with a 3/3 shadow. Drag or tap to set it; arrow keys
/// and screen readers step it by [step] (default: 1/20 of the range).
class PopSlider extends StatefulWidget {
  const PopSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.min = 0,
    this.max = 1,
    this.step,
    this.color = PopColors.mint,
    this.valueLabel,
  });

  final double value;

  /// Null disables it.
  final ValueChanged<double>? onChanged;
  final String semanticLabel;
  final double min;
  final double max;

  /// Snaps to multiples of this, if set.
  final double? step;
  final Color color;

  /// How screen readers say a value ("₹12,000"); defaults to the number.
  final String Function(double value)? valueLabel;

  @override
  State<PopSlider> createState() => _PopSliderState();
}

class _PopSliderState extends State<PopSlider> {
  bool _focus = false;

  double get _range => widget.max - widget.min;
  double get _keyStep => widget.step ?? _range / 20;

  double _snap(double v) {
    var x = v.clamp(widget.min, widget.max);
    if (widget.step != null && widget.step! > 0) x = (widget.min + ((x - widget.min) / widget.step!).round() * widget.step!).clamp(widget.min, widget.max);
    return x.toDouble();
  }

  void _set(double v) {
    final x = _snap(v);
    if (x != widget.value) widget.onChanged?.call(x);
  }

  void _fromDx(double dx, double width) {
    const r = PopSize.sliderKnob / 2;
    final t = ((dx - r) / (width - 2 * r)).clamp(0.0, 1.0);
    _set(widget.min + t * _range);
  }

  String _say(double v) => widget.valueLabel?.call(v) ?? (v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1));

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    final t = _range == 0 ? 0.0 : ((widget.value - widget.min) / _range).clamp(0.0, 1.0);
    return Semantics(
      slider: true,
      enabled: enabled,
      label: widget.semanticLabel,
      value: _say(widget.value),
      increasedValue: _say(_snap(widget.value + _keyStep)),
      decreasedValue: _say(_snap(widget.value - _keyStep)),
      onIncrease: enabled ? () => _set(widget.value + _keyStep) : null,
      onDecrease: enabled ? () => _set(widget.value - _keyStep) : null,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: enabled,
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowRight): _Step(1),
          SingleActivator(LogicalKeyboardKey.arrowUp): _Step(1),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _Step(-1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _Step(-1),
        },
        actions: <Type, Action<Intent>>{
          _Step: CallbackAction<_Step>(onInvoke: (i) => _set(widget.value + i.dir * _keyStep)),
        },
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            const knob = PopSize.sliderKnob;
            final x = t * (w - knob);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: enabled ? (d) => _fromDx(d.localPosition.dx, w) : null,
              onHorizontalDragUpdate: enabled ? (d) => _fromDx(d.localPosition.dx, w) : null,
              child: SizedBox(
                height: PopSize.tapTarget,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    // Track and fill, inset so the knob's centre reaches both ends.
                    Positioned(
                      left: knob / 2 - PopSize.progressBar / 2,
                      right: knob / 2 - PopSize.progressBar / 2,
                      child: Container(
                        height: PopSize.progressBar,
                        decoration: BoxDecoration(
                          color: enabled ? PopColors.white : PopColors.paper,
                          borderRadius: BorderRadius.circular(PopRadius.progressTrack),
                          border: popOutline(PopBorder.thin),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(PopRadius.progressFill),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: x + PopSize.progressBar / 2,
                              height: double.infinity,
                              child: ColoredBox(color: enabled ? widget.color : PopColors.divider),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: x,
                      child: Container(
                        width: knob,
                        height: knob,
                        decoration: BoxDecoration(
                          color: PopColors.white,
                          shape: BoxShape.circle,
                          border: popOutline(_focus ? PopBorder.spotlight : PopBorder.regular),
                          boxShadow: enabled ? popHardShadow(PopShadow.small) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Step extends Intent {
  const _Step(this.dir);
  final int dir;
}
