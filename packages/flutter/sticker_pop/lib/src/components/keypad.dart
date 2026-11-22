import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

/// Applies one keypad key to an amount being typed: digits, "." and
/// "⌫" (backspace). Keeps one decimal point, at most [decimals] decimal
/// places, no leading zeros ("05" → "5"), and at most [maxDigits] digits
/// before the point.
String applyPopKey(String current, String key, {int decimals = 2, int maxDigits = 9}) {
  if (key == '⌫') return current.isEmpty ? current : current.substring(0, current.length - 1);
  if (key == '.') {
    if (decimals == 0 || current.contains('.')) return current;
    return current.isEmpty ? '0.' : '$current.';
  }
  if (!RegExp(r'^\d$').hasMatch(key)) return current;
  final dot = current.indexOf('.');
  if (dot >= 0 && current.length - dot - 1 >= decimals) return current;
  if (dot < 0 && current.replaceFirst(RegExp(r'^0'), '').length >= maxDigits) return current;
  if (current == '0') return key;
  return '$current$key';
}

/// A number keypad for entering amounts, shown under a [PopAmountField] in
/// place of the system keyboard: a 3 × 4 grid of white sticker keys (1–9,
/// ".", 0, backspace) with 26/800 digits, each 56 high with a 3/3 shadow
/// that presses in. Combine with [applyPopKey]. A hardware keyboard works
/// too while it has focus.
class PopKeypad extends StatelessWidget {
  const PopKeypad({super.key, required this.onKey, this.decimal = true});

  /// Called with "0"–"9", "." or "⌫".
  final ValueChanged<String> onKey;

  /// Shows the "." key.
  final bool decimal;

  static const List<String> _keys = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, e) {
        if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
        final c = e.character;
        if (e.logicalKey == LogicalKeyboardKey.backspace) {
          onKey('⌫');
          return KeyEventResult.handled;
        }
        if (c != null && (RegExp(r'^\d$').hasMatch(c) || (decimal && c == '.'))) {
          onKey(c);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: LayoutBuilder(
        builder: (context, c) {
          const gap = PopSpace.sm;
          final w = (c.maxWidth - 2 * gap - PopShadow.small.dx) / 3;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: <Widget>[
              for (final k in _keys)
                SizedBox(
                  width: w,
                  child: k == '.' && !decimal ? const SizedBox(height: PopSize.keypadKey) : _Key(label: k, onTap: () => onKey(k)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final back = label == '⌫';
    return PopPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      shadow: PopShadow.small,
      semanticLabel: back ? 'Delete' : label == '.' ? 'Decimal point' : label,
      excludeSemantics: true,
      builder: (context, offset, pressed) => Container(
        height: PopSize.keypadKey,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pressed ? PopColors.paper : PopColors.white,
          borderRadius: BorderRadius.circular(PopRadius.tile),
          border: popOutline(PopBorder.thin),
          boxShadow: popHardShadow(offset),
        ),
        child: back
            ? const Icon(Icons.backspace_outlined, size: PopSize.iconTile, color: PopColors.ink)
            : PopText(label, spec: PopTextSpecs.keypadKey),
      ),
    );
  }
}
