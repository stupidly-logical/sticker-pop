import 'package:flutter/widgets.dart';

import '../tokens/pop_tokens.g.dart';

/// The package that bundles Bricolage Grotesque. Text styles reference the
/// font through it, so apps don't have to declare the font themselves.
const String popFontPackage = 'sticker_pop';

/// The font family name as [ThemeData.fontFamily] expects it for a font
/// bundled in a package.
const String popFontFamilyQualified = 'packages/$popFontPackage/${PopType.family}';

/// A text style in the Sticker Pop typeface.
///
/// Bricolage Grotesque ships as one variable font, so the weight is applied
/// both as [FontWeight] and as the `wght` axis. Weights below 600 are not
/// part of the system and are raised to 600.
TextStyle popText(
  double size, {
  FontWeight weight = FontWeight.w600,
  Color color = PopColors.ink,
  double? height,
  double letterSpacing = 0,
  bool tabular = false,
}) {
  final safeWeight = weight.value < 600 ? FontWeight.w600 : weight;
  return TextStyle(
    fontFamily: PopType.family,
    package: popFontPackage,
    fontSize: size,
    fontWeight: safeWeight,
    fontVariations: <FontVariation>[
      FontVariation('wght', safeWeight.value.toDouble()),
    ],
    fontFeatures: tabular
        ? const <FontFeature>[FontFeature.tabularFigures()]
        : null,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// The [TextStyle] for one role of the type scale, e.g.
/// `popTextOf(PopTextSpecs.rowTitle)`.
///
/// [PopTextSpec.caps] is not a style property: use [PopText] or
/// [popCaps] to upper-case the string.
TextStyle popTextOf(PopTextSpec spec, {Color? color}) => popText(
  spec.size,
  weight: spec.weight,
  color: color ?? spec.color,
  height: spec.height,
  letterSpacing: spec.letterSpacing,
  tabular: spec.tabular,
);

/// Upper-cases [text] when [spec] is an ALL CAPS role.
String popCaps(PopTextSpec spec, String text) =>
    spec.caps ? text.toUpperCase() : text;

/// A [Text] set in one role of the type scale, applying caps when the role
/// asks for them.
class PopText extends StatelessWidget {
  const PopText(
    this.text, {
    super.key,
    required this.spec,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.semanticsLabel,
  });

  final String text;
  final PopTextSpec spec;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      popCaps(spec, text),
      style: popTextOf(spec, color: color),
      maxLines: spec.tabular ? 1 : maxLines,
      softWrap: !spec.tabular,
      overflow: overflow,
      textAlign: textAlign,
      // Screen readers read the sentence-case original, not shouted caps.
      semanticsLabel: semanticsLabel ?? (spec.caps ? text : null),
    );
    // Amounts (the tabular roles) never wrap: they shrink to fit instead.
    if (!spec.tabular) return label;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: textAlign == TextAlign.end ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: label,
    );
  }
}
