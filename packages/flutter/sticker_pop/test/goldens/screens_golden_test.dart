import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_pop/samples.dart';

import '../helpers/pop_harness.dart';

/// Golden images of the Home sample and the gallery. Update them with:
///   flutter test --update-goldens test/goldens
///
/// Font rendering differs slightly between macOS and Linux, so goldens are
/// tagged and can be skipped with `--exclude-tags golden`.
void main() {
  setUpAll(loadPopFonts);

  testWidgets('Home sample', (tester) async {
    await pumpPop(tester, PopHomeSample(now: PopHomeSample.fixedNow));
    await tester.pumpAndSettle();
    await expectLater(find.byType(PopHomeSample), matchesGoldenFile('home_sample.png'));
  }, tags: <String>['golden']);

  testWidgets('Gallery', (tester) async {
    await pumpPop(tester, const PopGallery(), size: const Size(390, 5200));
    await tester.pumpAndSettle();
    await expectLater(find.byType(PopGallery), matchesGoldenFile('gallery.png'));
  }, tags: <String>['golden']);
}
