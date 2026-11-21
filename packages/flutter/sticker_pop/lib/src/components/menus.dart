import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'badges_and_lists.dart';
import 'inputs.dart';
import 'overlays.dart';

// ---------------------------------------------------------------------------
// Select

/// One choice in a [PopSelect].
@immutable
class PopSelectOption<T> {
  const PopSelectOption({required this.value, required this.label, this.icon, this.caption});

  final T value;
  final String label;

  /// Optional 22 icon before the label, in the list and in the field.
  final IconData? icon;

  /// Optional muted second line in the list.
  final String? caption;
}

/// A dropdown: a field (white, 2 ink outline, radius 14) showing the chosen
/// option and a chevron. Tapping it opens a bottom sheet listing the options;
/// the chosen row is yellow with a tick. For two to five short options a
/// [PopSegmented] or chips are usually better.
class PopSelect<T> extends StatefulWidget {
  const PopSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Choose',
    this.sheetTitle,
    this.errorText,
  });

  final List<PopSelectOption<T>> options;

  /// The chosen value, or null to show [hint].
  final T? value;

  /// Null disables the field.
  final ValueChanged<T>? onChanged;
  final String? label;
  final String hint;

  /// The sheet's title; defaults to [label], then [hint].
  final String? sheetTitle;
  final String? errorText;

  @override
  State<PopSelect<T>> createState() => _PopSelectState<T>();
}

class _PopSelectState<T> extends State<PopSelect<T>> {
  bool _open = false;
  bool _focused = false;

  PopSelectOption<T>? get _selected {
    for (final o in widget.options) {
      if (o.value == widget.value) return o;
    }
    return null;
  }

  Future<void> _pick() async {
    if (widget.onChanged == null || _open) return;
    setState(() => _open = true);
    final picked = await showPopSelectSheet<T>(
      context: context,
      title: widget.sheetTitle ?? widget.label ?? widget.hint,
      options: widget.options,
      selected: widget.value,
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (picked != null) widget.onChanged!(picked.value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    final selected = _selected;
    final strong = widget.errorText != null || _open || _focused;
    final field = Container(
      constraints: const BoxConstraints(minHeight: PopSize.tapTarget),
      padding: const EdgeInsets.symmetric(horizontal: PopSpace.md, vertical: 10),
      decoration: BoxDecoration(
        color: enabled ? PopColors.white : PopColors.paper,
        borderRadius: BorderRadius.circular(PopRadius.field),
        border: popOutline(strong ? PopBorder.regular : PopBorder.thin),
      ),
      child: Row(
        children: <Widget>[
          if (selected?.icon != null) ...<Widget>[
            Icon(selected!.icon, size: PopSize.iconNav, color: enabled ? PopColors.ink : PopColors.inkMuted),
            const SizedBox(width: PopSpace.sm),
          ],
          Expanded(
            child: selected == null
                ? PopText(widget.hint, spec: PopTextSpecs.inputHint, maxLines: 1, overflow: TextOverflow.ellipsis)
                : PopText(
                    selected.label,
                    spec: PopTextSpecs.input,
                    color: enabled ? PopColors.ink : PopColors.inkMuted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          const SizedBox(width: PopSpace.sm),
          Icon(Icons.expand_more_rounded, size: PopSize.iconNav, color: enabled ? PopColors.ink : PopColors.inkMuted),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          PopText(widget.label!, spec: PopTextSpecs.fieldLabel),
          const SizedBox(height: 6),
        ],
        Semantics(
          button: true,
          enabled: enabled,
          label: widget.label ?? widget.hint,
          value: selected?.label,
          hint: 'Opens a list',
          onTap: enabled ? _pick : null,
          excludeSemantics: true,
          child: FocusableActionDetector(
            enabled: enabled,
            mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
            onShowFocusHighlight: (v) => setState(() => _focused = v),
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _pick()),
            },
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: enabled ? _pick : null, child: field),
          ),
        ),
        if (widget.errorText != null) ...<Widget>[
          const SizedBox(height: 6),
          PopFormError(widget.errorText!),
        ],
      ],
    );
  }
}

/// Opens the [PopSelect] sheet on its own: a titled bottom sheet with the
/// options in a sticker list. Returns the option tapped, or null if dismissed.
Future<PopSelectOption<T>?> showPopSelectSheet<T>({
  required BuildContext context,
  required String title,
  required List<PopSelectOption<T>> options,
  T? selected,
}) {
  return showPopSheet<PopSelectOption<T>>(
    context: context,
    builder: (sheetContext) => PopSheet(
      title: title,
      children: <Widget>[
        StickerList(
          children: <Widget>[
            for (final o in options)
              PopOptionRow(
                label: o.label,
                caption: o.caption,
                icon: o.icon,
                selected: o.value == selected,
                onTap: () => Navigator.of(sheetContext).pop(o),
              ),
          ],
        ),
      ],
    ),
  );
}

/// A row in a select list: optional icon, a 16 label (800 when chosen), an
/// optional caption and a tick. The chosen row fills yellow to the edges.
class PopOptionRow extends StatelessWidget {
  const PopOptionRow({
    super.key,
    required this.label,
    required this.onTap,
    this.caption,
    this.icon,
    this.selected = false,
  });

  final String label;
  final String? caption;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: caption == null ? label : '$label, $caption',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: PopColors.paper,
          focusColor: PopColors.paper,
          child: Container(
            constraints: const BoxConstraints(minHeight: PopSize.rowMin),
            color: selected ? PopColors.yellow : null,
            padding: const EdgeInsets.symmetric(horizontal: PopSpace.lg, vertical: 10),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: PopSize.iconNav, color: PopColors.ink),
                  const SizedBox(width: PopSpace.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      PopText(label, spec: selected ? PopTextSpecs.rowTitle : PopTextSpecs.input),
                      if (caption != null) PopText(caption!, spec: PopTextSpecs.caption),
                    ],
                  ),
                ),
                if (selected) ...<Widget>[
                  const SizedBox(width: PopSpace.sm),
                  const Icon(Icons.check_rounded, size: PopSize.iconNav, color: PopColors.ink),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu

/// An entry in a [PopMenu]: a [PopMenuItem] or a [PopMenuDivider].
sealed class PopMenuEntry {
  const PopMenuEntry();
}

/// One action in a [PopMenu]. [destructive] actions (Delete) are 800 and go
/// last, after a divider; they stay ink, never red.
class PopMenuItem extends PopMenuEntry {
  const PopMenuItem({required this.label, required this.onTap, this.icon, this.destructive = false, this.enabled = true});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool destructive;
  final bool enabled;
}

/// A 2 divider line between groups of menu items.
class PopMenuDivider extends PopMenuEntry {
  const PopMenuDivider();
}

/// A small popover of actions anchored to its trigger (usually a
/// [PopIconButton] with a "more" icon). A white sticker, radius 16, 4/4
/// shadow; rows are 48 high and turn yellow when hovered, focused or pressed.
/// It opens below the trigger, lined up with its trailing edge, and flips
/// above when there is no room. Escape, a tap outside or picking an item
/// closes it.
class PopMenu extends StatefulWidget {
  const PopMenu({super.key, required this.items, required this.builder});

  final List<PopMenuEntry> items;

  /// Builds the trigger. Call `toggle` from its onTap.
  final Widget Function(BuildContext context, VoidCallback toggle, bool isOpen) builder;

  @override
  State<PopMenu> createState() => _PopMenuState();
}

class _PopMenuState extends State<PopMenu> with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _anchor = GlobalKey();
  late final AnimationController _anim = AnimationController(vsync: this, duration: PopMotion.fade);

  bool get _open => _portal.isShowing;

  void _show() {
    _portal.show();
    _anim.forward(from: 0);
    setState(() {});
  }

  Future<void> _hide() async {
    if (!_open) return;
    await _anim.reverse();
    if (!mounted) return;
    _portal.hide();
    setState(() {});
  }

  void _toggle() => _open ? _hide() : _show();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (overlayContext) {
        final anchorBox = _anchor.currentContext?.findRenderObject() as RenderBox?;
        final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox?;
        if (anchorBox == null || overlayBox == null) return const SizedBox.shrink();
        final rect = anchorBox.localToGlobal(Offset.zero, ancestor: overlayBox) & anchorBox.size;
        final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
        final curved = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _hide),
            ),
            Positioned.fill(
              child: CustomSingleChildLayout(
                delegate: _PopMenuLayout(anchor: rect, padding: MediaQuery.paddingOf(context)),
                child: FadeTransition(
                  opacity: curved,
                  child: ScaleTransition(
                    scale: reduce ? const AlwaysStoppedAnimation<double>(1) : Tween<double>(begin: 0.96, end: 1).animate(curved),
                    alignment: Alignment.topRight,
                    child: PopMenuPanel(
                      items: widget.items,
                      onClose: _hide,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: KeyedSubtree(key: _anchor, child: widget.builder(context, _toggle, _open)),
    );
  }
}

class _PopMenuLayout extends SingleChildLayoutDelegate {
  _PopMenuLayout({required this.anchor, required this.padding});

  final Rect anchor;
  final EdgeInsets padding;
  static const double _edge = PopSpace.sm;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxW = math.min(PopSize.menuMaxWidth, constraints.maxWidth - 2 * _edge);
    final maxH = math.min(
      PopSize.menuMaxHeight,
      constraints.maxHeight - padding.vertical - 2 * _edge,
    );
    return BoxConstraints(minWidth: math.min(PopSize.menuMinWidth, maxW), maxWidth: maxW, maxHeight: maxH);
  }

  @override
  Offset getPositionForChild(Size size, Size child) {
    final x = (anchor.right - child.width).clamp(_edge, math.max(_edge, size.width - child.width - _edge));
    final below = anchor.bottom + _edge;
    final fitsBelow = below + child.height <= size.height - padding.bottom - _edge;
    final y = fitsBelow ? below : math.max(padding.top + _edge, anchor.top - _edge - child.height);
    return Offset(x.toDouble(), y);
  }

  @override
  bool shouldRelayout(_PopMenuLayout old) => old.anchor != anchor || old.padding != padding;
}

/// The menu's sticker panel on its own, for custom anchoring or tests.
class PopMenuPanel extends StatelessWidget {
  const PopMenuPanel({super.key, required this.items, required this.onClose});

  final List<PopMenuEntry> items;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final firstEnabled = items.indexWhere((e) => e is PopMenuItem && e.enabled);
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{const SingleActivator(LogicalKeyboardKey.escape): onClose},
      child: FocusScope(
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          child: Container(
            decoration: BoxDecoration(
              color: PopColors.white,
              borderRadius: BorderRadius.circular(PopRadius.menu),
              border: popOutline(),
              boxShadow: popHardShadow(PopShadow.regular),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PopRadius.menu - PopBorder.regular),
              child: IntrinsicWidth(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (final (i, e) in items.indexed)
                        switch (e) {
                          PopMenuDivider() => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: SizedBox(height: PopBorder.divider, child: ColoredBox(color: PopColors.divider)),
                          ),
                          final PopMenuItem item => _PopMenuRow(
                            item: item,
                            autofocus: i == firstEnabled,
                            onDone: onClose,
                          ),
                        },
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopMenuRow extends StatefulWidget {
  const _PopMenuRow({required this.item, required this.autofocus, required this.onDone});

  final PopMenuItem item;
  final bool autofocus;
  final VoidCallback onDone;

  @override
  State<_PopMenuRow> createState() => _PopMenuRowState();
}

class _PopMenuRowState extends State<_PopMenuRow> {
  bool _hover = false;
  bool _focus = false;
  bool _pressed = false;

  void _activate() {
    if (!widget.item.enabled) return;
    widget.onDone();
    widget.item.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final lit = item.enabled && (_hover || _focus || _pressed);
    final color = item.enabled ? PopColors.ink : PopColors.inkMuted;
    return Semantics(
      button: true,
      enabled: item.enabled,
      label: item.label,
      onTap: item.enabled ? _activate : null,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: item.enabled,
        autofocus: widget.autofocus,
        mouseCursor: item.enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate()),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: _activate,
          child: Container(
            constraints: const BoxConstraints(minHeight: PopSize.tapTarget),
            color: lit ? PopColors.yellow : null,
            padding: const EdgeInsets.symmetric(horizontal: PopSpace.lg, vertical: 10),
            child: Row(
              children: <Widget>[
                if (item.icon != null) ...<Widget>[
                  Icon(item.icon, size: PopSize.iconNav, color: color),
                  const SizedBox(width: PopSpace.md),
                ],
                Flexible(
                  child: PopText(
                    item.label,
                    spec: item.destructive ? PopTextSpecs.tileLabel : PopTextSpecs.menuItem,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
