import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_pop/samples.dart';
import 'package:sticker_pop/sticker_pop.dart';

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
    const size = Size(390, 9000);
    await pumpPop(tester, const PopGallery(), size: size, reduceMotion: true);
    await tester.pumpAndSettle();
    // The gallery grows with every component: if the last section no longer
    // fits, raise the height above rather than losing it from the golden.
    expect(tester.getRect(find.byType(PopNavBar).last).bottom, lessThan(size.height - 40), reason: 'gallery taller than the golden');
    await expectLater(find.byType(PopGallery), matchesGoldenFile('gallery.png'));
  }, tags: <String>['golden']);

  // Overlays, open: the menu popover and the select sheet.
  Widget overlayScreen() => Scaffold(
    body: PaperBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(child: PopText('Chai Point', spec: PopTextSpecs.rowTitle)),
                PopMenu(
                  items: <PopMenuEntry>[
                    PopMenuItem(label: 'Edit', icon: Icons.edit_rounded, onTap: () {}),
                    PopMenuItem(label: 'Duplicate', icon: Icons.content_copy_rounded, onTap: () {}),
                    PopMenuItem(label: 'Share', icon: Icons.share_rounded, enabled: false, onTap: () {}),
                    const PopMenuDivider(),
                    PopMenuItem(label: 'Delete', icon: Icons.delete_rounded, destructive: true, onTap: () {}),
                  ],
                  builder: (context, toggle, open) => PopIconButton(icon: Icons.more_horiz_rounded, label: 'More', onTap: toggle),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PopSelect<String>(
              label: 'Account',
              value: 'icici',
              options: const <PopSelectOption<String>>[
                PopSelectOption(value: 'hdfc', label: 'HDFC', icon: Icons.account_balance_rounded, caption: 'Savings ·· 4821'),
                PopSelectOption(value: 'icici', label: 'ICICI', icon: Icons.credit_card_rounded, caption: 'Credit card ·· 4411'),
                PopSelectOption(value: 'sbi', label: 'SBI', icon: Icons.account_balance_rounded),
                PopSelectOption(value: 'cash', label: 'Cash', icon: Icons.payments_rounded),
              ],
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    ),
  );

  testWidgets('Menu open', (tester) async {
    await pumpPop(tester, overlayScreen());
    await tester.tap(find.bySemanticsLabel('More'));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('menu_open.png'));
  }, tags: <String>['golden']);

  testWidgets('Select sheet', (tester) async {
    await pumpPop(tester, overlayScreen());
    await tester.tap(find.byType(PopSelect<String>));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('select_sheet.png'));
  }, tags: <String>['golden']);
}
