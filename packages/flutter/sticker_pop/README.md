# Sticker Pop for Flutter

A bold, friendly design system: bright paper stickers on cream notebook
paper, with thick ink outlines, hard blur-free shadows and big, bold numbers.
48 components, the same ones as the Compose, SwiftUI and web libraries, all
built from one token file.

**Docs and live examples:** https://stupidly-logical.github.io/sticker-pop/

## Install

```sh
flutter pub add sticker_pop
```

Needs Flutter 3.50 or later. The Bricolage Grotesque font is bundled.

## Use

```dart
import 'package:sticker_pop/sticker_pop.dart';

MaterialApp(
  theme: buildPopTheme(),
  home: Scaffold(
    backgroundColor: PopColors.paper,
    body: StickerCard(
      child: StickerButton(label: 'Save', onPressed: () {}),
    ),
  ),
);
```

Tokens are constants (`PopColors`, `PopSpace`, `PopRadius`, `PopTextSpecs`),
and formatting helpers like `formatInr` and `applyPopKey` give the same
results on every platform. The `example` app is the full component gallery.

## License

MIT. Bricolage Grotesque is under the SIL Open Font License.
