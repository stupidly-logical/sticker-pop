import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Golden images are recorded on one machine and checked on others (ARM
/// Linux, x86 CI, macOS). Their blending can round a colour channel
/// differently by a shade or two, so a golden passes when every channel of
/// every pixel is within [_kChannelTolerance] of the recording. Anything
/// bigger, like a moved edge or different text, still fails as usual.
const int _kChannelTolerance = 2;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final current = goldenFileComparator;
  if (current is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(current.basedir.resolve('golden_test.dart'));
  }
  await testMain();
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final goldenBytes = await getGoldenBytes(golden);
    if (await _closeEnough(imageBytes, Uint8List.fromList(goldenBytes))) return true;
    return super.compare(imageBytes, golden);
  }

  static Future<bool> _closeEnough(Uint8List a, Uint8List b) async {
    final pa = await _rgba(a);
    final pb = await _rgba(b);
    if (pa == null || pb == null || pa.$1 != pb.$1 || pa.$2 != pb.$2) return false;
    final x = pa.$3;
    final y = pb.$3;
    for (var i = 0; i < x.length; i++) {
      if ((x[i] - y[i]).abs() > _kChannelTolerance) return false;
    }
    return true;
  }

  static Future<(int, int, Uint8List)?> _rgba(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final image = (await codec.getNextFrame()).image;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final result = data == null ? null : (image.width, image.height, data.buffer.asUint8List());
    image.dispose();
    codec.dispose();
    return result;
  }
}
