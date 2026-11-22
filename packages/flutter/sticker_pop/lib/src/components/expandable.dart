import 'package:material_ui/material_ui.dart';

import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'sticker_card.dart';

/// A card that opens to show more: a header row (16/800 title, optional
/// subtitle, a chevron that flips) and a body that slides open. For FAQs,
/// breakdowns and details that most people won't need. Stack several with
/// 12 between them.
class PopExpandable extends StatefulWidget {
  const PopExpandable({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.initiallyExpanded = false,
    this.onChanged,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onChanged;

  @override
  State<PopExpandable> createState() => _PopExpandableState();
}

class _PopExpandableState extends State<PopExpandable> {
  late bool _open = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _open = !_open);
    widget.onChanged?.call(_open);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = reduce ? Duration.zero : PopMotion.sheet;
    return StickerCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            button: true,
            expanded: _open,
            label: widget.subtitle == null ? widget.title : '${widget.title}, ${widget.subtitle}',
            onTap: _toggle,
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: PopSize.rowMin),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(PopSpace.lg, 10, PopSpace.md, 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            PopText(widget.title, spec: PopTextSpecs.rowTitle),
                            if (widget.subtitle != null) PopText(widget.subtitle!, spec: PopTextSpecs.caption),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: duration,
                        child: const Icon(Icons.expand_more_rounded, size: 26, color: PopColors.ink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              heightFactor: _open ? 1 : 0,
              duration: duration,
              curve: Curves.easeOut,
              child: ExcludeSemantics(
                excluding: !_open,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: PopBorder.divider, child: ColoredBox(color: PopColors.divider)),
                    Padding(padding: const EdgeInsets.all(PopSpace.lg), child: widget.child),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
