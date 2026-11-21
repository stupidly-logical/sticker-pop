// Layout QA: renders every sample screen at small-phone, phone and tablet
// sizes, at 100%, 130% and 200% text, and fails on any layout overflow.
// Screenshots go to test/qa/shots/ (git-ignored) when run with
//   flutter test --update-goldens --tags qa test/qa
@Tags(<String>['qa'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sticker_pop/samples.dart';
import 'package:sticker_pop/sticker_pop.dart';

import '../helpers/pop_harness.dart';

const sizes = <String, Size>{
  'small': Size(320, 640),
  'phone': Size(390, 844),
  'tablet': Size(768, 1024),
};
const scales = <double>[1.0, 1.3, 2.0];

Future<List<String>> pumpAndCollect(
  WidgetTester tester,
  Widget home,
  Size size,
  double scale, {
  Future<void> Function()? then,
}) async {
  final errors = <String>[];
  final old = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.toString();
    final where = RegExp(r'(\w+\.dart:\d+:\d+)').allMatches(text).map((m) => m.group(1)).where((w) => !w!.startsWith('layout_qa')).take(2).join(', ');
    final widget = RegExp(r'The relevant error-causing widget was:\s*\n\s*(\S+)').firstMatch(text)?.group(1) ?? '';
    errors.add('${details.exceptionAsString().split('\n').first} [$widget $where]');
  };
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  try {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildPopTheme(),
        builder: (context, child) => MediaQuery(
          // Reduced motion: pulsing skeletons would never settle.
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
          child: child!,
        ),
        home: home,
      ),
    );
    await tester.pumpAndSettle();
    if (then != null) {
      await then();
      await tester.pumpAndSettle();
    }
  } finally {
    FlutterError.onError = old;
  }
  return errors;
}

final dialogChip = find.byWidgetPredicate((w) => w is PopChip && w.label == 'Dialog');

void main() {
  setUpAll(loadPopFonts);

  final screens = <String, (Widget, Future<void> Function(WidgetTester)?)>{
    'home': (PopHomeSample(now: PopHomeSample.fixedNow), null),
    'home_add_sheet': (
      PopHomeSample(now: PopHomeSample.fixedNow),
      (t) => t.tap(find.bySemanticsLabel('Add transaction')),
    ),
    'gallery': (const PopGallery(), null),
    'gallery_dialog': (
      const PopGallery(),
      (t) async {
        await t.scrollUntilVisible(dialogChip, 300, scrollable: find.byType(Scrollable).first);
        await t.pumpAndSettle();
        await t.tap(dialogChip);
      },
    ),
  };

  for (final MapEntry(key: name, value: (widget, action)) in screens.entries) {
    for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
      for (final scale in scales) {
        final id = '${name}_${sizeName}_${(scale * 100).round()}';
        testWidgets(id, (tester) async {
          final handle = tester.ensureSemantics();
          final full = name == 'gallery' ? Size(size.width, 6000) : size;
          final errors = await pumpAndCollect(
            tester, widget, full, scale,
            then: action == null ? null : () => action(tester),
          );
          await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/$id.png'));
          handle.dispose();
          addTearDown(tester.view.reset);
          expect(errors, isEmpty, reason: '$id: ${errors.join(' | ')}');
        });
      }
    }
  }
}
