import 'package:material_ui/material_ui.dart';

import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'buttons.dart';
import 'sticker_card.dart';

/// What a [PopBanner] is about; sets its fill and default icon.
enum PopBannerTone {
  /// Blue: neutral news ("Prices update every morning").
  info,

  /// Orange: needs attention ("Backup is 30 days old").
  warning,

  /// Mint: something went well ("All caught up").
  success,
}

/// A message that stays in the page until it's dealt with, unlike a
/// snackbar: a bright sticker card with an icon, an optional 16/800 title,
/// a 15/600 message, an optional text-button action and an optional close
/// button. Never red; warnings are orange.
class PopBanner extends StatelessWidget {
  const PopBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = PopBannerTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  final String message;
  final String? title;
  final PopBannerTone tone;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  Color get _fill => switch (tone) {
    PopBannerTone.info => PopColors.blue,
    PopBannerTone.warning => PopColors.orange,
    PopBannerTone.success => PopColors.mint,
  };

  IconData get _icon =>
      icon ??
      switch (tone) {
        PopBannerTone.info => Icons.info_outline_rounded,
        PopBannerTone.warning => Icons.warning_amber_rounded,
        PopBannerTone.success => Icons.check_circle_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      child: StickerCard(
        color: _fill,
        padding: const EdgeInsets.fromLTRB(PopSpace.lg, PopSpace.md, PopSpace.sm, PopSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(top: 2), child: Icon(_icon, size: PopSize.iconNav, color: PopColors.ink)),
            const SizedBox(width: PopSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (title != null) PopText(title!, spec: PopTextSpecs.rowTitle),
                  PopText(message, spec: PopTextSpecs.body),
                  if (actionLabel != null) ...<Widget>[
                    const SizedBox(height: PopSpace.xs),
                    PopTextButton(label: actionLabel!, onPressed: onAction, underline: true),
                  ],
                ],
              ),
            ),
            if (onDismiss != null)
              Semantics(
                button: true,
                label: 'Dismiss',
                onTap: onDismiss,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDismiss,
                  child: const SizedBox.square(dimension: 40, child: Icon(Icons.close_rounded, size: 20, color: PopColors.ink)),
                ),
              )
            else
              const SizedBox(width: PopSpace.sm),
          ],
        ),
      ),
    );
  }
}
