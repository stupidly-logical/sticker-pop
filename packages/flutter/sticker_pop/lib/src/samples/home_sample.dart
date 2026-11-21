import 'package:material_ui/material_ui.dart';

import '../../sticker_pop.dart';

/// The sample's own categories. Mapping data to icons and colours is an
/// app's job, not the design system's.
const Map<String, (IconData, Color)> _categories = <String, (IconData, Color)>{
  'food': (Icons.local_cafe_rounded, PopColors.orange),
  'groceries': (Icons.shopping_cart_rounded, PopColors.mint),
  'transport': (Icons.directions_car_rounded, PopColors.blue),
  'bills': (Icons.bolt_rounded, PopColors.lilac),
  'shopping': (Icons.shopping_bag_rounded, PopColors.pink),
  'salary': (Icons.work_rounded, PopColors.mint),
};

Widget _dot(String category) {
  final (icon, color) = _categories[category] ?? (Icons.more_horiz_rounded, PopColors.white);
  return CategoryDot(icon: icon, color: color);
}

/// One transaction row in the Home sample.
@immutable
class SampleTransaction {
  const SampleTransaction({
    required this.title,
    required this.category,
    required this.paise,
    required this.when,
    this.account,
    this.upi = false,
    this.unsure = false,
  });

  final String title;
  final String category;

  /// Negative for money out.
  final int paise;
  final DateTime when;
  final String? account;
  final bool upi;
  final bool unsure;
}

/// A sample Home screen for an expense app, built only from Sticker Pop
/// components: title, the yellow month card, the Type it / Say
/// it / Scan it row, a "Recent" list and the bottom navigation with the
/// tilted pink add button.
class PopHomeSample extends StatefulWidget {
  const PopHomeSample({super.key, this.now, this.transactions});

  /// The clock; defaults to [DateTime.now].
  final DateTime? now;
  final List<SampleTransaction>? transactions;

  /// A fixed clock for screenshots and tests: 18 Nov 2026, 1:12 pm.
  static final DateTime fixedNow = DateTime(2026, 11, 18, 13, 12);

  static List<SampleTransaction> sampleTransactions(DateTime now) =>
      <SampleTransaction>[
        SampleTransaction(
          title: 'Chai Point',
          category: 'food',
          paise: -12000,
          when: now.subtract(const Duration(minutes: 40)),
          account: 'HDFC',
          upi: true,
        ),
        SampleTransaction(
          title: 'Uber',
          category: 'transport',
          paise: -34650,
          when: now.subtract(const Duration(hours: 4)),
          account: 'ICICI',
          upi: true,
        ),
        SampleTransaction(
          title: 'BigBasket',
          category: 'groceries',
          paise: -184520,
          when: now.subtract(const Duration(days: 1, hours: 2)),
          account: 'HDFC',
          unsure: true,
        ),
        SampleTransaction(
          title: 'Salary',
          category: 'salary',
          paise: 12500000,
          when: now.subtract(const Duration(days: 3)),
          account: 'HDFC',
        ),
        SampleTransaction(
          title: 'Electricity bill',
          category: 'bills',
          paise: -215000,
          when: now.subtract(const Duration(days: 5)),
          account: 'SBI',
        ),
      ];

  @override
  State<PopHomeSample> createState() => _PopHomeSampleState();
}

class _PopHomeSampleState extends State<PopHomeSample> {
  int _tab = 0;

  static const List<PopNavItem> _items = <PopNavItem>[
    PopNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
    PopNavItem(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long_rounded, label: 'Activity'),
    PopNavItem(icon: Icons.insights_rounded, label: 'Insights'),
    PopNavItem(icon: Icons.savings_outlined, selectedIcon: Icons.savings_rounded, label: 'Wealth'),
  ];

  @override
  Widget build(BuildContext context) {
    final now = widget.now ?? DateTime.now();
    final txns = widget.transactions ?? PopHomeSample.sampleTransactions(now);
    final spent = txns.where((t) => t.paise < 0).fold<int>(0, (s, t) => s - t.paise);
    const budget = 4000000; // ₹40,000

    void snack(String what) => showPopSnack(context, '$what opens here');

    return Scaffold(
      backgroundColor: PopColors.paper,
      body: PaperBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: popScreenPadding(context, top: PopSpace.md, bottom: PopSpace.xxl),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: PopText('Home', spec: PopTextSpecs.screenTitle),
                    ),
                  ),
                  PopIconButton(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: () => snack('Settings'),
                  ),
                ],
              ),
              const SizedBox(height: PopSpace.lg),
              StickerCard.hero(
                tiltDegrees: PopTilt.hero,
                onTap: () => snack('Month details'),
                semanticLabel: 'Spent in ${formatPopMonth(now)}: ${formatInr(spent)}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Wraps instead of squeezing the label when space is tight.
                    Wrap(
                      spacing: PopSpace.sm,
                      runSpacing: PopSpace.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        PopText('Spent in ${formatPopMonth(now)}', spec: PopTextSpecs.sectionLabel),
                        StickerBadge(label: '${(spent / budget * 100).round()}% of budget'),
                      ],
                    ),
                    const SizedBox(height: PopSpace.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: PopText(formatInr(spent), spec: PopTextSpecs.heroAmount),
                    ),
                    const SizedBox(height: PopSpace.md),
                    PopProgressBar(
                      value: spent / budget,
                      color: PopColors.pink,
                      semanticLabel: 'Monthly budget used',
                    ),
                    const SizedBox(height: PopSpace.sm),
                    PopText(
                      '${formatInr(budget - spent)} left of ${formatInrCompact(budget)} · 12 days to go',
                      spec: PopTextSpecs.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PopSpace.section),
              PopQuickAddRow.standard(
                onType: () => snack('Type it'),
                onSay: () => snack('Say it'),
                onScan: () => snack('Scan it'),
              ),
              const SizedBox(height: PopSpace.section),
              PopSectionLabel(
                'Recent',
                trailing: PopTextButton(label: 'See all', onPressed: () => setState(() => _tab = 1)),
              ),
              const SizedBox(height: PopSpace.sm),
              if (txns.isEmpty)
                const PopHintCard(
                  icon: Icon(Icons.lightbulb_rounded),
                  message: 'Your spending shows up here. Add one with Type it, Say it or Scan it.',
                )
              else
                StickerList(
                  children: <Widget>[
                    for (final t in txns)
                      StickerListRow(
                        leading: _dot(t.category),
                        title: t.title,
                        badge: t.unsure
                            ? const StickerBadge(label: 'Unsure', color: PopColors.orange)
                            : t.upi
                            ? const StickerBadge(label: 'UPI', fontSize: 11)
                            : null,
                        subtitle: [
                          formatPopDate(t.when, now: now),
                          if (formatPopDate(t.when, now: now) == 'Today') formatPopTime(t.when),
                          ?t.account,
                        ].join(' · '),
                        amount: formatInr(t.paise, sign: PopSign.always),
                        onTap: () => snack(t.title),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PopNavBar(
        items: _items,
        selectedIndex: _tab,
        onSelected: (i) => setState(() => _tab = i),
        onAdd: () => showPopSheet<void>(
          context: context,
          builder: (context) => const _AddSheet(),
        ),
      ),
    );
  }
}

class _AddSheet extends StatefulWidget {
  const _AddSheet();

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

enum _Kind { expense, income, transfer }

class _AddSheetState extends State<_AddSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  _Kind _kind = _Kind.expense;
  String _category = 'food';
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopSheet(
      title: 'Add a transaction',
      trailing: PopIconButton(
        icon: Icons.close_rounded,
        label: 'Close',
        onTap: () => Navigator.of(context).pop(),
      ),
      error: _error,
      primaryLabel: 'Save',
      onPrimary: () {
        if (_amount.text.trim().isEmpty || double.tryParse(_amount.text) == 0) {
          setState(() => _error = 'Enter an amount above ₹0.');
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        showPopSnackOn(messenger, 'Saved');
      },
      children: <Widget>[
        PopSegmented<_Kind>(
          values: _Kind.values,
          selected: _kind,
          labelOf: (k) => switch (k) {
            _Kind.expense => 'Expense',
            _Kind.income => 'Income',
            _Kind.transfer => 'Transfer',
          },
          onChanged: (k) => setState(() => _kind = k),
        ),
        const SizedBox(height: PopSpace.lg),
        PopAmountField(
          controller: _amount,
          color: _kind == _Kind.income ? PopColors.mint : PopColors.yellow,
          label: _kind == _Kind.income ? 'Income' : 'Expense',
          autofocus: false,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const SizedBox(height: PopSpace.lg),
        Wrap(
          spacing: PopSpace.sm,
          runSpacing: PopSpace.sm,
          children: <Widget>[
            for (final c in const <String>['food', 'groceries', 'transport', 'bills', 'shopping'])
              PopChip(
                label: c[0].toUpperCase() + c.substring(1),
                icon: _categories[c]!.$1,
                selected: _category == c,
                color: _categories[c]!.$2,
                onTap: () => setState(() => _category = c),
              ),
          ],
        ),
        const SizedBox(height: PopSpace.lg),
        PopTextField(controller: _note, hint: 'Add a note'),
      ],
    );
  }
}
