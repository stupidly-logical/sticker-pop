import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'buttons.dart';

const double _kPage = 40;
const double _kGap = PopSpace.xs;

/// The page slots to show for [page] of [count] (both from 1): every page
/// when there are 7 or fewer, otherwise always 7 slots with null for "…",
/// e.g. 1 … 4 5 6 … 12. The same rule runs on every platform.
List<int?> popPageItems(int page, int count) {
  if (count <= 7) return <int?>[for (var i = 1; i <= count; i++) i];
  if (page <= 4) return <int?>[1, 2, 3, 4, 5, null, count];
  if (page >= count - 3) return <int?>[1, null, for (var i = count - 4; i <= count; i++) i];
  return <int?>[1, null, page - 1, page, page + 1, null, count];
}

/// Moves through pages of a long list: previous and next sticker icon
/// buttons around the page numbers (40, radius 12; the current page is
/// yellow with a 2.5 outline). Where the full row doesn't fit (under 404,
/// so on most phones) it shows "Page 3 of 12" between the arrows instead.
class PopPagination extends StatelessWidget {
  const PopPagination({super.key, required this.page, required this.count, required this.onChanged});

  /// The current page, from 1.
  final int page;
  final int count;
  final ValueChanged<int> onChanged;

  static const double wideWidth = PopSize.iconButton * 2 + _kPage * 7 + _kGap * 8;

  @override
  Widget build(BuildContext context) {
    final prev = PopIconButton(
      icon: Icons.chevron_left_rounded,
      label: 'Previous page',
      onTap: page > 1 ? () => onChanged(page - 1) : null,
    );
    final next = PopIconButton(
      icon: Icons.chevron_right_rounded,
      label: 'Next page',
      onTap: page < count ? () => onChanged(page + 1) : null,
    );
    return Semantics(
      container: true,
      label: 'Pages',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= wideWidth && MediaQuery.textScalerOf(context).scale(1) <= 1.3;
          if (!wide) {
            return Row(
              children: <Widget>[
                prev,
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: PopText('Page $page of $count', spec: PopTextSpecs.rowTitle, textAlign: TextAlign.center),
                  ),
                ),
                next,
              ],
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              prev,
              const SizedBox(width: _kGap),
              for (final p in popPageItems(page, count)) ...<Widget>[
                if (p == null)
                  const SizedBox(width: _kPage, child: ExcludeSemantics(child: PopText('…', spec: PopTextSpecs.segment, textAlign: TextAlign.center)))
                else
                  _PageButton(page: p, count: count, current: p == page, onTap: () => onChanged(p)),
                const SizedBox(width: _kGap),
              ],
              next,
            ],
          );
        },
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.page, required this.count, required this.current, required this.onTap});

  final int page;
  final int count;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: current,
      label: 'Page $page of $count',
      onTap: current ? null : onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: current ? null : onTap,
        child: AnimatedContainer(
          duration: PopMotion.toggle,
          width: _kPage,
          height: _kPage,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: current ? PopColors.yellow : null,
            borderRadius: BorderRadius.circular(12),
            border: current ? popOutline() : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: PopText('$page', spec: current ? PopTextSpecs.segmentSelected : PopTextSpecs.segment),
          ),
        ),
      ),
    );
  }
}
