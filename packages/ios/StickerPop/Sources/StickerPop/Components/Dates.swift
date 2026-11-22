import SwiftUI

private let popWeekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
private let popMonths = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
private var popCal: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = .current
    return c
}()

/// Monday = 0 … Sunday = 6.
private func popWeekdayIndex(_ d: Date) -> Int { (popCal.component(.weekday, from: d) + 5) % 7 }

/// A strip of date tiles for quick picks: small stickers with the weekday
/// over the day number. The chosen tile is yellow; today reads "Today".
/// `onMore` adds a last tile that opens the calendar.
public struct PopDateTiles: View {
    let dates: [Date]
    @Binding var selection: Date
    let today: Date
    var moreLabel: String
    var onMore: (() -> Void)?

    public init(_ dates: [Date], selection: Binding<Date>, today: Date, moreLabel: String = "Pick a date", onMore: (() -> Void)? = nil) {
        self.dates = dates
        self._selection = selection
        self.today = today
        self.moreLabel = moreLabel
        self.onMore = onMore
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PopSpace.sm) {
                ForEach(dates, id: \.self) { d in
                    let selected = popCal.isDate(d, inSameDayAs: selection)
                    tile(selected: selected, label: "\(popCal.component(.day, from: d)) \(popMonths[popCal.component(.month, from: d) - 1])") {
                        selection = popCal.startOfDay(for: d)
                    } content: {
                        VStack(spacing: 0) {
                            PopText(popCal.isDate(d, inSameDayAs: today) ? "Today" : popWeekdays[popWeekdayIndex(d)], PopTextSpecs.sectionLabel,
                                    color: selected ? PopColors.ink : PopColors.inkMuted)
                            PopText("\(popCal.component(.day, from: d))", PopTextSpecs.sectionHeading)
                        }
                        .minimumScaleFactor(0.6)
                    }
                }
                if let onMore {
                    tile(selected: false, label: moreLabel, action: onMore) {
                        Image(systemName: "calendar").font(.system(size: 22, weight: .bold)).foregroundStyle(PopColors.ink)
                    }
                }
            }
            .padding(.trailing, PopShadow.small)
            .padding(.bottom, PopShadow.small)
        }
    }

    private func tile<C: View>(selected: Bool, label: String, action: @escaping () -> Void, @ViewBuilder content: () -> C) -> some View {
        Button(action: action) {
            content()
                .frame(width: PopSize.dateTileWidth, height: PopSize.dateTileHeight)
                .sticker(fill: selected ? PopColors.yellow : PopColors.white, radius: PopRadius.tile,
                         border: selected ? PopBorder.regular : PopBorder.thin, shadow: PopShadow.small)
        }
        .buttonStyle(PopPressStyle(offset: PopShadow.small))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

/// A month calendar: month and year with previous / next buttons, weekday
/// initials and 40 day circles. The chosen day is yellow with a 2.5 outline;
/// today has a 2 ink ring; days outside the range are muted.
public struct PopCalendar: View {
    @Binding var selection: Date
    let today: Date
    var range: ClosedRange<Date>?
    var onPick: (Date) -> Void
    var rangeStart: Date? = nil
    var rangeEnd: Date? = nil
    var isRange = false
    @State private var month: Date

    public init(selection: Binding<Date>, today: Date, in range: ClosedRange<Date>? = nil, onPick: @escaping (Date) -> Void = { _ in }) {
        self._selection = selection
        self.today = today
        self.range = range
        self.onPick = onPick
        self._month = State(initialValue: popCal.date(from: popCal.dateComponents([.year, .month], from: selection.wrappedValue)) ?? today)
    }

    init(rangeStart: Date?, rangeEnd: Date?, today: Date, in range: ClosedRange<Date>?, onPick: @escaping (Date) -> Void) {
        self._selection = .constant(rangeStart ?? today)
        self.today = today
        self.range = range
        self.onPick = onPick
        self.rangeStart = rangeStart.map { popCal.startOfDay(for: $0) }
        self.rangeEnd = rangeEnd.map { popCal.startOfDay(for: $0) }
        self.isRange = true
        self._month = State(initialValue: popCal.date(from: popCal.dateComponents([.year, .month], from: rangeStart ?? today)) ?? today)
    }

    private func allowed(_ d: Date) -> Bool {
        guard let range else { return true }
        return d >= popCal.startOfDay(for: range.lowerBound) && d <= range.upperBound
    }

    public var body: some View {
        let days = popCal.range(of: .day, in: .month, for: month)?.count ?? 30
        let lead = popWeekdayIndex(month)
        let cells: [Date?] = Array(repeating: nil, count: lead) + (0..<days).map { popCal.date(byAdding: .day, value: $0, to: month) }
        let prev = popCal.date(byAdding: .month, value: -1, to: month)!
        let next = popCal.date(byAdding: .month, value: 1, to: month)!
        VStack(alignment: .leading, spacing: PopSpace.sm) {
            HStack(spacing: PopSpace.sm) {
                PopText("\(popMonths[popCal.component(.month, from: month) - 1]) \(String(popCal.component(.year, from: month)))", PopTextSpecs.sectionHeading)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                PopIconButton(systemImage: "chevron.left", label: "Previous month") { month = prev }
                    .disabled(range.map { popCal.date(byAdding: .day, value: -1, to: month)! < popCal.startOfDay(for: $0.lowerBound) } ?? false)
                PopIconButton(systemImage: "chevron.right", label: "Next month") { month = next }
                    .disabled(range.map { next > $0.upperBound } ?? false)
            }
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    PopText(String(popWeekdays[i].prefix(1)), PopTextSpecs.sectionLabel).frame(maxWidth: .infinity)
                }
            }
            .accessibilityHidden(true)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 4) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, d in
                    if let d { dayCell(d) } else { Color.clear.frame(height: PopSize.calendarDay) }
                }
            }
        }
    }

    private func dayCell(_ d: Date) -> some View {
        let isStart = rangeStart.map { popCal.isDate(d, inSameDayAs: $0) } ?? false
        let isEnd = rangeEnd.map { popCal.isDate(d, inSameDayAs: $0) } ?? false
        let inside = rangeStart != nil && rangeEnd != nil && d > rangeStart! && d < rangeEnd! && !isEnd
        let selected = isRange ? isStart || isEnd : popCal.isDate(d, inSameDayAs: selection)
        let joined = isRange && rangeEnd != nil && !(isStart && isEnd)
        let band: Alignment? = !joined ? nil : inside ? .center : isStart ? .trailing : isEnd ? .leading : nil
        let role = isStart && isEnd ? ", start and end" : isStart ? ", start" : isEnd ? ", end" : inside ? ", in range" : ""
        let isToday = popCal.isDate(d, inSameDayAs: today)
        let ok = allowed(d)
        return Button {
            if !isRange { selection = d }
            onPick(d)
        } label: {
            PopText("\(popCal.component(.day, from: d))", selected ? PopTextSpecs.rowTitle : PopTextSpecs.input, color: ok ? PopColors.ink : PopColors.inkMuted)
                .frame(maxWidth: PopSize.calendarDay, maxHeight: PopSize.calendarDay)
                .aspectRatio(1, contentMode: .fit)
                .background(Circle().fill(selected ? PopColors.yellow : Color.clear))
                .overlay(Circle().strokeBorder(PopColors.ink, lineWidth: selected ? PopBorder.regular : isToday ? PopBorder.thin : 0))
                .frame(maxWidth: .infinity)
                .background(alignment: band ?? .center) {
                    if band != nil {
                        GeometryReader { g in
                            PopColors.mint.frame(width: band == .center ? g.size.width : g.size.width / 2, height: PopSize.calendarDay)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: band!)
                        }
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!ok)
        .accessibilityLabel("\(popCal.component(.day, from: d)) \(popMonths[popCal.component(.month, from: d) - 1])\(isToday ? ", today" : "")\(role)")
        .accessibilityAddTraits(selected || inside ? [.isButton, .isSelected] : .isButton)
    }
}

/// A `PopCalendar` in a sheet, titled "Pick a date"; picking a day closes it.
public struct PopDatePickerSheet: View {
    @Binding var selection: Date
    let today: Date
    var range: ClosedRange<Date>?
    var title: String
    let onDone: () -> Void

    public init(selection: Binding<Date>, today: Date, in range: ClosedRange<Date>? = nil, title: String = "Pick a date", onDone: @escaping () -> Void) {
        self._selection = selection
        self.today = today
        self.range = range
        self.title = title
        self.onDone = onDone
    }

    public var body: some View {
        PopSheet(title) { PopCalendar(selection: $selection, today: today, in: range) { _ in onDone() } }
    }
}

/// A month calendar for choosing a span of days, like a trip. The first tap
/// sets the start, the second the end (tapping earlier than the start moves
/// the start instead); a third tap starts again. Start and end are yellow
/// circles with a 2.5 outline joined by a 40 tall mint band.
public struct PopRangeCalendar: View {
    @Binding var start: Date?
    @Binding var end: Date?
    let today: Date
    var range: ClosedRange<Date>?

    public init(start: Binding<Date?>, end: Binding<Date?>, today: Date, in range: ClosedRange<Date>? = nil) {
        self._start = start
        self._end = end
        self.today = today
        self.range = range
    }

    public var body: some View {
        PopCalendar(rangeStart: start, rangeEnd: end, today: today, in: range) { d in
            if let s = start, end == nil, d >= popCal.startOfDay(for: s) {
                end = d
            } else {
                start = d
                end = nil
            }
        }
    }
}

/// A `PopRangeCalendar` in a sheet with a Done button, enabled once both
/// ends are chosen.
public struct PopDateRangePickerSheet: View {
    @Binding var start: Date?
    @Binding var end: Date?
    let today: Date
    var range: ClosedRange<Date>?
    var title: String
    var doneLabel: String
    let onDone: () -> Void

    public init(start: Binding<Date?>, end: Binding<Date?>, today: Date, in range: ClosedRange<Date>? = nil,
                title: String = "Pick dates", doneLabel: String = "Done", onDone: @escaping () -> Void) {
        self._start = start
        self._end = end
        self.today = today
        self.range = range
        self.title = title
        self.doneLabel = doneLabel
        self.onDone = onDone
    }

    public var body: some View {
        PopSheet(title) {
            PopRangeCalendar(start: $start, end: $end, today: today, in: range)
            StickerButton(doneLabel, action: onDone)
                .disabled(start == nil || end == nil)
                .padding(.top, PopSpace.lg)
        }
    }
}
