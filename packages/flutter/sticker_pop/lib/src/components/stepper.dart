import 'package:material_ui/material_ui.dart';

import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'buttons.dart';

/// A small counter, like how many people split a bill: − and + sticker
/// buttons with the number between them in 20/800 tabular figures. Each
/// button disables at its limit. Screen readers adjust it as one control.
class PopStepper extends StatelessWidget {
  const PopStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.min = 0,
    this.max = 99,
    this.step = 1,
  });

  final int value;

  /// Null disables it.
  final ValueChanged<int>? onChanged;
  final String semanticLabel;
  final int min;
  final int max;
  final int step;

  @override
  Widget build(BuildContext context) {
    final canDown = onChanged != null && value - step >= min;
    final canUp = onChanged != null && value + step <= max;
    return Semantics(
      label: semanticLabel,
      value: '$value',
      increasedValue: canUp ? '${value + step}' : null,
      decreasedValue: canDown ? '${value - step}' : null,
      onIncrease: canUp ? () => onChanged!(value + step) : null,
      onDecrease: canDown ? () => onChanged!(value - step) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ExcludeSemantics(child: PopIconButton(icon: Icons.remove_rounded, label: 'Less', onTap: canDown ? () => onChanged!(value - step) : null)),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48),
            child: ExcludeSemantics(child: PopText('$value', spec: PopTextSpecs.sectionHeading, textAlign: TextAlign.center)),
          ),
          ExcludeSemantics(child: PopIconButton(icon: Icons.add_rounded, label: 'More', onTap: canUp ? () => onChanged!(value + step) : null)),
        ],
      ),
    );
  }
}
