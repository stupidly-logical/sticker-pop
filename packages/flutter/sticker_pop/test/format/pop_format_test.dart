import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_pop/sticker_pop.dart';

/// Runs the shared cases in parity/format-cases.json; every platform must
/// produce exactly these strings.
Map<String, dynamic> _loadCases() {
  var dir = Directory.current;
  while (!File('${dir.path}/parity/format-cases.json').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('parity/format-cases.json not found above ${Directory.current.path}');
    }
    dir = parent;
  }
  return jsonDecode(File('${dir.path}/parity/format-cases.json').readAsStringSync()) as Map<String, dynamic>;
}

PopSign _sign(Map<String, dynamic> c) => switch (c['sign']) {
  'always' => PopSign.always,
  'none' => PopSign.none,
  _ => PopSign.auto,
};

List<Map<String, dynamic>> _list(Map<String, dynamic> all, String name) =>
    (all[name] as List<dynamic>).cast<Map<String, dynamic>>();

void main() {
  final cases = _loadCases();

  test('formatInr', () {
    for (final c in _list(cases, 'formatInr')) {
      expect(
        formatInr(c['paise'] as int, sign: _sign(c), alwaysPaise: c['alwaysPaise'] == true),
        c['out'],
        reason: '$c',
      );
    }
  });

  test('formatInrCompact', () {
    for (final c in _list(cases, 'formatInrCompact')) {
      expect(formatInrCompact(c['paise'] as int, sign: _sign(c)), c['out'], reason: '$c');
    }
  });

  test('formatPopDate', () {
    for (final c in _list(cases, 'formatPopDate')) {
      expect(
        formatPopDate(DateTime.parse(c['date'] as String), now: DateTime.parse(c['now'] as String)),
        c['out'],
        reason: '$c',
      );
    }
  });

  test('formatPopMonth', () {
    for (final c in _list(cases, 'formatPopMonth')) {
      expect(formatPopMonth(DateTime.parse(c['date'] as String)), c['out']);
    }
  });

  test('formatPopTime', () {
    for (final c in _list(cases, 'formatPopTime')) {
      expect(formatPopTime(DateTime.parse(c['time'] as String)), c['out']);
    }
  });
}
