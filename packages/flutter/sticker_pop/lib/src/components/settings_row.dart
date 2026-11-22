import 'package:material_ui/material_ui.dart';

import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'selection.dart';

/// A row for settings lists, inside a [StickerList]: an optional 22 icon, a
/// 16/700 title with an optional 13/600 subtitle, and on the right either a
/// switch ([switchValue]), or an optional 16/700 muted [value] and a chevron
/// when it opens something ([onTap]). The whole row is the tap target; with a
/// switch, tapping the row flips it.
class PopSettingsRow extends StatelessWidget {
  const PopSettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.value,
    this.onTap,
    this.switchValue,
    this.onSwitch,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// The current setting, shown muted before the chevron ("English").
  final String? value;
  final VoidCallback? onTap;

  /// Non-null shows a switch instead of a chevron.
  final bool? switchValue;
  final ValueChanged<bool>? onSwitch;

  @override
  Widget build(BuildContext context) {
    final hasSwitch = switchValue != null;
    final enabled = hasSwitch ? onSwitch != null : onTap != null;
    final tap = hasSwitch ? (onSwitch == null ? null : () => onSwitch!(!switchValue!)) : onTap;
    final ink = enabled || (!hasSwitch && onTap == null) ? PopColors.ink : PopColors.inkMuted;
    return Semantics(
      button: !hasSwitch && onTap != null,
      toggled: hasSwitch ? switchValue : null,
      enabled: enabled,
      label: <String?>[title, subtitle, value].whereType<String>().join(', '),
      onTap: tap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: PopSize.rowMin),
          child: Padding(
            padding: EdgeInsets.fromLTRB(PopSpace.lg, 8, hasSwitch ? PopSpace.md : PopSpace.sm, 8),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: PopSize.iconNav, color: ink),
                  const SizedBox(width: PopSpace.md),
                ],
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      PopText(title, spec: PopTextSpecs.input, color: ink),
                      if (subtitle != null) PopText(subtitle!, spec: PopTextSpecs.caption),
                    ],
                  ),
                ),
                if (hasSwitch)
                  ExcludeSemantics(child: PopSwitch(value: switchValue!, onChanged: onSwitch, label: title))
                else ...<Widget>[
                  if (value != null) ...<Widget>[
                    const SizedBox(width: PopSpace.sm),
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PopText(value!, spec: PopTextSpecs.input, color: PopColors.inkMuted, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  if (onTap != null) const Icon(Icons.chevron_right_rounded, size: 26, color: PopColors.ink) else const SizedBox(width: PopSpace.sm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
