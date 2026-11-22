import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'buttons.dart';

/// A whole-screen state for when there's nothing to show yet, or something
/// went wrong: a 96 sticker tile with a 44 icon, tilted −4°, then a 22/800
/// title, a short 15/600 message and up to two actions, all centred. Lilac
/// for empty (the default), orange for errors and offline.
class PopEmptyState extends StatelessWidget {
  const PopEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.color = PopColors.lilac,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(PopSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ExcludeSemantics(
                child: PopTilted(
                  degrees: -4,
                  child: Container(
                    width: PopSize.stateTile,
                    height: PopSize.stateTile,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(PopRadius.card),
                      border: popOutline(),
                      boxShadow: popHardShadow(PopShadow.large),
                    ),
                    child: Icon(icon, size: 44, color: PopColors.ink),
                  ),
                ),
              ),
              const SizedBox(height: PopSpace.xxl),
              Semantics(header: true, child: PopText(title, spec: PopTextSpecs.sheetTitle, textAlign: TextAlign.center)),
              const SizedBox(height: PopSpace.sm),
              PopText(message, spec: PopTextSpecs.body, color: PopColors.inkMuted, textAlign: TextAlign.center),
              if (actionLabel != null) ...<Widget>[
                const SizedBox(height: PopSpace.xl),
                StickerButton(label: actionLabel!, onPressed: onAction),
              ],
              if (secondaryLabel != null) ...<Widget>[
                const SizedBox(height: PopSpace.sm),
                PopTextButton(label: secondaryLabel!, onPressed: onSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
