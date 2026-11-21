import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

/// A selectable pill. Selected pills get a bright fill, a thicker outline,
/// a small hard shadow and bolder text, so selection never relies on colour
/// alone.
class PopChip extends StatelessWidget {
  const PopChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = PopColors.yellow,
    this.icon,
    this.onRemove,
  });

  final String label;
  final bool selected;

  /// Null disables the chip.
  final VoidCallback? onTap;

  /// The fill when selected.
  final Color color;

  /// Optional 16 leading icon.
  final IconData? icon;

  /// Shows a trailing × that calls this, for removable chips.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = enabled ? PopColors.ink : PopColors.inkMuted;
    final spec = selected ? PopTextSpecs.chipSelected : PopTextSpecs.chip;
    final outline = selected ? PopBorder.regular : PopBorder.thin;
    final extra = PopBorder.regular - outline;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // Same size selected or not, so neighbours never move: padding makes
        // up for the thinner rest outline, and the label reserves the width
        // of its bold (selected) form.
        child: Container(
          constraints: const BoxConstraints(minHeight: PopSize.chip),
          padding: EdgeInsets.fromLTRB(
            14 + extra,
            6 + extra,
            (onRemove == null ? 14 : 6) + extra,
            6 + extra,
          ),
          decoration: BoxDecoration(
            color: !enabled
                ? PopColors.paper
                : selected
                ? color
                : PopColors.white,
            borderRadius: BorderRadius.circular(PopRadius.pill),
            border: popOutline(outline),
            boxShadow: selected && enabled
                ? popHardShadow(PopShadow.chip)
                : const <BoxShadow>[],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: PopSize.iconChip, color: fg),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    ExcludeSemantics(
                      child: Opacity(
                        opacity: 0,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: popTextOf(PopTextSpecs.chipSelected),
                        ),
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: popTextOf(spec, color: fg),
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                Semantics(
                  container: true,
                  button: true,
                  label: 'Remove $label',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: onRemove,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(PopSpace.xs),
                      child: Icon(
                        Icons.close_rounded,
                        size: PopSize.iconChip,
                        color: fg,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of equal segments with one selected: Expense | Income | Transfer.
class PopSegmented<T> extends StatelessWidget {
  const PopSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.colorOf,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;

  /// Null disables the control.
  final ValueChanged<T>? onChanged;

  /// The fill of the selected segment; pink by default.
  final Color Function(T)? colorOf;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled ? PopColors.white : PopColors.paper,
        borderRadius: BorderRadius.circular(PopRadius.tile),
        border: popOutline(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PopRadius.tile - PopBorder.regular),
        child: Row(
          children: <Widget>[
            for (final (index, value) in values.indexed)
              Expanded(
                child: Semantics(
                  button: true,
                  enabled: enabled,
                  selected: value == selected,
                  child: GestureDetector(
                    key: Key('segment-${labelOf(value).toLowerCase()}'),
                    onTap: enabled ? () => onChanged!(value) : null,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: PopSize.segment,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PopSpace.xs,
                      ),
                      decoration: BoxDecoration(
                        color: value == selected && enabled
                            ? (colorOf?.call(value) ?? PopColors.pink)
                            : null,
                        border: index == 0
                            ? null
                            : const Border(
                                left: BorderSide(
                                  color: PopColors.ink,
                                  width: PopBorder.regular,
                                ),
                              ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          labelOf(value),
                          maxLines: 1,
                          style: popTextOf(
                            value == selected
                                ? PopTextSpecs.segmentSelected
                                : PopTextSpecs.segment,
                            color: enabled ? PopColors.ink : PopColors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A sticker on/off switch: white off, mint on, knob slides in 150 ms.
class PopSwitch extends StatelessWidget {
  const PopSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  /// Read by screen readers along with the on/off state.
  final String label;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final track = !enabled
        ? PopColors.paper
        : value
        ? PopColors.mint
        : PopColors.white;
    return Semantics(
      toggled: value,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          // Pads the 52×30 track out to a 48-high tap target.
          height: PopSize.tapTarget,
          // widthFactor 1: the switch is only as wide as its track, so a
          // parent can align it (e.g. to the right of a row).
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: PopMotion.toggle,
              curve: Curves.easeOut,
              width: PopSize.switchWidth,
              height: PopSize.switchHeight,
              padding: const EdgeInsets.all(2),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(PopRadius.switchTrack),
                border: popOutline(),
              ),
              child: Container(
                width: PopSize.switchKnob,
                height: PopSize.switchKnob,
                decoration: BoxDecoration(
                  color: enabled ? PopColors.white : PopColors.divider,
                  shape: BoxShape.circle,
                  border: popOutline(PopBorder.thin),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
