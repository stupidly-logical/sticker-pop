import 'package:material_ui/material_ui.dart';
import 'package:sticker_pop/samples.dart';
import 'package:sticker_pop/sticker_pop.dart';

void main() => runApp(const StickerPopExample());

/// Opens the component gallery; its yellow home button opens the Home
/// sample.
class StickerPopExample extends StatelessWidget {
  const StickerPopExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticker Pop',
      debugShowCheckedModeBanner: false,
      theme: buildPopTheme(),
      home: const PopGallery(),
    );
  }
}
