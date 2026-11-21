#!/usr/bin/env bash
# Runs every check: generated tokens up to date, then the Flutter package
# (analyze + tests) and the web package's lint. Run from the repo root.
#
#   bash tools/check.sh
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== tokens"
node tools/build-tokens.mjs --check

echo "== versions"
node tools/check-version.mjs

echo "== parity"
node tools/check-parity.mjs

echo "== flutter: sticker_pop"
(
  cd packages/flutter/sticker_pop
  flutter pub get >/dev/null
  flutter analyze --no-fatal-infos
  # Goldens were rendered on Linux; macOS text rendering differs slightly.
  # Set GOLDENS=1 to force them, or refresh with --update-goldens.
  if [ "$(uname)" = "Linux" ] || [ "${GOLDENS:-0}" = "1" ]; then
    flutter test --exclude-tags qa
  else
    flutter test --exclude-tags golden,qa
  fi
  # Layout QA: every sample screen at 320/390/768 wide and 100/130/200% text;
  # fails on any overflow. Screenshots land in test/qa/shots (git-ignored).
  flutter test --tags qa --update-goldens test/qa
)

if [ -d packages/flutter/sticker_pop/example ]; then
  echo "== flutter: example"
  (
    cd packages/flutter/sticker_pop/example
    flutter pub get >/dev/null
    flutter analyze --no-fatal-infos
  )
fi

echo "== android (compose)"
if [ -n "${ANDROID_HOME:-}" ] && command -v java >/dev/null; then
  (
    cd packages/android
    [ -f local.properties ] || echo "sdk.dir=$ANDROID_HOME" > local.properties
    # Android's screenshot renderer has no ARM Linux build: there, run the
    # unit tests only and leave screenshots to macOS and x86 Linux (CI).
    if [ "$(uname -s)-$(uname -m)" = "Linux-aarch64" ]; then
      ${GRADLE:-./gradlew} -q --no-daemon :stickerpop:compileDebugKotlin :stickerpop:testDebugUnitTest --tests 'dev.stickerpop.PopFormatTest'
      echo "compose: compiled; format tests passed; screenshots skipped on ARM Linux"
    else
      ${GRADLE:-./gradlew} -q :stickerpop:testDebugUnitTest :stickerpop:verifyPaparazziDebug :sample:assembleDebug
      echo "compose: compiled; tests and screenshots passed; sample app built"
    fi
  )
else
  echo "compose: skipped (set ANDROID_HOME and install JDK 21 to include it)"
fi

echo "== ios (swiftui)"
if [ "$(uname -s)" = "Darwin" ] && command -v swift >/dev/null; then
  swift build && swift test
else
  echo "swiftui: skipped (needs macOS with Xcode; runs in CI)"
fi

echo "== web"
node packages/web/scripts/check.mjs
node packages/web/scripts/test-format.mjs

echo "== docs site"
node tools/check-site.mjs

echo "All checks passed."
