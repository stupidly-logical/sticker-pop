import 'package:material_ui/material_ui.dart';

import '../tokens/pop_tokens.g.dart';
import 'pop_text.dart';

/// The app-wide theme: paper background, ink text, no ripples.
///
/// Sticker Pop components draw themselves from tokens, so the theme only
/// sets what Material widgets fall back to (text, app bar, selection,
/// progress indicators).
ThemeData buildPopTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: PopColors.pink,
    primary: PopColors.ink,
    onPrimary: PopColors.white,
    secondary: PopColors.pink,
    onSecondary: PopColors.ink,
    tertiary: PopColors.yellow,
    onTertiary: PopColors.ink,
    error: PopColors.ink,
    onError: PopColors.white,
    surface: PopColors.paper,
    onSurface: PopColors.ink,
    onSurfaceVariant: PopColors.inkMuted,
    outline: PopColors.ink,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: popFontFamilyQualified,
  );

  return base.copyWith(
    scaffoldBackgroundColor: PopColors.paper,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    textTheme: base.textTheme.apply(
      fontFamily: popFontFamilyQualified,
      bodyColor: PopColors.ink,
      displayColor: PopColors.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: PopColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: popTextOf(PopTextSpecs.sheetTitle),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: PopColors.ink,
      selectionColor: PopColors.yellow,
      selectionHandleColor: PopColors.ink,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PopColors.ink,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
