#!/usr/bin/env bash
# Runs tools/check.sh from a Linux sandbox that shares this folder with a
# Mac (such as the Claude desktop app's VM). It works on a private copy, so
# the Mac's .dart_tool/ and build/ never get Linux paths. Installs Flutter
# on first run.
#
#   bash tools/mirror_check.sh            # everything
#   bash tools/mirror_check.sh test/x.dart  # analyze, then only these Flutter tests
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
DST="${MIRROR_DIR:-$HOME/work/sticker-pop}"
SDK_ROOT="${SDK_ROOT:-$HOME/sdk}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.50.0}"

if [ ! -x "$SDK_ROOT/flutter/bin/flutter" ]; then
  echo "Installing Flutter $FLUTTER_VERSION into $SDK_ROOT/flutter"
  git clone -q --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$SDK_ROOT/flutter"
fi
export PATH="$SDK_ROOT/flutter/bin:$PATH"
# JDK 21 + Android SDK, when installed alongside Flutter.
if [ -f "$SDK_ROOT/env.sh" ]; then . "$SDK_ROOT/env.sh"; fi
flutter config --no-analytics >/dev/null 2>&1 || true

mkdir -p "$DST"
rsync -a --delete \
  --exclude .dart_tool --exclude build --exclude .idea --exclude _to_delete \
  --exclude '.flutter-plugins*' --exclude node_modules \
  --exclude '**/android/.gradle' --exclude local.properties --exclude .gradle --exclude '**/ios/Pods' --exclude '.build' \
  "$SRC/" "$DST/"
cd "$DST"

if [ $# -gt 0 ]; then
  cd packages/flutter/sticker_pop
  flutter pub get >/dev/null
  flutter analyze --no-fatal-infos
  flutter test "$@"
else
  bash tools/check.sh
fi
