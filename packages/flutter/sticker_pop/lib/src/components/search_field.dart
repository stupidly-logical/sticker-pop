import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'buttons.dart';
import 'inputs.dart';

/// A search box: a text field (white, 2 ink outline, radius 14, 48 high)
/// with a search icon, a ✕ that clears it while it has text, and an
/// optional "Cancel" text button after it ([onCancel]).
class PopSearchField extends StatefulWidget {
  const PopSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onCancel,
    this.cancelLabel = 'Cancel',
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Shows a "Cancel" text button; clear the search and leave it here.
  final VoidCallback? onCancel;
  final String cancelLabel;
  final bool autofocus;

  @override
  State<PopSearchField> createState() => _PopSearchFieldState();
}

class _PopSearchFieldState extends State<PopSearchField> {
  late final TextEditingController _own = TextEditingController();
  final FocusNode _focus = FocusNode();
  TextEditingController get _c => widget.controller ?? _own;

  @override
  void initState() {
    super.initState();
    _c.addListener(_rebuild);
    _focus.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _c.removeListener(_rebuild);
    _own.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _clear() {
    _c.clear();
    widget.onChanged?.call('');
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final field = Container(
      constraints: const BoxConstraints(minHeight: PopSize.tapTarget),
      padding: const EdgeInsets.only(left: PopSpace.md, right: PopSpace.xs),
      decoration: BoxDecoration(
        color: PopColors.white,
        borderRadius: BorderRadius.circular(PopRadius.field),
        border: popOutline(_focus.hasFocus ? PopBorder.regular : PopBorder.thin),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search_rounded, size: PopSize.iconNav, color: PopColors.ink),
          const SizedBox(width: PopSpace.sm),
          Expanded(
            child: TextField(
              controller: _c,
              focusNode: _focus,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              cursorColor: PopColors.ink,
              style: popTextOf(PopTextSpecs.input),
              decoration: popBareInput(hint: widget.hint),
            ),
          ),
          if (_c.text.isNotEmpty)
            Semantics(
              button: true,
              label: 'Clear search',
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _clear,
                child: const SizedBox.square(
                  dimension: 40,
                  child: Icon(Icons.cancel_rounded, size: 20, color: PopColors.ink),
                ),
              ),
            )
          else
            const SizedBox(width: PopSpace.sm),
        ],
      ),
    );
    if (widget.onCancel == null) return field;
    return Row(
      children: <Widget>[
        Expanded(child: field),
        const SizedBox(width: PopSpace.md),
        PopTextButton(label: widget.cancelLabel, onPressed: widget.onCancel),
      ],
    );
  }
}
