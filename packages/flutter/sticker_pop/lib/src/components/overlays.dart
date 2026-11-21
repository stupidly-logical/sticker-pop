import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'buttons.dart';
import 'inputs.dart';

/// Opens a Sticker Pop bottom sheet (paper fill, ink top edge, top radius
/// 24, up to 90% of the screen) with the platform slide.
Future<T?> showPopSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    sheetAnimationStyle: const AnimationStyle(
      duration: PopMotion.sheet,
      reverseDuration: PopMotion.sheet,
    ),
    isScrollControlled: true,
    isDismissible: isDismissible,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: PopColors.ink.withValues(alpha: 0.45),
    elevation: 0,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * PopSize.sheetMaxHeightFraction,
    ),
    builder: builder,
  );
}

/// The body of a bottom sheet: title, content, then the inline error and
/// the primary button last.
class PopSheet extends StatelessWidget {
  const PopSheet({
    super.key,
    required this.title,
    required this.children,
    this.primaryLabel,
    this.onPrimary,
    this.error,
    this.leading,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final String? primaryLabel;
  final VoidCallback? onPrimary;

  /// Shown in 14/800 ink directly above the primary button.
  final String? error;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: PopColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(PopRadius.sheet)),
        border: Border(top: BorderSide(color: PopColors.ink, width: PopBorder.regular)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          PopSpace.xl,
          PopSpace.xl,
          PopSpace.xl,
          PopSpace.xxl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (leading != null) ...<Widget>[leading!, const SizedBox(width: PopSpace.md)],
                Expanded(
                  child: Semantics(
                    header: true,
                    child: PopText(title, spec: PopTextSpecs.sheetTitle),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: PopSpace.lg),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: PopSpace.md),
              PopFormError(error!),
            ],
            if (primaryLabel != null) ...<Widget>[
              const SizedBox(height: PopSpace.lg),
              StickerButton(label: primaryLabel!, onPressed: onPrimary),
            ],
          ],
        ),
      ),
    );
  }
}

/// Opens a [PopDialog].
Future<T?> showPopDialog<T>({required BuildContext context, required WidgetBuilder builder}) {
  return showDialog<T>(
    context: context,
    animationStyle: const AnimationStyle(
      duration: PopMotion.fade,
      reverseDuration: PopMotion.fade,
    ),
    barrierColor: PopColors.ink.withValues(alpha: 0.45),
    builder: builder,
  );
}

/// A dialog: a paper sticker with the large shadow, 20 in from the screen
/// edges. Title, body, the primary button, then "Cancel".
class PopDialog extends StatelessWidget {
  const PopDialog({
    super.key,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.cancelLabel = 'Cancel',
    this.onCancel,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String cancelLabel;

  /// Defaults to closing the dialog.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(PopSpace.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PopColors.paper,
          borderRadius: BorderRadius.circular(PopRadius.card),
          border: popOutline(),
          boxShadow: popHardShadow(PopShadow.large),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PopSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Semantics(header: true, child: PopText(title, spec: PopTextSpecs.sheetTitle)),
              const SizedBox(height: PopSpace.sm),
              PopText(body, spec: PopTextSpecs.body),
              const SizedBox(height: PopSpace.xl),
              StickerButton(label: primaryLabel, onPressed: onPrimary),
              const SizedBox(height: PopSpace.sm),
              Center(
                child: PopTextButton(
                  label: cancelLabel,
                  onPressed: onCancel ?? () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a floating ink snackbar for "Saved" or "Deleted · Undo"-style
/// confirmations: 3 s, or 6 s with an action. Never for form errors.
void showPopSnack(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  showPopSnackOn(
    ScaffoldMessenger.of(context),
    message,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

/// Like [showPopSnack], for when the screen that triggered it is closing.
void showPopSnackOn(
  ScaffoldMessengerState messenger,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(popSnackBar(message, actionLabel: actionLabel, onAction: onAction));
}

/// The [SnackBar] used by [showPopSnack].
SnackBar popSnackBar(String message, {String? actionLabel, VoidCallback? onAction}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: PopColors.ink,
    elevation: 0,
    duration: actionLabel == null ? PopMotion.snackbar : PopMotion.snackbarWithAction,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PopRadius.snackbar)),
    content: PopText(message, spec: PopTextSpecs.snackbar),
    action: actionLabel == null
        ? null
        : SnackBarAction(
            label: actionLabel,
            textColor: PopColors.yellow,
            onPressed: onAction ?? () {},
          ),
  );
}
