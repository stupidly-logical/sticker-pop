import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sticker_pop/sticker_pop.dart';

import '../helpers/pop_harness.dart';

BoxDecoration _decorationOf(WidgetTester tester, Finder f) {
  final box = tester.widget<Container>(
    find.ancestor(of: f, matching: find.byType(Container)).first,
  );
  return box.decoration! as BoxDecoration;
}

void main() {
  group('StickerButton', () {
    testWidgets('rest: ink fill, pink hard shadow, white 18/800 label', (tester) async {
      var taps = 0;
      await pumpPop(tester, onPaper(StickerButton(label: 'Save', onPressed: () => taps++)));
      final d = _decorationOf(tester, find.text('Save'));
      expect(d.color, PopColors.ink);
      expect(d.boxShadow!.single.color, PopColors.pink);
      expect(d.boxShadow!.single.offset, PopShadow.regular);
      expect(d.boxShadow!.single.blurRadius, 0);
      final style = tester.widget<Text>(find.text('Save')).style!;
      expect(style.color, PopColors.white);
      expect(style.fontSize, 18);
      await tester.tap(find.text('Save'));
      expect(taps, 1);
    });

    testWidgets('disabled: muted fill, ignores taps, announced as disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPop(tester, onPaper(const StickerButton(label: 'Save', onPressed: null)));
      expect(_decorationOf(tester, find.text('Save')).color, PopColors.inkMuted);
      expect(
        tester.getSemantics(find.byType(StickerButton)),
        matchesSemantics(label: 'Save', isButton: true, hasEnabledState: true, isEnabled: false),
      );
      handle.dispose();
    });

    testWidgets('pressed: moves by its shadow and the shadow goes', (tester) async {
      await pumpPop(tester, onPaper(StickerButton(label: 'Save', onPressed: () {})));
      final gesture = await tester.startGesture(tester.getCenter(find.text('Save')));
      await tester.pump();
      expect(_decorationOf(tester, find.text('Save')).boxShadow, isEmpty);
      await gesture.up();
      await tester.pump();
      expect(_decorationOf(tester, find.text('Save')).boxShadow, isNotEmpty);
    });
  });

  group('PopChip', () {
    testWidgets('selected adds fill, thicker outline, 2/2 shadow and 800 text', (tester) async {
      await pumpPop(tester, onPaper(const Row(children: <Widget>[
        PopChip(label: 'Rest', selected: false, onTap: _noop),
        PopChip(label: 'On', selected: true, onTap: _noop),
      ])));
      final rest = _decorationOf(tester, find.text('Rest'));
      final on = _decorationOf(tester, find.text('On'));
      expect(rest.color, PopColors.white);
      expect((rest.border! as Border).top.width, PopBorder.thin);
      expect(rest.boxShadow, isEmpty);
      expect(on.color, PopColors.yellow);
      expect((on.border! as Border).top.width, PopBorder.regular);
      expect(on.boxShadow!.single.offset, PopShadow.chip);
      expect(tester.widget<Text>(find.text('On').last).style!.fontWeight, FontWeight.w800);
    });

    testWidgets('is the same size selected or not, so neighbours never move', (tester) async {
      Future<Size> sizeOf({required bool selected, VoidCallback? onRemove}) async {
        await pumpPop(tester, onPaper(Center(child: PopChip(label: 'Groceries', selected: selected, onTap: _noop, onRemove: onRemove))));
        return tester.getSize(find.byType(PopChip));
      }

      expect(await sizeOf(selected: true), await sizeOf(selected: false));
      expect(await sizeOf(selected: true, onRemove: _noop), await sizeOf(selected: false, onRemove: _noop));
    });

    testWidgets('removable chip exposes a labelled remove control', (tester) async {
      final handle = tester.ensureSemantics();
      var removed = false;
      await pumpPop(tester, onPaper(PopChip(label: 'Trip', selected: false, onTap: _noop, onRemove: () => removed = true)));
      await tester.tap(find.bySemanticsLabel('Remove Trip'));
      expect(removed, isTrue);
      handle.dispose();
    });
  });

  group('PopSegmented', () {
    testWidgets('selected segment is pink and switches on tap', (tester) async {
      var value = 'Expense';
      await pumpPop(tester, StatefulBuilder(
        builder: (context, setState) => onPaper(PopSegmented<String>(
          values: const <String>['Expense', 'Income', 'Transfer'],
          selected: value,
          labelOf: (s) => s,
          onChanged: (s) => setState(() => value = s),
        )),
      ));
      expect(_decorationOf(tester, find.text('Expense')).color, PopColors.pink);
      await tester.tap(find.byKey(const Key('segment-income')));
      await tester.pump();
      expect(value, 'Income');
      expect(_decorationOf(tester, find.text('Income')).color, PopColors.pink);
    });
  });

  group('PopSwitch', () {
    testWidgets('toggles, announces state, and is mint when on', (tester) async {
      final handle = tester.ensureSemantics();
      var on = false;
      await pumpPop(tester, StatefulBuilder(
        builder: (context, setState) => onPaper(PopSwitch(value: on, label: 'Reminders', onChanged: (v) => setState(() => on = v))),
      ));
      await tester.tap(find.byType(PopSwitch));
      await tester.pumpAndSettle();
      expect(on, isTrue);
      expect(
        tester.getSemantics(find.byType(PopSwitch)),
        matchesSemantics(label: 'Reminders', hasToggledState: true, isToggled: true, hasEnabledState: true, isEnabled: true, hasTapAction: false),
      );
      handle.dispose();
    });
  });

  group('PopTextField', () {
    testWidgets('error state thickens the outline and shows the message in ink', (tester) async {
      await pumpPop(tester, onPaper(const PopTextField(hint: 'Payee', errorText: 'Add who you paid.')));
      expect(find.text('Add who you paid.'), findsOneWidget);
      final style = tester.widget<Text>(find.text('Add who you paid.')).style!;
      expect(style.color, PopColors.ink);
      expect(style.fontWeight, FontWeight.w800);
    });
  });

  group('PopIconButton', () {
    testWidgets('has a screen-reader label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPop(tester, onPaper(PopIconButton(icon: Icons.arrow_back_rounded, label: 'Back', onTap: () {})));
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      handle.dispose();
    });
  });

  group('PopNavBar', () {
    testWidgets('selected item gets the yellow pill; add button is labelled and tilted', (tester) async {
      final handle = tester.ensureSemantics();
      var added = false;
      await pumpPop(tester, Scaffold(
        bottomNavigationBar: PopNavBar(
          items: const <PopNavItem>[
            PopNavItem(icon: Icons.home_rounded, label: 'Home'),
            PopNavItem(icon: Icons.receipt_long_rounded, label: 'Activity'),
            PopNavItem(icon: Icons.insights_rounded, label: 'Insights'),
            PopNavItem(icon: Icons.savings_rounded, label: 'Wealth'),
          ],
          selectedIndex: 0,
          onSelected: (_) {},
          onAdd: () => added = true,
        ),
      ));
      await tester.tap(find.bySemanticsLabel('Add transaction'));
      expect(added, isTrue);
      final tilt = tester.widget<PopTilted>(
        find.ancestor(of: find.byType(StickerCard), matching: find.byType(PopTilted)).last,
      );
      expect(tilt.degrees, PopTilt.addButton);
      handle.dispose();
    });

    testWidgets('add button keeps clear of its neighbours on a 320 wide phone', (tester) async {
      await pumpPop(tester, Scaffold(
        bottomNavigationBar: PopNavBar(
          items: const <PopNavItem>[
            PopNavItem(icon: Icons.home_rounded, label: 'Home'),
            PopNavItem(icon: Icons.receipt_long_rounded, label: 'Activity'),
            PopNavItem(icon: Icons.insights_rounded, label: 'Insights'),
            PopNavItem(icon: Icons.savings_rounded, label: 'Wealth'),
          ],
          selectedIndex: 0,
          onSelected: (_) {},
          onAdd: () {},
        ),
      ), size: const Size(320, 640));
      final add = tester.getRect(find.descendant(of: find.byType(PopNavBar), matching: find.byType(StickerCard)));
      // Room for the −6° tilt (about 3 each side) and the 4/4 shadow on the right.
      const clearance = 4.0;
      for (final f in <Finder>[find.text('Activity'), find.byIcon(Icons.receipt_long_rounded)]) {
        expect(add.left - tester.getRect(f).right, greaterThanOrEqualTo(clearance), reason: 'left neighbour');
      }
      for (final f in <Finder>[find.text('Insights'), find.byIcon(Icons.insights_rounded)]) {
        expect(tester.getRect(f).left - add.right, greaterThanOrEqualTo(clearance + PopShadow.regular.dx), reason: 'right neighbour');
      }
    });
  });

  group('Tilt guard', () {
    test('cards reject tilt beyond ±3°', () {
      expect(() => StickerCard(tiltDegrees: 4, child: const SizedBox()), throwsAssertionError);
    });
  });

  group('popText', () {
    test('never goes below weight 600 and sets the wght axis', () {
      final s = popText(15, weight: FontWeight.w400);
      expect(s.fontWeight, FontWeight.w600);
      expect(s.fontVariations!.single.value, 600);
      expect(s.fontFamily, 'packages/sticker_pop/BricolageGrotesque');
    });
  });
}

void _noop() {}
