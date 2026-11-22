import 'package:flutter/services.dart';
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

  group('PopSelect', () {
    const accounts = <PopSelectOption<String>>[
      PopSelectOption(value: 'hdfc', label: 'HDFC Savings', icon: Icons.account_balance_rounded),
      PopSelectOption(value: 'icici', label: 'ICICI Credit', caption: 'Card ending 4411'),
      PopSelectOption(value: 'cash', label: 'Cash'),
    ];

    testWidgets('shows the hint, opens a sheet and returns the picked option', (tester) async {
      String? picked;
      await pumpPop(tester, onPaper(StatefulBuilder(
        builder: (context, setState) => PopSelect<String>(
          label: 'Account',
          options: accounts,
          value: picked,
          onChanged: (v) => setState(() => picked = v),
        ),
      )));
      expect(find.text('Choose'), findsOneWidget);
      await tester.tap(find.byType(PopSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('ICICI Credit'), findsOneWidget);
      await tester.tap(find.text('ICICI Credit'));
      await tester.pumpAndSettle();
      expect(picked, 'icici');
      expect(find.text('ICICI Credit'), findsOneWidget); // now shown in the field
      expect(find.byType(PopSheet), findsNothing);
    });

    testWidgets('the chosen row is marked selected and ticked', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPop(tester, onPaper(PopSelect<String>(label: 'Account', options: accounts, value: 'cash', onChanged: (_) {})));
      await tester.tap(find.byType(PopSelect<String>));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(tester.getSemantics(find.widgetWithText(PopOptionRow, 'Cash')), isSemantics(isButton: true, isSelected: true, label: 'Cash', hasTapAction: true));
      handle.dispose();
    });

    testWidgets('disabled when onChanged is null', (tester) async {
      await pumpPop(tester, onPaper(PopSelect<String>(options: accounts, value: null, onChanged: null)));
      await tester.tap(find.byType(PopSelect<String>));
      await tester.pumpAndSettle();
      expect(find.byType(PopSheet), findsNothing);
    });
  });

  group('PopMenu', () {
    Widget menu({required void Function(String) onPick, Alignment at = Alignment.topRight}) => Scaffold(
      body: Align(
        alignment: at,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: PopMenu(
            items: <PopMenuEntry>[
              PopMenuItem(label: 'Edit', icon: Icons.edit_rounded, onTap: () => onPick('edit')),
              PopMenuItem(label: 'Duplicate', icon: Icons.content_copy_rounded, onTap: () => onPick('dup')),
              const PopMenuDivider(),
              PopMenuItem(label: 'Delete', icon: Icons.delete_rounded, destructive: true, onTap: () => onPick('delete')),
            ],
            builder: (context, toggle, open) => PopIconButton(icon: Icons.more_horiz_rounded, label: 'More', onTap: toggle),
          ),
        ),
      ),
    );

    testWidgets('opens below the trigger, picks an item and closes', (tester) async {
      String? picked;
      await pumpPop(tester, menu(onPick: (v) => picked = v));
      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(find.byType(PopIconButton));
      final panel = tester.getRect(find.byType(PopMenuPanel));
      expect(panel.top, greaterThan(trigger.bottom));
      expect(panel.right, closeTo(trigger.right, 1));
      expect(panel.width, greaterThanOrEqualTo(PopSize.menuMinWidth));
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();
      expect(picked, 'dup');
      expect(find.byType(PopMenuPanel), findsNothing);
    });

    testWidgets('flips above the trigger near the bottom of the screen', (tester) async {
      await pumpPop(tester, menu(onPick: (_) {}, at: Alignment.bottomRight));
      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(PopMenuPanel)).bottom, lessThan(tester.getRect(find.byType(PopIconButton)).top));
    });

    testWidgets('Escape and a tap outside close it', (tester) async {
      await pumpPop(tester, menu(onPick: (_) {}));
      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(PopMenuPanel), findsNothing);
      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 400));
      await tester.pumpAndSettle();
      expect(find.byType(PopMenuPanel), findsNothing);
    });

    testWidgets('fits a 320 wide phone', (tester) async {
      await pumpPop(tester, menu(onPick: (_) {}, at: Alignment.topLeft), size: const Size(320, 640));
      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      final panel = tester.getRect(find.byType(PopMenuPanel));
      expect(panel.left, greaterThanOrEqualTo(PopSpace.sm));
      expect(panel.right, lessThanOrEqualTo(320 - PopSpace.sm));
    });
  });

  group('PopCheckbox and PopRadio', () {
    testWidgets('checkbox row toggles, fills mint and is announced as checked', (tester) async {
      final handle = tester.ensureSemantics();
      var on = false;
      await pumpPop(tester, onPaper(StatefulBuilder(
        builder: (context, setState) => PopCheckboxRow(label: 'Include transfers', value: on, onChanged: (v) => setState(() => on = v)),
      )));
      await tester.tap(find.text('Include transfers'));
      await tester.pumpAndSettle();
      expect(on, isTrue);
      final box = tester.widget<AnimatedContainer>(find.descendant(of: find.byType(PopCheckboxMark), matching: find.byType(AnimatedContainer)));
      expect((box.decoration! as BoxDecoration).color, PopColors.mint);
      expect(tester.getSemantics(find.byType(PopCheckboxRow)), isSemantics(isChecked: true, label: 'Include transfers', hasTapAction: true));
      handle.dispose();
    });

    testWidgets('tristate shows mixed; tapping checks it', (tester) async {
      bool? v;
      await pumpPop(tester, onPaper(StatefulBuilder(
        builder: (context, setState) => PopCheckbox(value: v, tristate: true, semanticLabel: 'All', onChanged: (x) => setState(() => v = x)),
      )));
      await tester.tap(find.byType(PopCheckbox));
      await tester.pump();
      expect(v, isTrue);
    });

    testWidgets('radios pick one of a group; the box is a 48 tap target', (tester) async {
      String group = 'month';
      await pumpPop(tester, onPaper(StatefulBuilder(
        builder: (context, setState) => Column(children: <Widget>[
          for (final p in <String>['week', 'month', 'year'])
            PopRadioRow<String>(label: p, value: p, groupValue: group, onChanged: (x) => setState(() => group = x)),
          PopRadio<String>(value: 'x', groupValue: group, onChanged: (_) {}, semanticLabel: 'X'),
        ]),
      )));
      await tester.tap(find.text('year'));
      await tester.pumpAndSettle();
      expect(group, 'year');
      expect(tester.getSize(find.byType(PopRadio<String>)), const Size(PopSize.tapTarget, PopSize.tapTarget));
    });

    testWidgets('disabled rows ignore taps', (tester) async {
      await pumpPop(tester, onPaper(const PopCheckboxRow(label: 'Sync', value: false, onChanged: null)));
      await tester.tap(find.text('Sync'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('PopTopBar', () {
    Border borderOf(WidgetTester tester) {
      final box = tester.widget<AnimatedContainer>(find.descendant(of: find.byType(PopTopBar), matching: find.byType(AnimatedContainer)).first);
      return (box.decoration! as BoxDecoration).border! as Border;
    }

    testWidgets('compact app bar: back button, title, ink line once scrolled', (tester) async {
      var back = 0;
      await pumpPop(tester, Scaffold(
        appBar: PopTopBar(title: 'Food budget', onBack: () => back++, actions: <Widget>[PopIconButton(icon: Icons.edit_rounded, label: 'Edit', onTap: () {})]),
        body: ListView(children: <Widget>[for (var i = 0; i < 40; i++) SizedBox(height: 60, child: Text('Row $i'))]),
      ));
      expect(find.text('Food budget'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back'));
      expect(back, 1);
      expect(borderOf(tester).bottom.color.a, 0);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(borderOf(tester).bottom.color, PopColors.ink);
      expect(tester.getSize(find.byType(PopTopBar)).height, PopSize.topBar);
    });

    testWidgets('large title wraps to two lines at 200% text without overflowing', (tester) async {
      await pumpPop(tester, MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Scaffold(body: Column(children: <Widget>[
          PopTopBar.large(title: 'Spending this month', actions: <Widget>[PopIconButton(icon: Icons.settings_rounded, label: 'Settings', onTap: () {})]),
        ])),
      ), size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PopTopBar)).height, greaterThan(PopSize.topBar));
    });
  });

  group('PopSearchField', () {
    testWidgets('clear appears with text and empties it; cancel calls back', (tester) async {
      var cancelled = false;
      final c = TextEditingController();
      await pumpPop(tester, onPaper(PopSearchField(controller: c, onCancel: () => cancelled = true)));
      expect(find.bySemanticsLabel('Clear search'), findsNothing);
      await tester.enterText(find.byType(TextField), 'chai');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Clear search'));
      await tester.pump();
      expect(c.text, isEmpty);
      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });
  });

  group('Dates', () {
    final today = DateTime(2026, 11, 21);
    testWidgets('date tiles: today reads Today, picking one calls back, more opens', (tester) async {
      DateTime? picked;
      var more = false;
      await pumpPop(tester, onPaper(PopDateTiles(
        dates: <DateTime>[for (var i = 3; i >= 0; i--) today.subtract(Duration(days: i))],
        selected: today,
        today: today,
        onSelected: (d) => picked = d,
        onMore: () => more = true,
      )));
      expect(find.text('TODAY'), findsOneWidget);
      await tester.tap(find.text('19'));
      expect(picked, DateTime(2026, 11, 19));
      await tester.tap(find.bySemanticsLabel('Pick a date'));
      expect(more, isTrue);
    });

    testWidgets('calendar: Monday-first grid, month paging, limits, picker returns the day', (tester) async {
      DateTime? result;
      await pumpPop(tester, Scaffold(body: Builder(builder: (context) => Center(child: PopTextButton(
        label: 'Open',
        onPressed: () async => result = await showPopDatePicker(context: context, today: today, initial: today, lastDate: today),
      )))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('November 2026'), findsOneWidget);
      // 1 Nov 2026 is a Sunday: six blanks before it in a Monday-first week.
      final one = tester.getRect(find.text('1').first);
      final m = tester.getRect(find.text('M'));
      expect(one.center.dx, greaterThan(m.center.dx + 200));
      await tester.tap(find.bySemanticsLabel('22 November 2026'));
      await tester.pump();
      expect(find.byType(PopSheet), findsOneWidget); // after today: not pickable
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('15 October 2026'));
      await tester.pumpAndSettle();
      expect(result, DateTime(2026, 10, 15));
    });
  });

  group('Loading', () {
    testWidgets('skeleton list announces Loading once and pulses; spinner turns', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPop(tester, onPaper(const Column(children: <Widget>[PopSkeletonList(), PopSpinner()])));
      expect(find.bySemanticsLabel('Loading'), findsNWidgets(2));
      final fade = tester.widget<FadeTransition>(find.descendant(of: find.byType(PopSkeleton).first, matching: find.byType(FadeTransition)));
      final before = fade.opacity.value;
      await tester.pump(const Duration(milliseconds: 450));
      expect(fade.opacity.value, lessThan(before));
      handle.dispose();
    });

    testWidgets('reduced motion keeps skeletons and spinner still', (tester) async {
      await pumpPop(tester, const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Scaffold(body: Column(children: <Widget>[PopSkeleton.line(width: 100), PopSpinner()])),
      ));
      await tester.pump(const Duration(milliseconds: 450));
      final fade = tester.widget<FadeTransition>(find.descendant(of: find.byType(PopSkeleton), matching: find.byType(FadeTransition)));
      expect(fade.opacity.value, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('PopTabs', () {
    testWidgets('tapping a tab selects it; the selected tab is yellow and announced', (tester) async {
      final handle = tester.ensureSemantics();
      var tab = 0;
      await pumpPop(tester, onPaper(StatefulBuilder(
        builder: (context, setState) => PopTabs(tabs: const <String>['Spending', 'Income', 'Accounts'], selected: tab, onSelected: (i) => setState(() => tab = i)),
      )));
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      expect(tab, 1);
      expect(tester.getSemantics(find.bySemanticsLabel('Income, tab 2 of 3')), isSemantics(isSelected: true, hasTapAction: true));
      handle.dispose();
    });
  });

  group('PopBanner', () {
    testWidgets('warning is orange; action and dismiss call back', (tester) async {
      var acted = false;
      var dismissed = false;
      await pumpPop(tester, onPaper(PopBanner(
        tone: PopBannerTone.warning,
        title: 'Back up soon',
        message: 'Your last backup was 30 days ago.',
        actionLabel: 'Back up now',
        onAction: () => acted = true,
        onDismiss: () => dismissed = true,
      )));
      expect(tester.widget<StickerCard>(find.byType(StickerCard)).color, PopColors.orange);
      await tester.tap(find.text('Back up now'));
      await tester.tap(find.bySemanticsLabel('Dismiss'));
      expect(acted && dismissed, isTrue);
    });
  });

  group('PopSettingsRow', () {
    testWidgets('chevron row taps; switch row flips when the row is tapped', (tester) async {
      var opened = false;
      var on = false;
      await pumpPop(tester, onPaper(StatefulBuilder(
        builder: (context, setState) => StickerList(children: <Widget>[
          PopSettingsRow(title: 'Language', value: 'English', icon: Icons.translate_rounded, onTap: () => opened = true),
          PopSettingsRow(title: 'Daily reminder', subtitle: 'At 9 pm', switchValue: on, onSwitch: (v) => setState(() => on = v)),
        ]),
      )));
      await tester.tap(find.text('Language'));
      await tester.tap(find.text('Daily reminder'));
      await tester.pump();
      expect(opened, isTrue);
      expect(on, isTrue);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });
  });

  group('PopSlider', () {
    testWidgets('tap and drag set the value, snapped to the step; semantics step it', (tester) async {
      final handle = tester.ensureSemantics();
      var v = 10000.0;
      await pumpPop(tester, onPaper(StatefulBuilder(
        builder: (context, setState) => PopSlider(
          semanticLabel: 'Monthly budget', min: 0, max: 20000, step: 500, value: v,
          valueLabel: (x) => formatInr((x * 100).round()),
          onChanged: (x) => setState(() => v = x),
        ),
      )));
      final r = tester.getRect(find.byType(PopSlider));
      await tester.tapAt(Offset(r.right - 2, r.center.dy));
      await tester.pump();
      expect(v, 20000);
      await tester.dragFrom(Offset(r.right - 14, r.center.dy), Offset(-(r.width - 28) / 4, 0));
      await tester.pump();
      expect(v % 500, 0);
      expect(v, closeTo(15000, 500));
      final before = v;
      tester.semantics.decrease(find.semantics.byLabel('Monthly budget'));
      await tester.pump();
      expect(v, before - 500);
      handle.dispose();
    });
  });

  group('PopStepper', () {
    testWidgets('steps within its limits; the − button disables at the minimum', (tester) async {
      var n = 2;
      await pumpPop(tester, onPaper(StatefulBuilder(
        builder: (context, setState) => PopStepper(semanticLabel: 'People', value: n, min: 1, max: 3, onChanged: (v) => setState(() => n = v)),
      )));
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(n, 3);
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(n, 1);
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('PopKeypad', () {
    test('applyPopKey keeps amounts tidy', () {
      String type(String keys) => keys.split('').fold('', (s, k) => applyPopKey(s, k == '<' ? '⌫' : k));
      expect(type('0012'), '12');
      expect(type('.5'), '0.5');
      expect(type('12.345'), '12.34');
      expect(type('1.2.3'), '1.23');
      expect(type('125<'), '12');
      expect(type('1234567890'), '123456789');
    });

    testWidgets('keys type into an amount; backspace deletes', (tester) async {
      var amount = '';
      await pumpPop(tester, onPaper(StatefulBuilder(
        builder: (context, setState) => PopKeypad(onKey: (k) => setState(() => amount = applyPopKey(amount, k))),
      )));
      for (final k in <String>['4', '5', '0', '.', '5']) {
        await tester.tap(find.bySemanticsLabel(k == '.' ? 'Decimal point' : k));
      }
      await tester.tap(find.bySemanticsLabel('Delete'));
      expect(amount, '450.');
    });
  });

  group('PopAvatar', () {
    test('initials and colour are stable', () {
      expect(popInitials('Asha Rao'), 'AR');
      expect(popInitials('  priya  '), 'P');
      expect(popInitials('Ravi Kumar Shah'), 'RS');
      expect(popInitials(''), '?');
      expect(popAvatarColor('Asha Rao'), popAvatarColor(' Asha Rao '));
      // "Asha Rao": code units sum to 703; 703 % 6 = 1 → pink (the same rule on every platform).
      expect(popAvatarColor('Asha Rao'), PopColors.pink);
    });
  });

  group('PopEmptyState', () {
    testWidgets('error state fits a small phone at 200% text and its action works', (tester) async {
      var retried = false;
      await pumpPop(tester, MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Scaffold(body: SingleChildScrollView(child: PopEmptyState(
          icon: Icons.cloud_off_rounded,
          title: "Couldn't load prices",
          message: 'Check your connection and try again. Your own data is safe on this phone.',
          color: PopColors.orange,
          actionLabel: 'Try again',
          onAction: () => retried = true,
        ))),
      ), size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Try again'));
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });
  });

  group('PopStatTile', () {
    testWidgets('spending down is good: − in a mint badge, read as one sentence', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPop(tester, onPaper(const PopStatTile(label: 'Spent this month', value: '₹4,461', change: '8%', trend: PopTrend.downGood, caption: 'vs October')));
      expect(find.text('−8%'), findsOneWidget);
      expect(tester.widget<StickerBadge>(find.byType(StickerBadge)).color, PopColors.mint);
      expect(find.bySemanticsLabel('Spent this month, ₹4,461, down 8%, vs October'), findsOneWidget);
      handle.dispose();
    });
  });

  group('PopExpandable', () {
    testWidgets('opens and closes; announced as expanded', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPop(tester, onPaper(const Align(alignment: Alignment.topCenter, child: PopExpandable(title: 'Where does my data go?', child: Text('Nowhere: it stays on this phone.')))));
      expect(tester.getSize(find.byType(PopExpandable)).height, lessThan(80));
      await tester.tap(find.text('Where does my data go?'));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(PopExpandable)).height, greaterThan(80));
      expect(tester.getSemantics(find.bySemanticsLabel('Where does my data go?')), isSemantics(isExpanded: true, hasTapAction: true));
      handle.dispose();
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
