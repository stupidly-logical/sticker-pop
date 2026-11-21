import 'package:material_ui/material_ui.dart';

import '../../sticker_pop.dart';
import 'home_sample.dart';

/// Every Sticker Pop component in each of its states (rest, selected,
/// disabled, error), plus the token swatches. Run it from the example app.
class PopGallery extends StatefulWidget {
  const PopGallery({super.key});

  @override
  State<PopGallery> createState() => _PopGalleryState();
}

class _PopGalleryState extends State<PopGallery> {
  final GlobalKey _addKey = GlobalKey();
  final GlobalKey _chipKey = GlobalKey();
  String _segment = 'Expense';
  String _chip = 'Food';
  bool _switch = true;
  int _nav = 0;
  final Set<String> _tags = <String>{'Office', 'Trip'};
  String? _account = 'hdfc';
  bool _transfers = true;
  bool _hideSmall = false;
  String _period = 'Month';
  int _tab = 0;
  static final DateTime _today = DateTime(2026, 11, 21);
  DateTime _date = DateTime(2026, 11, 21);

  static const List<PopSelectOption<String>> _accounts = <PopSelectOption<String>>[
    PopSelectOption(value: 'hdfc', label: 'HDFC', icon: Icons.account_balance_rounded, caption: 'Savings ·· 4821'),
    PopSelectOption(value: 'icici', label: 'ICICI', icon: Icons.credit_card_rounded, caption: 'Credit card ·· 4411'),
    PopSelectOption(value: 'cash', label: 'Cash', icon: Icons.payments_rounded),
  ];
  final TextEditingController _amount = TextEditingController(text: '1250.50');

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PopColors.paper,
      body: PaperBackground(
        child: SafeArea(
          child: ListView(
            padding: popScreenPadding(
              context,
              top: PopSpace.screen,
              bottom: PopSpace.screen,
            ),
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: PopText(
                      'Sticker Pop',
                      spec: PopTextSpecs.welcomeTitle,
                    ),
                  ),
                  PopIconButton(
                    icon: Icons.home_rounded,
                    label: 'Open the Home sample',
                    color: PopColors.yellow,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PopHomeSample(now: PopHomeSample.fixedNow),
                      ),
                    ),
                  ),
                ],
              ),
              const PopText(
                'A bold, friendly design system',
                spec: PopTextSpecs.body,
              ),

              _Section(
                'Colour',
                children: <Widget>[
                  Wrap(
                    spacing: PopSpace.md,
                    runSpacing: PopSpace.md,
                    children: <Widget>[
                      for (final (name, c) in const <(String, Color)>[
                        ('paper', PopColors.paper),
                        ('ink', PopColors.ink),
                        ('inkMuted', PopColors.inkMuted),
                        ('white', PopColors.white),
                        ('divider', PopColors.divider),
                        ('yellow', PopColors.yellow),
                        ('pink', PopColors.pink),
                        ('blue', PopColors.blue),
                        ('mint', PopColors.mint),
                        ('lilac', PopColors.lilac),
                        ('orange', PopColors.orange),
                      ])
                        _Swatch(name: name, color: c),
                    ],
                  ),
                ],
              ),

              _Section(
                'Type',
                children: <Widget>[
                  for (final (name, spec) in const <(String, PopTextSpec)>[
                    ('Screen title 34', PopTextSpecs.screenTitle),
                    ('₹1,25,000', PopTextSpecs.heroAmount),
                    ('Sheet title 22', PopTextSpecs.sheetTitle),
                    ('Row title 16', PopTextSpecs.rowTitle),
                    ('Body 15 for sentences people read.', PopTextSpecs.body),
                    ('Caption 13 in muted ink', PopTextSpecs.caption),
                    ('Section label', PopTextSpecs.sectionLabel),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: PopText(name, spec: spec),
                    ),
                ],
              ),

              _Section(
                'StickerCard',
                children: <Widget>[
                  const StickerCard(
                    child: PopText(
                      'Default: white, 4/4 shadow',
                      spec: PopTextSpecs.body,
                    ),
                  ),
                  const SizedBox(height: PopSpace.cardGap),
                  const StickerCard.hero(
                    tiltDegrees: PopTilt.hero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        PopText('Net worth', spec: PopTextSpecs.sectionLabel),
                        PopText('₹12,40,500', spec: PopTextSpecs.heroAmount),
                      ],
                    ),
                  ),
                  const SizedBox(height: PopSpace.cardGap),
                  const Row(
                    children: <Widget>[
                      Expanded(
                        child: StickerCard.info(
                          child: PopText('Info, blue', spec: PopTextSpecs.body),
                        ),
                      ),
                      SizedBox(width: PopSpace.md),
                      Expanded(
                        child: StickerCard.info(
                          color: PopColors.mint,
                          child: PopText('Info, mint', spec: PopTextSpecs.body),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PopSpace.cardGap),
                  // Gradient fills come from tokens (PopGradients).
                  Row(
                    children: <Widget>[
                      for (final (i, MapEntry(key: name, value: g))
                          in PopGradients.byName.entries.indexed) ...<Widget>[
                        if (i > 0) const SizedBox(width: PopSpace.md),
                        Expanded(
                          child: StickerCard(
                            gradient: g,
                            padding: const EdgeInsets.symmetric(
                              horizontal: PopSpace.sm,
                              vertical: PopSpace.lg,
                            ),
                            child: Center(
                              child: PopText(name, spec: PopTextSpecs.chipSelected, maxLines: 1),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: PopSpace.cardGap),
                  const PopHintCard(
                    icon: Icon(Icons.lightbulb_rounded),
                    message: 'Goals you add show up here. Tap Add goal to start one.',
                  ),
                ],
              ),

              _Section(
                'Buttons',
                children: <Widget>[
                  StickerButton(label: 'Save', onPressed: () {}),
                  const SizedBox(height: PopSpace.lg),
                  const StickerButton(
                    label: 'Save (disabled)',
                    onPressed: null,
                  ),
                  const SizedBox(height: PopSpace.lg),
                  StickerButton(label: 'Saving', busy: true, onPressed: () {}),
                  const SizedBox(height: PopSpace.sm),
                  Wrap(
                    spacing: PopSpace.sm,
                    children: <Widget>[
                      PopTextButton(label: 'Cancel', onPressed: () {}),
                      PopTextButton(
                        label: 'Skip',
                        underline: true,
                        onPressed: () {},
                      ),
                      const PopTextButton(label: 'Disabled', onPressed: null),
                    ],
                  ),
                  const SizedBox(height: PopSpace.sm),
                  Wrap(
                    spacing: PopSpace.md,
                    runSpacing: PopSpace.md,
                    children: <Widget>[
                      PopIconButton(
                        icon: Icons.arrow_back_rounded,
                        label: 'Back',
                        onTap: () {},
                      ),
                      PopIconButton(
                        icon: Icons.mic_rounded,
                        label: 'Voice',
                        color: PopColors.pink,
                        onTap: () {},
                      ),
                      PopIconButton(
                        icon: Icons.tune_rounded,
                        label: 'Filters on',
                        selected: true,
                        color: PopColors.yellow,
                        onTap: () {},
                      ),
                      const PopIconButton(
                        icon: Icons.close_rounded,
                        label: 'Close',
                        onTap: null,
                      ),
                    ],
                  ),
                ],
              ),

              _Section(
                'PopChip',
                children: <Widget>[
                  Wrap(
                    key: _chipKey,
                    spacing: PopSpace.sm,
                    runSpacing: PopSpace.sm,
                    children: <Widget>[
                      for (final c in const <String>['Food', 'Travel', 'Bills'])
                        PopChip(
                          label: c,
                          selected: _chip == c,
                          onTap: () => setState(() => _chip = c),
                        ),
                      PopChip(
                        label: 'Mint',
                        icon: Icons.eco_rounded,
                        selected: true,
                        color: PopColors.mint,
                        onTap: () {},
                      ),
                      const PopChip(
                        label: 'Disabled',
                        selected: false,
                        onTap: null,
                      ),
                      for (final t in _tags)
                        PopChip(
                          label: t,
                          selected: false,
                          onTap: () {},
                          onRemove: () => setState(() => _tags.remove(t)),
                        ),
                    ],
                  ),
                ],
              ),

              _Section(
                'PopSegmented',
                children: <Widget>[
                  PopSegmented<String>(
                    values: const <String>['Expense', 'Income', 'Transfer'],
                    selected: _segment,
                    labelOf: (s) => s,
                    onChanged: (s) => setState(() => _segment = s),
                  ),
                  const SizedBox(height: PopSpace.md),
                  PopSegmented<String>(
                    values: const <String>['Month', 'Year'],
                    selected: 'Month',
                    labelOf: (s) => s,
                    onChanged: null,
                  ),
                ],
              ),

              _Section(
                'PopSwitch',
                children: <Widget>[
                  StickerList(
                    children: <Widget>[
                      PopFieldRow(
                        label: 'Reminders',
                        divider: false,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: PopSwitch(
                            value: _switch,
                            label: 'Reminders',
                            onChanged: (v) => setState(() => _switch = v),
                          ),
                        ),
                      ),
                      const PopFieldRow(
                        label: 'Sync',
                        divider: false,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: PopSwitch(
                            value: false,
                            label: 'Sync (unavailable)',
                            onChanged: null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              _Section(
                'Text fields',
                children: <Widget>[
                  const PopTextField(label: 'Note', hint: 'Add a note'),
                  const SizedBox(height: PopSpace.md),
                  const PopTextField(
                    label: 'Payee',
                    hint: 'Who was it?',
                    errorText: 'Add who you paid.',
                  ),
                  const SizedBox(height: PopSpace.md),
                  const PopTextField(
                    label: 'Account',
                    hint: 'HDFC ·· 4821',
                    enabled: false,
                  ),
                  const SizedBox(height: PopSpace.md),
                  PopSearchField(hint: 'Search transactions', onCancel: () {}),
                  const SizedBox(height: PopSpace.lg),
                  PopAmountField(controller: _amount, label: 'Expense'),
                  const SizedBox(height: PopSpace.lg),
                  // A details card: field rows draw their own dividers.
                  StickerCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[
                        const PopFieldRow(
                          label: 'Paid to',
                          child: PopText(
                            'Chai Point',
                            spec: PopTextSpecs.rowTitle,
                          ),
                        ),
                        PopFieldRow(
                          label: 'Account',
                          showChevron: true,
                          divider: false,
                          onTap: () {},
                          child: const PopText(
                            'HDFC ·· 4821',
                            spec: PopTextSpecs.rowTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              _Section(
                'Select and menu',
                children: <Widget>[
                  PopSelect<String>(
                    label: 'Account',
                    options: _accounts,
                    value: _account,
                    onChanged: (v) => setState(() => _account = v),
                  ),
                  const SizedBox(height: PopSpace.md),
                  PopSelect<String>(
                    label: 'Paid from',
                    hint: 'Choose an account',
                    options: _accounts,
                    value: null,
                    onChanged: (_) {},
                    errorText: 'Choose where the money came from.',
                  ),
                  const SizedBox(height: PopSpace.lg),
                  Row(
                    children: <Widget>[
                      const Expanded(child: PopText('Chai Point', spec: PopTextSpecs.rowTitle)),
                      PopMenu(
                        items: <PopMenuEntry>[
                          PopMenuItem(label: 'Edit', icon: Icons.edit_rounded, onTap: () => showPopSnack(context, 'Edit opens here')),
                          PopMenuItem(label: 'Duplicate', icon: Icons.content_copy_rounded, onTap: () => showPopSnack(context, 'Duplicated')),
                          const PopMenuDivider(),
                          PopMenuItem(
                            label: 'Delete',
                            icon: Icons.delete_rounded,
                            destructive: true,
                            onTap: () => showPopSnack(context, 'Deleted', actionLabel: 'Undo', onAction: () {}),
                          ),
                        ],
                        builder: (context, toggle, open) => PopIconButton(
                          icon: Icons.more_horiz_rounded,
                          label: 'More for Chai Point',
                          onTap: toggle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              _Section(
                'Checkbox and radio',
                children: <Widget>[
                  StickerList(
                    children: <Widget>[
                      PopCheckboxRow(
                        label: 'Include transfers',
                        caption: 'Moving money between your own accounts',
                        value: _transfers,
                        onChanged: (v) => setState(() => _transfers = v),
                      ),
                      PopCheckboxRow(label: 'Hide small amounts', value: _hideSmall, onChanged: (v) => setState(() => _hideSmall = v)),
                      const PopCheckboxRow(label: 'Sync', value: true, onChanged: null),
                    ],
                  ),
                  const SizedBox(height: PopSpace.lg),
                  StickerList(
                    children: <Widget>[
                      for (final p in const <String>['Week', 'Month', 'Year'])
                        PopRadioRow<String>(label: p, value: p, groupValue: _period, onChanged: (v) => setState(() => _period = v)),
                    ],
                  ),
                ],
              ),

              _Section(
                'Dates',
                children: <Widget>[
                  PopDateTiles(
                    dates: <DateTime>[for (var i = 4; i >= 0; i--) _today.subtract(Duration(days: i))],
                    selected: _date,
                    today: _today,
                    onSelected: (d) => setState(() => _date = d),
                    onMore: () async {
                      final d = await showPopDatePicker(context: context, today: _today, initial: _date, lastDate: _today);
                      if (d != null) setState(() => _date = d);
                    },
                  ),
                  const SizedBox(height: PopSpace.lg),
                  StickerCard(
                    child: PopCalendar(selected: _date, today: _today, lastDate: _today, onSelected: (d) => setState(() => _date = d)),
                  ),
                ],
              ),

              _Section(
                'Banners',
                children: <Widget>[
                  PopBanner(
                    tone: PopBannerTone.warning,
                    title: 'Back up soon',
                    message: 'Your last backup was 30 days ago.',
                    actionLabel: 'Back up now',
                    onAction: () {},
                    onDismiss: () {},
                  ),
                  const SizedBox(height: PopSpace.md),
                  const PopBanner(message: 'Prices update every morning at 9.'),
                  const SizedBox(height: PopSpace.md),
                  const PopBanner(tone: PopBannerTone.success, message: 'All caught up: nothing needs a category.'),
                ],
              ),

              _Section(
                'Loading',
                children: const <Widget>[
                  PopSkeletonList(rows: 2),
                  SizedBox(height: PopSpace.lg),
                  Row(children: <Widget>[PopSpinner(), SizedBox(width: PopSpace.md), PopText('Fetching prices…', spec: PopTextSpecs.body)]),
                ],
              ),

              _Section(
                'Tabs',
                children: <Widget>[
                  PopTabs(tabs: const <String>['Spending', 'Income', 'Accounts', 'Goals'], selected: _tab, onSelected: (i) => setState(() => _tab = i)),
                ],
              ),

              _Section(
                'Top app bar',
                children: <Widget>[
                  // Shown inside bordered frames here; in an app the compact bar
                  // is the Scaffold appBar and the large one tops the content.
                  _Frame(child: PopTopBar.large(
                    title: 'Insights',
                    scrolled: false,
                    actions: <Widget>[
                      PopIconButton(icon: Icons.calendar_month_rounded, label: 'Pick month', onTap: () {}),
                      PopIconButton(icon: Icons.settings_rounded, label: 'Settings', onTap: () {}),
                    ],
                  )),
                  const SizedBox(height: PopSpace.md),
                  _Frame(child: PopTopBar(
                    title: 'Food budget',
                    scrolled: false,
                    onBack: () {},
                    actions: <Widget>[PopIconButton(icon: Icons.edit_rounded, label: 'Edit', onTap: () {})],
                  )),
                  const SizedBox(height: PopSpace.md),
                  _Frame(child: PopTopBar(title: 'Scrolled under', scrolled: true, onBack: () {})),
                ],
              ),

              _Section(
                'Badges and category dots',
                children: <Widget>[
                  const Wrap(
                    spacing: PopSpace.md,
                    runSpacing: PopSpace.md,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      StickerBadge(label: 'UPI'),
                      StickerBadge(label: 'Unsure', color: PopColors.orange),
                      StickerBadge(label: '+12.4%', color: PopColors.mint),
                      StickerBadge(
                        label: 'Coming soon',
                        caps: true,
                        color: PopColors.lilac,
                      ),
                    ],
                  ),
                  const SizedBox(height: PopSpace.lg),
                  Wrap(
                    spacing: PopSpace.md,
                    runSpacing: PopSpace.md,
                    children: <Widget>[
                      for (final (icon, color) in const <(IconData, Color)>[
                        (Icons.local_cafe_rounded, PopColors.orange),
                        (Icons.shopping_cart_rounded, PopColors.mint),
                        (Icons.directions_car_rounded, PopColors.blue),
                        (Icons.bolt_rounded, PopColors.lilac),
                        (Icons.shopping_bag_rounded, PopColors.pink),
                        (Icons.more_horiz_rounded, PopColors.white),
                      ])
                        CategoryDot(icon: icon, color: color),
                    ],
                  ),
                ],
              ),

              _Section(
                'StickerList',
                children: <Widget>[
                  StickerList(
                    children: <Widget>[
                      StickerListRow(
                        leading: const CategoryDot(
                          icon: Icons.local_cafe_rounded,
                          color: PopColors.orange,
                        ),
                        title: 'Chai Point',
                        badge: const StickerBadge(label: 'UPI', fontSize: 11),
                        subtitle: 'Today · 1:12 pm · HDFC',
                        amount: formatInr(-12000, sign: PopSign.always),
                        onTap: () {},
                      ),
                      StickerListRow(
                        leading: const CategoryDot(
                          icon: Icons.work_rounded,
                          color: PopColors.mint,
                        ),
                        title: 'Salary',
                        subtitle: '15 Nov 2026 · HDFC',
                        amount: formatInr(12500000, sign: PopSign.always),
                        selected: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),

              _Section(
                'Progress and charts',
                children: <Widget>[
                  const PopProgressBar(
                    value: 0.8,
                    color: PopColors.orange,
                    semanticLabel: 'Food budget',
                  ),
                  const SizedBox(height: PopSpace.sm),
                  const PopText(
                    '₹8,000 of ₹10,000 · 80% used',
                    spec: PopTextSpecs.caption,
                  ),
                  const SizedBox(height: PopSpace.lg),
                  StickerCard(
                    child: Row(
                      children: <Widget>[
                        const PopDonut(
                          size: 140,
                          thickness: 30,
                          semanticLabel: 'Spending by category',
                          data: _slices,
                          center: PopText(
                            '₹51.2k',
                            spec: PopTextSpecs.rowAmount,
                          ),
                        ),
                        const SizedBox(width: PopSpace.lg),
                        const Expanded(child: PopLegend(data: _slices)),
                      ],
                    ),
                  ),
                  const SizedBox(height: PopSpace.lg),
                  const StickerCard(
                    child: PopBarChart(
                      semanticLabel: 'Spend by month',
                      highlightIndex: 5,
                      data: <PopDatum>[
                        PopDatum(
                          label: 'Jun',
                          value: 38,
                          color: PopColors.blue,
                        ),
                        PopDatum(
                          label: 'Jul',
                          value: 42,
                          color: PopColors.blue,
                        ),
                        PopDatum(
                          label: 'Aug',
                          value: 31,
                          color: PopColors.blue,
                        ),
                        PopDatum(
                          label: 'Sep',
                          value: 47,
                          color: PopColors.blue,
                        ),
                        PopDatum(
                          label: 'Oct',
                          value: 52,
                          color: PopColors.blue,
                        ),
                        PopDatum(
                          label: 'Nov',
                          value: 29,
                          color: PopColors.yellow,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              _Section(
                'Overlays',
                children: <Widget>[
                  Wrap(
                    spacing: PopSpace.md,
                    runSpacing: PopSpace.md,
                    children: <Widget>[
                      PopChip(
                        label: 'Sheet',
                        selected: false,
                        onTap: () => showPopSheet<void>(
                          context: context,
                          builder: (context) => PopSheet(
                            title: 'Rename account',
                            error: 'Names need at least one letter.',
                            primaryLabel: 'Save',
                            onPrimary: () => Navigator.pop(context),
                            children: const <Widget>[
                              PopTextField(hint: 'Account name'),
                            ],
                          ),
                        ),
                      ),
                      PopChip(
                        label: 'Dialog',
                        selected: false,
                        onTap: () => showPopDialog<void>(
                          context: context,
                          builder: (context) => PopDialog(
                            title: 'Delete this transaction?',
                            body: 'It goes from this phone straight away. You can undo for a few seconds.',
                            primaryLabel: 'Delete',
                            onPrimary: () {
                              Navigator.pop(context);
                              showPopSnack(
                                context,
                                'Deleted',
                                actionLabel: 'Undo',
                              );
                            },
                          ),
                        ),
                      ),
                      PopChip(
                        label: 'Snackbar',
                        selected: false,
                        onTap: () => showPopSnack(context, 'Saved'),
                      ),
                      PopChip(
                        label: 'Tour',
                        selected: false,
                        onTap: () => showPopTour(context, <PopTourStep>[
                          PopTourStep(
                            target: _chipKey,
                            title: 'Pick a category',
                            body: 'Tap a chip to choose it. Chips you pick get a fill and a thicker outline.',
                          ),
                          PopTourStep(
                            target: _addKey,
                            title: 'Add anything',
                            body: 'The pink button adds an expense, income or transfer.',
                          ),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: PopSpace.lg),
                  PopTourCard(
                    step: 1,
                    count: 3,
                    title: 'Say it',
                    body: 'Speak an expense like "450 for lunch". It is read on the phone and not kept.',
                    onNext: () {},
                    onSkip: () {},
                  ),
                ],
              ),

              _Section(
                'Quick add',
                children: <Widget>[
                  PopQuickAddRow.standard(
                    onType: () {},
                    onSay: () {},
                    onScan: () {},
                  ),
                ],
              ),

              _Section(
                'Navigation',
                children: <Widget>[
                  StickerCard(
                    padding: EdgeInsets.zero,
                    shadow: Offset.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        PopRadius.card - PopBorder.regular,
                      ),
                      child: KeyedSubtree(
                        key: _addKey,
                        child: PopNavBar(
                          items: const <PopNavItem>[
                            PopNavItem(icon: Icons.home_rounded, label: 'Home'),
                            PopNavItem(
                              icon: Icons.receipt_long_rounded,
                              label: 'Activity',
                            ),
                            PopNavItem(
                              icon: Icons.insights_rounded,
                              label: 'Insights',
                            ),
                            PopNavItem(
                              icon: Icons.savings_rounded,
                              label: 'Wealth',
                            ),
                          ],
                          selectedIndex: _nav,
                          onSelected: (i) => setState(() => _nav = i),
                          onAdd: () {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PopSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }

  static const List<PopDatum> _slices = <PopDatum>[
    PopDatum(label: 'Food', value: 32, color: PopColors.orange),
    PopDatum(label: 'Groceries', value: 24, color: PopColors.mint),
    PopDatum(label: 'Transport', value: 18, color: PopColors.blue),
    PopDatum(label: 'Bills', value: 16, color: PopColors.lilac),
    PopDatum(label: 'Shopping', value: 10, color: PopColors.pink),
  ];
}

/// A rounded, outlined frame for showing a bar out of context.
class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PopRadius.tile),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PopRadius.tile),
          border: Border.all(color: PopColors.divider, width: PopBorder.divider),
        ),
        child: MediaQuery.removePadding(context: context, removeTop: true, child: child),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, {required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: PopSpace.section + PopSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: PopText(title, spec: PopTextSpecs.sectionHeading),
          ),
          const SizedBox(height: PopSpace.md),
          ...children,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final onInk = color == PopColors.ink || color == PopColors.inkMuted;
    return Container(
      width: 96,
      height: 64,
      padding: const EdgeInsets.all(PopSpace.sm),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PopRadius.tile),
        border: popOutline(),
        boxShadow: popHardShadow(PopShadow.small),
      ),
      child: Text(
        name,
        style: popTextOf(
          PopTextSpecs.chipSelected,
          color: onInk ? PopColors.white : PopColors.ink,
        ),
      ),
    );
  }
}
