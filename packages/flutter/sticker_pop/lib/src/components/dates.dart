import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../format/pop_format.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';
import 'buttons.dart';
import 'overlays.dart';

const List<String> _weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> _months = <String>['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
bool _same(DateTime? a, DateTime? b) => a != null && b != null && a.year == b.year && a.month == b.month && a.day == b.day;

/// A strip of date tiles for quick picks (e.g. the last week): small
/// stickers with the weekday over the day number. The chosen tile is yellow;
/// today reads "Today". [onMore] adds a last tile that opens the calendar.
class PopDateTiles extends StatelessWidget {
  const PopDateTiles({
    super.key,
    required this.dates,
    required this.selected,
    required this.onSelected,
    required this.today,
    this.onMore,
    this.moreLabel = 'Pick a date',
  });

  final List<DateTime> dates;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;
  final DateTime today;
  final VoidCallback? onMore;
  final String moreLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: <Widget>[
          for (final (i, d) in dates.indexed) ...<Widget>[
            if (i > 0) const SizedBox(width: PopSpace.sm),
            _DateTile(
              top: _same(d, today) ? 'Today' : _weekdays[d.weekday - 1],
              bottom: '${d.day}',
              selected: _same(d, selected),
              semanticLabel: formatPopDate(d, now: today),
              onTap: () => onSelected(_day(d)),
            ),
          ],
          if (onMore != null) ...<Widget>[
            const SizedBox(width: PopSpace.sm),
            _DateTile(icon: Icons.calendar_month_rounded, selected: false, semanticLabel: moreLabel, onTap: onMore!),
          ],
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({this.top, this.bottom, this.icon, required this.selected, required this.semanticLabel, required this.onTap});

  final String? top;
  final String? bottom;
  final IconData? icon;
  final bool selected;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const shadow = PopShadow.small;
    return PopPressable(
      onTap: onTap,
      shadow: shadow,
      semanticLabel: semanticLabel,
      selected: selected,
      excludeSemantics: true,
      builder: (context, offset, pressed) => Container(
        width: PopSize.dateTileWidth,
        height: PopSize.dateTileHeight,
        decoration: BoxDecoration(
          color: selected ? PopColors.yellow : PopColors.white,
          borderRadius: BorderRadius.circular(PopRadius.tile),
          border: popOutline(selected ? PopBorder.regular : PopBorder.thin),
          boxShadow: popHardShadow(offset),
        ),
        child: icon != null
            ? Icon(icon, size: PopSize.iconTile, color: PopColors.ink)
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      PopText(top!, spec: PopTextSpecs.sectionLabel, color: selected ? PopColors.ink : PopColors.inkMuted),
                      PopText(bottom!, spec: PopTextSpecs.sectionHeading),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// A month calendar: the month and year with previous / next buttons, the
/// weekday initials, and 40 day circles. The chosen day is yellow with a 2.5
/// outline; today has a 2 ink ring; days outside [firstDate]–[lastDate] are
/// muted and can't be picked.
class PopCalendar extends StatefulWidget {
  const PopCalendar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.today,
    this.firstDate,
    this.lastDate,
    this.firstWeekday = DateTime.monday,
  });

  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;
  final DateTime today;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// DateTime.monday … DateTime.sunday.
  final int firstWeekday;

  @override
  State<PopCalendar> createState() => _PopCalendarState();
}

class _PopCalendarState extends State<PopCalendar> {
  late DateTime _month = DateTime((widget.selected ?? widget.today).year, (widget.selected ?? widget.today).month);

  bool _allowed(DateTime d) =>
      (widget.firstDate == null || !d.isBefore(_day(widget.firstDate!))) && (widget.lastDate == null || !d.isAfter(_day(widget.lastDate!)));

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_month.year, _month.month);
    final lead = (first.weekday - widget.firstWeekday + 7) % 7;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final prev = DateTime(_month.year, _month.month - 1);
    final next = DateTime(_month.year, _month.month + 1);
    final canPrev = widget.firstDate == null || !DateTime(_month.year, _month.month, 0).isBefore(_day(widget.firstDate!));
    final canNext = widget.lastDate == null || !next.isAfter(_day(widget.lastDate!));
    final cells = <Widget>[
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++) _dayCell(DateTime(_month.year, _month.month, d)),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: PopText('${_months[_month.month - 1]} ${_month.year}', spec: PopTextSpecs.sectionHeading),
              ),
            ),
            PopIconButton(icon: Icons.chevron_left_rounded, label: 'Previous month', onTap: canPrev ? () => setState(() => _month = prev) : null),
            const SizedBox(width: PopSpace.sm),
            PopIconButton(icon: Icons.chevron_right_rounded, label: 'Next month', onTap: canNext ? () => setState(() => _month = next) : null),
          ],
        ),
        const SizedBox(height: PopSpace.md),
        Row(
          children: <Widget>[
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: ExcludeSemantics(
                    child: PopText(_weekdays[(widget.firstWeekday - 1 + i) % 7].substring(0, 1), spec: PopTextSpecs.sectionLabel),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: PopSpace.xs),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1,
          children: cells,
        ),
      ],
    );
  }

  Widget _dayCell(DateTime d) {
    final selected = _same(d, widget.selected);
    final today = _same(d, widget.today);
    final allowed = _allowed(d);
    return Semantics(
      button: true,
      selected: selected,
      enabled: allowed,
      label: '${d.day} ${_months[d.month - 1]} ${d.year}${today ? ', today' : ''}',
      onTap: allowed ? () => widget.onSelected(d) : null,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: allowed ? () => widget.onSelected(d) : null,
        child: Center(
          child: AnimatedContainer(
            duration: PopMotion.toggle,
            width: PopSize.calendarDay,
            height: PopSize.calendarDay,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? PopColors.yellow : null,
              shape: BoxShape.circle,
              border: selected ? popOutline() : today ? popOutline(PopBorder.thin) : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: PopText(
                '${d.day}',
                spec: selected ? PopTextSpecs.rowTitle : PopTextSpecs.input,
                color: allowed ? PopColors.ink : PopColors.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens a [PopCalendar] in a bottom sheet; returns the picked day, or null.
Future<DateTime?> showPopDatePicker({
  required BuildContext context,
  required DateTime today,
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'Pick a date',
  int firstWeekday = DateTime.monday,
}) {
  return showPopSheet<DateTime>(
    context: context,
    builder: (sheetContext) => PopSheet(
      title: title,
      children: <Widget>[
        PopCalendar(
          selected: initial,
          today: today,
          firstDate: firstDate,
          lastDate: lastDate,
          firstWeekday: firstWeekday,
          onSelected: (d) => Navigator.of(sheetContext).pop(d),
        ),
      ],
    ),
  );
}
