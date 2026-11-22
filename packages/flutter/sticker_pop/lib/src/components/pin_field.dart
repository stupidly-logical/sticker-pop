import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'inputs.dart';

/// Shows a PIN or one-time code being typed: a row of [length] boxes (48 ×
/// 56, radius 14). Filled boxes show an ink dot ([obscure]) or the digit;
/// the next box to fill has a 2.5 outline. With [error] the boxes turn orange
/// and the message shows below. Feed it from a [PopKeypad] (decimal: false).
class PopPinField extends StatelessWidget {
  const PopPinField({super.key, required this.value, this.length = 4, this.obscure = true, this.error, this.semanticLabel = 'PIN'});

  final String value;
  final int length;
  final bool obscure;
  final String? error;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bad = error != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          label: semanticLabel,
          value: '${value.length} of $length entered',
          liveRegion: true,
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var i = 0; i < length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: PopSpace.sm),
                Flexible(
                  child: AnimatedContainer(
                    duration: PopMotion.toggle,
                    width: 48,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bad ? PopColors.orange : PopColors.white,
                      borderRadius: BorderRadius.circular(PopRadius.field),
                      border: popOutline(!bad && i == value.length ? PopBorder.regular : PopBorder.thin),
                    ),
                    child: i < value.length
                        ? (obscure
                              ? Container(width: 14, height: 14, decoration: const BoxDecoration(color: PopColors.ink, shape: BoxShape.circle))
                              : PopText(value[i], spec: PopTextSpecs.keypadKey))
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (bad) ...<Widget>[const SizedBox(height: PopSpace.md), PopFormError(error!)],
      ],
    );
  }
}
