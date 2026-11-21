import 'package:material_ui/material_ui.dart';

import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'buttons.dart';

/// The bar at the top of a screen.
///
/// Compact (the default) is for sub-screens and works as a
/// `Scaffold.appBar`: a back sticker button when [onBack] is set, a one-line
/// 22/800 title and up to two [actions] (usually [PopIconButton]s), 64 high.
/// [PopTopBar.large] is for main screens and sits at the top of the
/// scrolling content: the 34/800 screen title (up to two lines) with the
/// actions on the right.
///
/// When content scrolls under it, the bar fills with paper and draws a 2.5
/// ink line along its bottom. As an app bar it follows the scaffold's body
/// on its own; pass [scrolled] to decide yourself.
class PopTopBar extends StatefulWidget implements PreferredSizeWidget {
  const PopTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.backLabel = 'Back',
    this.actions = const <Widget>[],
    this.scrolled,
  }) : large = false;

  const PopTopBar.large({
    super.key,
    required this.title,
    this.actions = const <Widget>[],
    this.scrolled = false,
  }) : large = true,
       onBack = null,
       backLabel = 'Back';

  final String title;
  final VoidCallback? onBack;
  final String backLabel;

  /// Up to two trailing controls, usually [PopIconButton]s or a [PopMenu].
  final List<Widget> actions;

  /// Null: follow the nearest scaffold body's scroll position.
  final bool? scrolled;
  final bool large;

  @override
  Size get preferredSize => const Size.fromHeight(PopSize.topBar);

  @override
  State<PopTopBar> createState() => _PopTopBarState();
}

class _PopTopBarState extends State<PopTopBar> {
  ScrollNotificationObserverState? _observer;
  bool _scrolledUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer?.removeListener(_onScroll);
    _observer = widget.scrolled == null ? ScrollNotificationObserver.maybeOf(context) : null;
    _observer?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _observer?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll(ScrollNotification n) {
    if (n is! ScrollUpdateNotification || n.depth != 0 || n.metrics.axis != Axis.vertical) return;
    final under = n.metrics.extentBefore > 0;
    if (under != _scrolledUnder) setState(() => _scrolledUnder = under);
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.actions.length <= 2, 'PopTopBar holds up to two actions; put the rest in a PopMenu');
    final scrolled = widget.scrolled ?? _scrolledUnder;
    final title = Semantics(
      header: true,
      child: PopText(
        widget.title,
        spec: widget.large ? PopTextSpecs.screenTitle : PopTextSpecs.sheetTitle,
        maxLines: widget.large ? 2 : 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final row = Row(
      children: <Widget>[
        if (widget.onBack != null) ...<Widget>[
          PopIconButton(icon: Icons.arrow_back_rounded, label: widget.backLabel, onTap: widget.onBack),
          const SizedBox(width: PopSpace.md),
        ],
        Expanded(child: title),
        for (final (i, a) in widget.actions.indexed) ...<Widget>[
          SizedBox(width: i == 0 ? PopSpace.md : PopSpace.sm),
          a,
        ],
      ],
    );
    return AnimatedContainer(
      duration: PopMotion.fade,
      decoration: BoxDecoration(
        color: scrolled ? PopColors.paper : PopColors.paper.withValues(alpha: 0),
        border: Border(bottom: BorderSide(color: scrolled ? PopColors.ink : PopColors.ink.withValues(alpha: 0), width: PopBorder.regular)),
      ),
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: PopSize.topBar - PopBorder.regular),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: PopSpace.screen, vertical: widget.large ? PopSpace.sm : 0),
            child: Align(alignment: Alignment.centerLeft, heightFactor: 1, child: row),
          ),
        ),
      ),
    );
  }
}
