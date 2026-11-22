import 'package:material_ui/material_ui.dart';

import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

/// A short explanation in an ink bubble (white 13/700 text, radius 10)
/// above [child]: on long-press or tap on phones, on hover or focus with a
/// mouse or keyboard. It hides after 3 s. Keep it to one sentence; anything
/// people need to act on belongs on the screen. Put it around something
/// that isn't itself a button (usually a 22 ⓘ icon in a 48 square), so the
/// tap reaches the tooltip.
class PopTooltip extends StatelessWidget {
  const PopTooltip({super.key, required this.message, required this.child, this.tapToShow = true});

  final String message;
  final Widget child;

  /// Shows on a tap (good for ⓘ buttons); otherwise only on long-press.
  final bool tapToShow;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: tapToShow ? TooltipTriggerMode.tap : TooltipTriggerMode.longPress,
      showDuration: PopMotion.snackbar,
      waitDuration: const Duration(milliseconds: 400),
      preferBelow: false,
      verticalOffset: 28,
      margin: const EdgeInsets.symmetric(horizontal: PopSpace.screen),
      padding: const EdgeInsets.symmetric(horizontal: PopSpace.md, vertical: PopSpace.sm),
      decoration: BoxDecoration(color: PopColors.ink, borderRadius: BorderRadius.circular(PopRadius.badge)),
      textStyle: popText(13, weight: FontWeight.w700, color: PopColors.white),
      child: child,
    );
  }
}
