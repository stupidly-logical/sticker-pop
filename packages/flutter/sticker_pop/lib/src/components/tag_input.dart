import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'inputs.dart';
import 'selection.dart';

/// Tags typed into a field: each tag is a removable chip inside a
/// text-field box (white, 2 outline, radius 14), followed by an inline text
/// field. Enter or a comma adds what was typed; backspace in an empty field
/// removes the last tag. Duplicates (ignoring case) are skipped.
class PopTagInput extends StatefulWidget {
  const PopTagInput({super.key, required this.tags, required this.onChanged, this.hint = 'Add a tag', this.label});

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String hint;
  final String? label;

  @override
  State<PopTagInput> createState() => _PopTagInputState();
}

class _PopTagInputState extends State<PopTagInput> {
  final TextEditingController _text = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final t = raw.replaceAll(',', '').trim();
    _text.clear();
    if (t.isEmpty || widget.tags.any((x) => x.toLowerCase() == t.toLowerCase())) return;
    widget.onChanged(<String>[...widget.tags, t]);
  }

  void _remove(String t) => widget.onChanged(<String>[...widget.tags]..remove(t));

  @override
  Widget build(BuildContext context) {
    final box = GestureDetector(
      onTap: _focus.requestFocus,
      child: Container(
        constraints: const BoxConstraints(minHeight: PopSize.tapTarget),
        padding: const EdgeInsets.symmetric(horizontal: PopSpace.sm, vertical: 6),
        decoration: BoxDecoration(
          color: PopColors.white,
          borderRadius: BorderRadius.circular(PopRadius.field),
          border: popOutline(_focus.hasFocus ? PopBorder.regular : PopBorder.thin),
        ),
        child: Wrap(
          spacing: PopSpace.sm,
          runSpacing: PopSpace.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            // A no-op tap keeps the chip ink (a null onTap would mean disabled).
            for (final t in widget.tags) PopChip(label: t, selected: false, onTap: () {}, onRemove: () => _remove(t)),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
              child: IntrinsicWidth(
                child: Focus(
                  onKeyEvent: (node, e) {
                    if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.backspace && _text.text.isEmpty && widget.tags.isNotEmpty) {
                      _remove(widget.tags.last);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: _text,
                    focusNode: _focus,
                    textInputAction: TextInputAction.done,
                    onChanged: (v) {
                      if (v.contains(',')) _add(v);
                    },
                    onSubmitted: (v) {
                      _add(v);
                      _focus.requestFocus();
                    },
                    cursorColor: PopColors.ink,
                    style: popTextOf(PopTextSpecs.input),
                    decoration: popBareInput(hint: widget.tags.isEmpty ? widget.hint : null).copyWith(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[PopText(widget.label!, spec: PopTextSpecs.fieldLabel), const SizedBox(height: 6)],
        box,
      ],
    );
  }
}
