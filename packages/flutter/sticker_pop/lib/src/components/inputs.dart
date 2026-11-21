import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'sticker_card.dart';

/// A borderless input decoration for use inside [PopTextField],
/// [PopFieldRow] or a hero amount card.
InputDecoration popBareInput({String? hint, double hintSize = 16}) =>
    InputDecoration(
      isDense: true,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      hintText: hint,
      hintStyle: popText(
        hintSize,
        weight: FontWeight.w600,
        color: PopColors.inkMuted,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );

/// A white text field with a thin ink outline.
///
/// States: rest, focused (outline thickens to 2.5), disabled (paper fill,
/// muted text) and error (2.5 outline plus an ink message with a ⚠ glyph;
/// never red alone).
class PopTextField extends StatefulWidget {
  const PopTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.prefix,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? hint;

  /// An optional label above the field, in the field-label style.
  final String? label;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final bool autofocus;

  @override
  State<PopTextField> createState() => _PopTextFieldState();
}

class _PopTextFieldState extends State<PopTextField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final strong = hasError || _focus.hasFocus;
    final field = Container(
      constraints: const BoxConstraints(minHeight: PopSize.tapTarget),
      padding: const EdgeInsets.symmetric(horizontal: PopSpace.md),
      decoration: BoxDecoration(
        color: widget.enabled ? PopColors.white : PopColors.paper,
        borderRadius: BorderRadius.circular(PopRadius.field),
        border: popOutline(strong ? PopBorder.regular : PopBorder.thin),
      ),
      child: Row(
        children: <Widget>[
          if (widget.prefix != null) ...<Widget>[
            widget.prefix!,
            const SizedBox(width: PopSpace.sm),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              inputFormatters: widget.inputFormatters,
              cursorColor: PopColors.ink,
              style: popTextOf(
                PopTextSpecs.input,
                color: widget.enabled ? PopColors.ink : PopColors.inkMuted,
              ),
              decoration: popBareInput(hint: widget.hint),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          PopText(widget.label!, spec: PopTextSpecs.fieldLabel),
          const SizedBox(height: 6),
        ],
        field,
        if (hasError) ...<Widget>[
          const SizedBox(height: 6),
          PopFormError(widget.errorText!),
        ],
      ],
    );
  }
}

/// An inline form error: 14/800 ink with a ⚠ glyph. In sheets it sits
/// directly above the primary button, never in a snackbar.
class PopFormError extends StatelessWidget {
  const PopFormError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: PopColors.ink,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: PopText(message, spec: PopTextSpecs.formError)),
        ],
      ),
    );
  }
}

/// The big amount entry: a bright card with a currency prefix at the same
/// 32/800 size. Pick the card colour by meaning, e.g. yellow for money out,
/// mint for money in.
class PopAmountField extends StatelessWidget {
  const PopAmountField({
    super.key,
    required this.controller,
    this.color = PopColors.yellow,
    this.label = 'Amount',
    this.currencySymbol = '₹',
    this.errorText,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final Color color;

  /// A short caps label above the amount.
  final String label;

  /// Shown before the amount at the same size.
  final String currencySymbol;
  final String? errorText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final style = popTextOf(PopTextSpecs.amountEntry);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StickerCard(
          color: color,
          padding: const EdgeInsets.fromLTRB(
            PopSpace.lg,
            PopSpace.md,
            PopSpace.lg,
            PopSpace.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PopText(label, spec: PopTextSpecs.sectionLabel),
              Row(
                children: <Widget>[
                  Text(currencySymbol, style: style),
                  const SizedBox(width: PopSpace.xs),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: autofocus,
                      onChanged: onChanged,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      cursorColor: PopColors.ink,
                      style: style,
                      decoration: popBareInput(hint: '0', hintSize: 32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: PopSpace.sm),
          PopFormError(errorText!),
        ],
      ],
    );
  }
}

/// One labelled line inside a details card: "Paid to", "Account", ...
///
/// A 76-wide muted label column, the value on the right, min height 52 and
/// a 2px divider under each row.
class PopFieldRow extends StatelessWidget {
  const PopFieldRow({
    super.key,
    required this.label,
    required this.child,
    this.onTap,
    this.showChevron = false,
    this.divider = true,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: PopSize.rowMin),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: divider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: PopColors.divider,
                  width: PopBorder.divider,
                ),
              ),
            )
          : null,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: PopSize.fieldLabelColumn,
            child: PopText(label, spec: PopTextSpecs.fieldLabel),
          ),
          Expanded(child: child),
          if (showChevron)
            const Icon(
              Icons.chevron_right_rounded,
              size: PopSize.iconNav,
              color: PopColors.ink,
            ),
        ],
      ),
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: row,
      ),
    );
  }
}
