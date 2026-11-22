# Contributing to Sticker Pop

Thanks for helping. Sticker Pop is one design system shipped as four
libraries (Compose, Flutter, SwiftUI and the web) that are kept equal. Most
of this guide is about keeping them that way.

Before you start, skim the [README](README.md), then
[`docs/spec.md`](docs/spec.md). The spec is the source of truth for the look:
its numbers are not suggestions.

## Ways to help

- **Report a bug or a visual glitch.** Open an issue with the platform,
  the version, what you expected and a screenshot. If it only happens at a
  large text size or on a small screen, say which.
- **Suggest a component.** Open an issue first and describe where it's
  used. A new component lands on all four platforms at once, so it's worth
  agreeing on its states and parameters before anyone writes code.
- **Fix something.** Small fixes can go straight to a pull request.

## Set up

Clone the repo, then install what you need for the platforms you'll touch:

| Platform | Needs | Lives in |
|---|---|---|
| Tokens, web, docs site | Node 22 | `tokens/`, `packages/web`, `apps/site` |
| Flutter | Flutter 3.50 or later | `packages/flutter/sticker_pop` |
| Compose | JDK 21 and the Android SDK (`ANDROID_HOME` set); Gradle comes with the wrapper | `packages/android` |
| SwiftUI | macOS with Xcode 16 (iPhone 16 simulator) | `packages/ios/StickerPop`, manifest in `Package.swift` |

Then, from the repo root:

```sh
bash tools/check.sh
```

This is the one command that matters. It checks the generated tokens, the
version, the parity between platforms, Flutter (analysis, tests, a layout
check at large text sizes, and screenshot tests on Linux), Compose (compile and the
shared formatting tests), SwiftUI (on a Mac), the web lint and formatting
tests, and the docs site. It skips a platform whose tools aren't installed
and says so. **A change is done when it passes**, and CI runs the same
checks plus the screenshot tests for every platform.

To look at your work:

```sh
npm run site:fast                                  # docs site on http://localhost:4173
cd packages/flutter/sticker_pop/example && flutter run
cd packages/android && ./gradlew :sample:installDebug
swift run StickerPopDemo                           # Mac window with the gallery
```

## The rules

These are checked in review, and many of them by the checks too.

**Tokens come from one file.** Edit `tokens/sticker-pop.tokens.json`, then
run `node tools/build-tokens.mjs`. Never edit the generated files
(`*.g.dart`, `PopTokens.kt`, `PopTokens.swift`, `packages/web/src/tokens.*`,
`fills.css`). Components use tokens only: no colours, sizes or durations
typed in by hand. Animation durations come from the `motion` tokens.

**All four platforms are equals.** A component change lands on Compose,
Flutter, SwiftUI and the web in the same pull request, with the same
parameters and states. If you can only work on some platforms, open the
pull request anyway and say which are missing, and a maintainer will help.

**The look.**

- Everything has an ink outline. No 1px or borderless surfaces.
- Shadows are hard, with zero blur.
- Fills are flat. Gradients only come from the gradient tokens.
- Text is ink on every fill, and white only on ink.
- Colour never carries meaning alone, and red is never used: errors are orange plus a message.
- Font weights are 600 to 800 only.
- Tilt is at most ±6° (cards ±3°), and never on lists, inputs or long text.
- One primary button per view.
- Tap targets are at least 48.

**Accessibility is part of the component.** Every control has a label
that screen readers read, reports its state (selected, on/off, disabled),
works with a keyboard on the web, and still fits at 200% text on a 320-wide
screen. Motion respects the reduce-motion setting.

**Keep it app-agnostic.** No product names, app IDs or app-specific data.
Those belong in the apps that use the library (the README has a section on
this).

**Money is `int` paise.** Format it with `formatInr` and
`formatInrCompact`. A formatting change adds a case to
`parity/format-cases.json`, and that case must pass on all four platforms.

## Adding or changing a component

Use this checklist. It's the same one every existing component went
through.

- [ ] **Flutter:** `lib/src/components/<name>.dart`, exported from `lib/sticker_pop.dart`
- [ ] **Compose:** `stickerpop/src/main/kotlin/dev/stickerpop/components/<Name>.kt`
- [ ] **SwiftUI:** `Sources/StickerPop/Components/<Name>.swift`
- [ ] **Web:** CSS in `packages/web/src/components.css`, plus any behaviour in `behaviors.mjs` (wired from `wirePopControls`)
- [ ] **Galleries:** a section in the Flutter, Compose, SwiftUI and web galleries, and the Home sample if it's relevant
- [ ] **Docs site:** an entry in `apps/site/content/c-*.js` with code for all four platforms, the spec table, rules and accessibility notes
- [ ] **Parity:** an entry in `parity/components.json` naming each platform's API
- [ ] **Spec:** `docs/spec.md` and the states table in `docs/components.md`
- [ ] **Tests:** at least a Flutter widget test for its behaviour, and the screenshot images updated (below)
- [ ] **Changelog:** a line under `## Unreleased` in `CHANGELOG.md`
- [ ] `bash tools/check.sh` passes

## Screenshot tests

Each platform compares its gallery and Home sample against saved images.
If your change alters how something looks on purpose, update the images in
the same pull request and say so in its description.

- **Flutter.** The images are recorded on Linux, because macOS draws text
  slightly differently and would fail CI. That's why `check.sh` skips them
  on a Mac. On Linux, run this in `packages/flutter/sticker_pop`:
  ```sh
  flutter test --tags golden --update-goldens test/goldens
  ```
  On a Mac, push instead. CI's Flutter job fails and attaches a
  `flutter-golden-failures` artifact, whose `*_testImage.png` files are the
  new images. Tiny rounding differences between Linux machines are
  tolerated.
- **Compose.** Run this in `packages/android`:
  ```sh
  ./gradlew :stickerpop:recordPaparazziDebug
  ```
  The renderer doesn't run on ARM Linux. If you can't record locally,
  push and download the `compose-screenshots-and-sample` artifact from the
  CI run.
- **SwiftUI.** Run this from the repo root on a Mac:
  ```sh
  SNAPSHOT_RECORD=1 xcodebuild test -scheme StickerPop-Package \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing StickerPopTests/ScreensTests
  ```
- **Web.** CI screenshots the docs-site gallery and attaches the images to
  the run for review.

Look at the new images before committing them. The gallery images are tall,
and you should check that the last section (Navigation) is still in them. If
it isn't, the gallery outgrew its screen, so raise the height in the
screenshot test.

## Pull requests

- Keep each pull request to one change, and describe what it changes for
  someone using the library.
- Add a line under `## Unreleased` in `CHANGELOG.md`. Write it in plain
  words, for app developers.
- Don't change the version. The maintainer sets it when releasing.
- CI must pass. If you couldn't test a platform (for example SwiftUI
  without a Mac), say so rather than ticking it off.
- Write commit messages that say what changed and why, in the present
  tense.

## Releasing (maintainers)

The version lives only in the `VERSION` file:

```sh
node tools/version.mjs patch     # or minor, major
# turn "## Unreleased" into the release notes in CHANGELOG.md
bash tools/check.sh
bash tools/publish.sh
```

The tag publishes to npm, pub.dev and Maven Central from CI, and Swift
Package Manager installs from the tag. The README's "Releasing a new
version" section has the details.

## Licence

By contributing, you agree that your work is released under the
[MIT licence](LICENSE), like the rest of Sticker Pop.
