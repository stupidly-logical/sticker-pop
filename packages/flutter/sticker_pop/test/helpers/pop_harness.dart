import 'dart:io';

import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sticker_pop/sticker_pop.dart';

/// Loads Bricolage Grotesque and Material Icons so goldens show real text
/// and icons instead of test boxes.
Future<void> loadPopFonts() async {
  final bricolage = FontLoader('packages/sticker_pop/BricolageGrotesque')
    ..addFont(_bytes('assets/fonts/BricolageGrotesque-Variable.ttf'));
  await bricolage.load();

  final root = _flutterRoot();
  if (root != null) {
    final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      final loader = FontLoader('MaterialIcons')..addFont(_bytes(icons.path));
      await loader.load();
    }
  }
}

Future<ByteData> _bytes(String path) async =>
    ByteData.sublistView(await File(path).readAsBytes());

String? _flutterRoot() {
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null) return env;
  // flutter_tester lives at <root>/bin/cache/artifacts/engine/<platform>/.
  final exe = File(Platform.resolvedExecutable).parent;
  var dir = exe;
  for (var i = 0; i < 6; i++) {
    if (File('${dir.path}/bin/flutter').existsSync()) return dir.path;
    dir = dir.parent;
  }
  return null;
}

/// Pumps [child] on a 390×844 phone in the Sticker Pop theme.
Future<void> pumpPop(WidgetTester tester, Widget child, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildPopTheme(),
      home: child,
    ),
  );
}

/// Wraps a component in a padded paper scaffold.
Widget onPaper(Widget child) => Scaffold(
  backgroundColor: PopColors.paper,
  body: Center(child: Padding(padding: const EdgeInsets.all(20), child: child)),
);
