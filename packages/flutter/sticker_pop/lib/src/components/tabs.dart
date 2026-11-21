import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

/// A row of tabs for switching between views of one screen (e.g. "Spending
/// | Income | Accounts"). Unselected tabs are plain 15/700 muted text; the
/// selected one sits in a yellow pill with a 2 ink outline and 800 text. The
/// row scrolls sideways when the tabs don't fit. Showing the right content is
/// up to you.
class PopTabs extends StatelessWidget {
  const PopTabs({super.key, required this.tabs, required this.selected, required this.onSelected});

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final (i, t) in tabs.indexed) ...<Widget>[
            if (i > 0) const SizedBox(width: PopSpace.xs),
            Semantics(
              button: true,
              selected: i == selected,
              label: '$t, tab ${i + 1} of ${tabs.length}',
              onTap: () => onSelected(i),
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: PopMotion.toggle,
                  constraints: const BoxConstraints(minHeight: PopSize.chip, minWidth: PopSize.tapTarget),
                  padding: const EdgeInsets.symmetric(horizontal: PopSpace.lg),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? PopColors.yellow : PopColors.yellow.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(PopRadius.pill),
                    border: popOutline(PopBorder.thin).scale(i == selected ? 1 : 0),
                  ),
                  child: PopText(
                    t,
                    spec: i == selected ? PopTextSpecs.segmentSelected : PopTextSpecs.segment,
                    color: i == selected ? PopColors.ink : PopColors.inkMuted,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
