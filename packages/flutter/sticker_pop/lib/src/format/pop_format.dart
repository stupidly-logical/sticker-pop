/// Content formats from the Sticker Pop spec: Indian rupees with Indian digit
/// grouping, compact amounts, and short dates and times.
///
/// Amounts are `int` paise everywhere, never `double`.
library;

const String _minus = '−'; // − (a real minus sign, not a hyphen)

/// Groups digits the Indian way: 1,25,000 and 12,34,56,789.
String groupIndian(int value) {
  final digits = value.abs().toString();
  if (digits.length <= 3) return digits;
  final last3 = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

/// How [formatInr] marks direction.
enum PopSign {
  /// Only negatives get a sign (−).
  auto,

  /// Money in gets "+", money out gets "−".
  always,

  /// No sign, even for negatives.
  none,
}

/// Formats [paise] as rupees: ₹1,25,000 or ₹1,250.50.
///
/// Paise are shown only when non-zero, unless [alwaysPaise] is set.
String formatInr(
  int paise, {
  PopSign sign = PopSign.auto,
  bool alwaysPaise = false,
}) {
  final rupees = paise.abs() ~/ 100;
  final rem = paise.abs() % 100;
  final body = rem != 0 || alwaysPaise
      ? '${groupIndian(rupees)}.${rem.toString().padLeft(2, '0')}'
      : groupIndian(rupees);
  return '${_signFor(paise, sign)}₹$body';
}

/// Compact rupees: ₹950, ₹51.2k, ₹1.25L, ₹2.1Cr.
///
/// Uses at most three significant figures and drops trailing zeros.
String formatInrCompact(int paise, {PopSign sign = PopSign.auto}) {
  final rupees = paise.abs() / 100;
  String body;
  if (rupees >= 1e7) {
    body = '${_trim(rupees / 1e7)}Cr';
  } else if (rupees >= 1e5) {
    body = '${_trim(rupees / 1e5)}L';
  } else if (rupees >= 1e3) {
    body = '${_trim(rupees / 1e3)}k';
  } else {
    body = groupIndian(rupees.round());
  }
  return '${_signFor(paise, sign)}₹$body';
}

String _signFor(int paise, PopSign sign) => switch (sign) {
  PopSign.none => '',
  PopSign.auto => paise < 0 ? _minus : '',
  PopSign.always =>
    paise < 0
        ? _minus
        : paise > 0
        ? '+'
        : '',
};

/// Three significant figures, trailing zeros removed: 51.2, 1.25, 2.1, 125.
String _trim(double v) {
  final decimals = v >= 100
      ? 0
      : v >= 10
      ? 1
      : 2;
  var s = v.toStringAsFixed(decimals);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Today", "Yesterday", or "18 Nov 2026".
String formatPopDate(DateTime date, {required DateTime now}) {
  final d = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  final days = today.difference(d).inHours ~/ 24;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// "Nov 2026".
String formatPopMonth(DateTime date) =>
    '${_months[date.month - 1]} ${date.year}';

/// 12-hour time: "1:12 pm", "9:05 am", "12:00 pm".
String formatPopTime(DateTime time) {
  final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m ${time.hour < 12 ? 'am' : 'pm'}';
}
