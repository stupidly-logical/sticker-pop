import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'sticker_card.dart';

/// One destination in [PopNavBar].
@immutable
class PopNavItem {
  const PopNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

/// The bottom navigation bar: white, a 2.5 ink line on top, five slots with
/// the tilted pink add button in the middle.
///
/// [items] holds the four destinations (Home, Activity, Insights, Wealth);
/// the add button is inserted between the second and third.
class PopNavBar extends StatelessWidget {
  const PopNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdd,
    this.addLabel = 'Add transaction',
  }) : assert(items.length == 4, 'PopNavBar has four destinations plus Add');

  final List<PopNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback? onAdd;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    Widget item(int i) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _PopNavSlot(
          item: items[i],
          selected: i == selectedIndex,
          onTap: () => onSelected(i),
        ),
      ),
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: PopColors.white,
        border: Border(
          top: BorderSide(color: PopColors.ink, width: PopBorder.regular),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              item(0),
              item(1),
              // The add slot is as wide as the button plus room for its tilt
              // and shadow; the four items share the rest, so on a narrow
              // phone the button never overlaps its neighbours.
              Padding(
                // Extra room on the right for the 4/4 shadow, so button and shadow sit centred.
                padding: EdgeInsets.only(left: PopSpace.sm, right: PopSpace.sm + PopShadow.regular.dx),
                child: PopAddButton(onTap: onAdd, label: addLabel),
              ),
              item(2),
              item(3),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopNavSlot extends StatelessWidget {
  const _PopNavSlot({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PopNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      selected ? (item.selectedIcon ?? item.icon) : item.icon,
      size: PopSize.iconNav,
      color: selected ? PopColors.ink : PopColors.inkMuted,
    );
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.5,
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: PopSize.tapTarget),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: selected
                      ? BoxDecoration(
                          color: PopColors.yellow,
                          borderRadius: BorderRadius.circular(
                            PopRadius.navPill,
                          ),
                          border: popOutline(PopBorder.thin),
                        )
                      : BoxDecoration(
                          // Keeps selected and unselected slots the same size.
                          border: Border.all(
                            color: Colors.transparent,
                            width: PopBorder.thin,
                          ),
                        ),
                  child: icon,
                ),
                const SizedBox(height: 3),
                // Nav labels grow with system text up to 150%, then stop, so
                // five slots still fit on a small phone (as on iOS and Android).
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: PopText(
                    item.label,
                    spec: selected
                        ? PopTextSpecs.navLabelSelected
                        : PopTextSpecs.navLabel,
                    maxLines: 1,
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

/// The centred add button: a pink sticker tilted −6° holding a 28 "+".
class PopAddButton extends StatelessWidget {
  const PopAddButton({
    super.key,
    required this.onTap,
    this.label = 'Add transaction',
  });

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return PopTilted(
      degrees: PopTilt.addButton,
      child: StickerCard(
        color: PopColors.pink,
        radius: PopRadius.addButton,
        padding: const EdgeInsets.all(13),
        onTap: onTap,
        semanticLabel: label,
        child: const Icon(
          Icons.add_rounded,
          size: PopSize.iconAdd,
          color: PopColors.ink,
        ),
      ),
    );
  }
}

/// One tile in [PopQuickAddRow].
@immutable
class PopQuickAddTile {
  const PopQuickAddTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.tiltDegrees,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double tiltDegrees;
  final VoidCallback? onTap;
}

/// Home's quick-add row: Type it (white, −1.5°), Say it (pink, +1.5°) and
/// Scan it (mint, −1°), three equal tiles 12 apart.
class PopQuickAddRow extends StatelessWidget {
  const PopQuickAddRow({super.key, required this.tiles});

  /// The standard three tiles.
  PopQuickAddRow.standard({
    super.key,
    required VoidCallback? onType,
    required VoidCallback? onSay,
    required VoidCallback? onScan,
  }) : tiles = <PopQuickAddTile>[
         PopQuickAddTile(
           label: 'Type it',
           icon: Icons.keyboard_rounded,
           color: PopColors.white,
           tiltDegrees: -1.5,
           onTap: onType,
         ),
         PopQuickAddTile(
           label: 'Say it',
           icon: Icons.mic_rounded,
           color: PopColors.pink,
           tiltDegrees: 1.5,
           onTap: onSay,
         ),
         PopQuickAddTile(
           label: 'Scan it',
           icon: Icons.document_scanner_rounded,
           color: PopColors.mint,
           tiltDegrees: -1,
           onTap: onScan,
         ),
       ];

  final List<PopQuickAddTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final (i, tile) in tiles.indexed) ...<Widget>[
          if (i > 0) const SizedBox(width: PopSpace.md),
          Expanded(
            child: StickerCard(
              color: tile.color,
              tiltDegrees: tile.tiltDegrees,
              padding: const EdgeInsets.symmetric(
                vertical: PopSpace.md,
                horizontal: PopSpace.xs,
              ),
              onTap: tile.onTap,
              semanticLabel: tile.label,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(tile.icon, size: PopSize.iconTile, color: PopColors.ink),
                  const SizedBox(height: PopSpace.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: PopText(
                      tile.label,
                      spec: PopTextSpecs.tileLabel,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
