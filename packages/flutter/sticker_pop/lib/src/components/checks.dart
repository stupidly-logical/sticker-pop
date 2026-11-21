import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

/// A checkbox: a 24 rounded square (radius 7). Unchecked it is white with a
/// 2 ink outline; checked it fills mint with a 2.5 outline and an ink tick.
/// With [tristate], a null [value] shows a dash (some, not all). Padded to a
/// 48 tap target. Pair it with a label: usually use [PopCheckboxRow].
class PopCheckbox extends StatelessWidget {
  const PopCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.tristate = false,
  }) : assert(tristate || value != null);

  final bool? value;

  /// Null disables it. Tapping a mixed (null) box checks it.
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Semantics(
      checked: value ?? false,
      mixed: tristate && value == null,
      enabled: enabled,
      label: semanticLabel,
      onTap: enabled ? () => onChanged!(value != true) : null,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(value != true) : null,
        child: SizedBox.square(
          dimension: PopSize.tapTarget,
          child: Center(child: PopCheckboxMark(value: value, enabled: enabled)),
        ),
      ),
    );
  }
}

/// The checkbox drawing on its own (no tap handling).
class PopCheckboxMark extends StatelessWidget {
  const PopCheckboxMark({super.key, required this.value, this.enabled = true});

  final bool? value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final on = value != false;
    final fill = !enabled ? (on ? PopColors.divider : PopColors.paper) : (on ? PopColors.mint : PopColors.white);
    final mark = enabled ? PopColors.ink : PopColors.inkMuted;
    return AnimatedContainer(
      duration: PopMotion.toggle,
      curve: Curves.easeOut,
      width: PopSize.checkbox,
      height: PopSize.checkbox,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(PopRadius.checkbox),
        border: popOutline(on ? PopBorder.regular : PopBorder.thin),
      ),
      child: value == false ? null : CustomPaint(painter: _MarkPainter(dash: value == null, color: mark)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.dash, required this.color});

  final bool dash;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    if (dash) {
      canvas.drawLine(Offset(w * 0.28, h * 0.5), Offset(w * 0.72, h * 0.5), paint);
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.24, h * 0.52)
          ..lineTo(w * 0.43, h * 0.7)
          ..lineTo(w * 0.77, h * 0.32),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.dash != dash || old.color != color;
}

/// A radio button: a 24 circle. Unselected it is white with a 2 ink outline;
/// selected it fills yellow with a 2.5 outline and a 10 ink dot. One of a
/// group: every radio in the group shares [groupValue]. Usually use
/// [PopRadioRow].
class PopRadio<T> extends StatelessWidget {
  const PopRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.semanticLabel,
  });

  final T value;
  final T? groupValue;

  /// Null disables it.
  final ValueChanged<T>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final selected = value == groupValue;
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: enabled ? () => onChanged!(value) : null,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(value) : null,
        child: SizedBox.square(
          dimension: PopSize.tapTarget,
          child: Center(child: PopRadioMark(selected: selected, enabled: enabled)),
        ),
      ),
    );
  }
}

/// The radio drawing on its own (no tap handling).
class PopRadioMark extends StatelessWidget {
  const PopRadioMark({super.key, required this.selected, this.enabled = true});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final fill = !enabled ? (selected ? PopColors.divider : PopColors.paper) : (selected ? PopColors.yellow : PopColors.white);
    return AnimatedContainer(
      duration: PopMotion.toggle,
      curve: Curves.easeOut,
      width: PopSize.checkbox,
      height: PopSize.checkbox,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: popOutline(selected ? PopBorder.regular : PopBorder.thin),
      ),
      child: selected
          ? Container(
              width: PopSize.radioDot,
              height: PopSize.radioDot,
              decoration: BoxDecoration(color: enabled ? PopColors.ink : PopColors.inkMuted, shape: BoxShape.circle),
            )
          : null,
    );
  }
}

/// A tappable row with a checkbox, a 16/700 label and an optional caption.
/// The whole row toggles. Sits on its own or inside a [StickerList].
class PopCheckboxRow extends StatelessWidget {
  const PopCheckboxRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.caption,
    this.tristate = false,
  });

  final String label;
  final String? caption;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Semantics(
      checked: value ?? false,
      mixed: tristate && value == null,
      enabled: enabled,
      label: caption == null ? label : '$label, $caption',
      onTap: enabled ? () => onChanged!(value != true) : null,
      excludeSemantics: true,
      child: _ChoiceRow(
        onTap: enabled ? () => onChanged!(value != true) : null,
        control: PopCheckboxMark(value: value, enabled: enabled),
        label: label,
        caption: caption,
        enabled: enabled,
      ),
    );
  }
}

/// A tappable row with a radio, a 16/700 label and an optional caption.
class PopRadioRow<T> extends StatelessWidget {
  const PopRadioRow({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.caption,
  });

  final String label;
  final String? caption;
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final selected = value == groupValue;
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      enabled: enabled,
      label: caption == null ? label : '$label, $caption',
      onTap: enabled ? () => onChanged!(value) : null,
      excludeSemantics: true,
      child: _ChoiceRow(
        onTap: enabled ? () => onChanged!(value) : null,
        control: PopRadioMark(selected: selected, enabled: enabled),
        label: label,
        caption: caption,
        enabled: enabled,
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.onTap, required this.control, required this.label, required this.caption, required this.enabled});

  final VoidCallback? onTap;
  final Widget control;
  final String label;
  final String? caption;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: PopSize.rowMin),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PopSpace.lg, vertical: 10),
          child: Row(
            children: <Widget>[
              control,
              const SizedBox(width: PopSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    PopText(label, spec: PopTextSpecs.input, color: enabled ? PopColors.ink : PopColors.inkMuted),
                    if (caption != null) PopText(caption!, spec: PopTextSpecs.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
