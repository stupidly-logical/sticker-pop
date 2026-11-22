# Sticker Pop

A bold, friendly design system for apps. It looks like a scrapbook of bright
paper stickers on cream notebook paper: everything has a thick ink outline
and a hard, blur-free shadow, a few things are tilted, and numbers are
always the biggest, boldest thing on the screen. Light theme only for now.

One token file feeds four libraries, and all four are equals: the same
components with the same states, the same formatting helpers, the same
gallery and Home sample, and the same kinds of tests.

| | Compose | Flutter | SwiftUI | Web |
| --- | --- | --- | --- | --- |
| Path | `packages/android` | `packages/flutter/sticker_pop` | `packages/ios/StickerPop` (manifest at repo root) | `packages/web` |
| Package | `dev.stickerpop:stickerpop` | `sticker_pop` | `StickerPop` | `@sticker-pop/web` |
| Components | 23 | 23 | 23 | 23 (CSS + JS) |
| Formatting helpers | `PopFormat` | `formatInr` … | `PopFormat` | `format.mjs` |
| Gallery + Home sample | `PopGallery`, `PopHomeSample` | `PopGallery`, `PopHomeSample` | `PopGallery`, `PopHomeSample` | `index.html` |
| Demo app | `:sample` module | `example/` | `swift run StickerPopDemo` | the gallery page |
| Shared format cases | JUnit | `flutter test` | XCTest | Node |
| Screenshot tests | Paparazzi | goldens | swift-snapshot-testing | Playwright (CI) |

`parity/components.json` lists every component's name on every platform,
and `tools/check-parity.mjs` fails the build if one is missing anywhere or
lacks a docs page. `parity/format-cases.json` holds the formatting cases
every platform's tests must reproduce exactly.

```
apps/site/                       the docs website (+ the Flutter gallery app)
tokens/sticker-pop.tokens.json   the source of truth (W3C design-token format)
tools/                           token generator, checks, site builder
fonts/                           Bricolage Grotesque variable + OFL licence
docs/                            spec and component state matrix
packages/                        the libraries
```

## Using it from an app

Docs: **https://stupidly-logical.github.io/sticker-pop/**

Each version is a tag (`v0.1.0`) with a GitHub Release. The same tag
publishes the web package to npm and the Flutter package to pub.dev, and
Swift Package Manager installs straight from it. Pin the version so library
changes never reach an app by surprise.

**Flutter**

```sh
flutter pub add sticker_pop     # or in pubspec.yaml: sticker_pop: ^0.1.0
```

```dart
import 'package:sticker_pop/sticker_pop.dart';

MaterialApp(theme: buildPopTheme(), home: …);
```

The package bundles the font. Flutter 3.50+ (it imports
`package:material_ui/material_ui.dart`).

**SwiftUI (iOS 16+, macOS 13+)**: in Xcode, *File › Add Package
Dependencies…*, paste `https://github.com/stupidly-logical/sticker-pop.git`
and pick *Up to Next Major* from `0.1.0`. Or in `Package.swift`:

```swift
.package(url: "https://github.com/stupidly-logical/sticker-pop.git", from: "0.1.0")
```

Call `StickerPopFonts.register()` once at launch.

**Compose (Android)**: add the repo as a git submodule and include it as a
source build (needs JDK 21 and AGP 8.11+):

```sh
git submodule add https://github.com/stupidly-logical/sticker-pop.git third_party/sticker-pop
git -C third_party/sticker-pop checkout v0.1.0
```

```kotlin
// settings.gradle.kts
includeBuild("third_party/sticker-pop/packages/android")

// app/build.gradle.kts
dependencies { implementation("dev.stickerpop:stickerpop:0.1.0") }
```

**Web**: from npm with a bundler, or from jsDelivr with no build step.

```sh
npm install @sticker-pop/web
```

```js
import '@sticker-pop/web/sticker-pop.css';
import { wirePopControls } from '@sticker-pop/web/behaviors.mjs';
wirePopControls();
```

```html
<!-- no build step -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@sticker-pop/web@0.1.0/src/sticker-pop.css">
<script type="module">
  import { wirePopControls } from 'https://cdn.jsdelivr.net/npm/@sticker-pop/web@0.1.0/src/behaviors.mjs';
  wirePopControls();
</script>
<!-- either way: the icon font, and turn the styles on -->
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,500,1,0">
<body class="sp-root sp-paper">
```

Other modules: `format.mjs`, `charts.mjs`, and the tokens as `@sticker-pop/web` (see `packages/web/README.md`).

### Releasing a new version

The version lives in one place, the `VERSION` file. A helper copies it into
everything else (pubspecs, `package.json`, Gradle, the docs site, the install
snippets here and on the site) and bumps the sample apps' build numbers:

```sh
node tools/version.mjs minor     # or patch, major, or an exact version: 0.3.0
# describe the release under its new heading in CHANGELOG.md
bash tools/check.sh
bash tools/publish.sh            # commit, push, tag; CI, Docs and Release run from there
```

Edited `VERSION` by hand? `node tools/version.mjs sync` copies it everywhere.
`node tools/version.mjs check` (run by CI) fails if any place disagrees, and a
release is refused while the changelog section still says TODO.

The first npm and pub.dev release is published by hand once, so the
package exists; after that, CI publishes every tag. See "First release on
the registries" below.

### First release on the registries

npm and pub.dev only let CI publish a package that already exists, so the
very first version goes up by hand, once. Do this before the first
`bash tools/publish.sh`:

1. **npm.** Create a free organisation named `sticker-pop` on npmjs.com (it
   owns the `@sticker-pop` scope), then:
   ```sh
   npm login
   cd packages/web && npm publish --access public
   ```
   On the package's page: Settings › Trusted publisher › GitHub Actions,
   owner `stupidly-logical`, repository `sticker-pop`, workflow `release.yml`.
2. **pub.dev.** Sign in with a Google account when asked:
   ```sh
   cd packages/flutter/sticker_pop && flutter pub publish
   ```
   On pub.dev: sticker_pop › Admin › Automated publishing › enable GitHub
   Actions, repository `stupidly-logical/sticker-pop`, tag pattern `v{{version}}`.
3. **Swift Package Index** (optional, after the repo is public): add the repo
   at https://swiftpackageindex.com/add-a-package.

From then on, every tag publishes both packages from CI with no tokens. A
version that's already on a registry is skipped, so the first tag is fine.

## What belongs in the library, and what belongs in an app

Sticker Pop has the look, the components and general helpers. Anything about
an app's own data stays in the app. For example, which category gets which
icon and colour: the library gives you `CategoryDot(icon:, color:)` and the
rule (repeat colours by meaning, white for "other"), and the app keeps the
mapping. Likewise `PopAmountField` takes a colour, label and currency
symbol instead of knowing about expenses and income.

The formatting helpers (`formatInr`, `formatInrCompact`, `formatPopDate`,
`formatPopMonth`, `formatPopTime`, on every platform) use Indian rupees, Indian digit grouping and 12-hour
times. Apps that need other currencies can format their own amounts; keep
tabular figures and a real minus sign (−).

## Tokens

Edit `tokens/sticker-pop.tokens.json`, then regenerate:

```sh
node tools/build-tokens.mjs           # writes Dart, Kotlin, Swift, CSS, JS, resolved JSON
node tools/build-tokens.mjs --check   # fails if anything generated is stale
```

The generator has no dependencies (Node 18+). Before it writes anything it
checks the rules: weights 600 to 800, text only in ink, muted ink or white,
tilt within ±6°, and at least 4.5:1 contrast for ink on every fill (and for
muted ink on paper and white).

| | Flutter | Compose | SwiftUI | CSS |
| --- | --- | --- | --- | --- |
| Colour | `PopColors.yellow` | `PopColors.yellow` | `PopColors.yellow` | `var(--sp-color-yellow)` |
| Type role | `PopTextSpecs.heroAmount` | `PopTextSpecs.heroAmount` | `PopTextSpecs.heroAmount` | `.sp-text-hero-amount` |
| Spacing | `PopSpace.lg` | `PopSpace.lg` (Dp) | `PopSpace.lg` | `var(--sp-space-lg)` |
| Shadow | `PopShadow.regular` (Offset) | `PopShadow.regular` | `PopShadow.regular` | `var(--sp-shadow-regular)` |
| Gradient | `PopGradients.sunrise` | `PopGradients.sunrise.brush` | `PopGradients.sunrise` | `.sp-fill-sunrise` |
| Motion | `PopMotion.toggle` (Duration) | `PopMotion.toggleMillis` | `PopMotion.toggle` (s) | `var(--sp-motion-toggle)` |

**Gradients** are allowed alongside flat colour, but only from the
`gradient` tokens, which are built from the brights (the build checks ink
contrast at every stop). `StickerCard` and `StickerBadge` take one on every
platform. The three in the file (`sunrise`, `candy`, `lagoon`) are starters
to rename or replace.

**Motion** is still to be designed. The few existing transitions (switch,
sheet, dialog and snackbar fades, tour dots) read their durations from the
`motion` tokens, so animation can be added or retuned in one place later.

## Docs website

`apps/site` is the documentation site: principles; colour, type, spacing and
shape (rendered live from the tokens); content and accessibility guidelines;
a page per component with live demos of each state and code for every
platform; the Home sample; and the Flutter gallery app compiled for the web.

```sh
npm run site        # build tokens + site + Flutter web app, serve on http://localhost:4173
npm run site:fast   # same, without the Flutter app (no Flutter needed)
npm run site:build  # just build dist/site
```

`dist/site` is plain static files with relative paths, so any static host
works (Cloudflare Pages, GitHub Pages, Netlify).

## Checks and CI

```sh
bash tools/check.sh          # everything this machine can build
bash tools/mirror_check.sh   # the same, from a Linux sandbox sharing this folder
```

`check.sh` runs the token check, the parity check, Flutter (analyze, tests,
goldens on Linux), Compose (when `ANDROID_HOME` and JDK 21 are set), SwiftUI
(on macOS with Xcode), the web lint and format tests, and the docs-site
check. A platform it can't build on the current machine is reported as
skipped, never as passed.

`.github/workflows/ci.yml` builds and tests every platform on every push:
Compose and Flutter on Linux, SwiftUI on macOS (including an iPhone
simulator), and web screenshots with Playwright. The first CI run records
the Compose and SwiftUI screenshot references; commit them from the run's
artifacts so later runs verify against them. Flutter's goldens are already
committed (rendered on Linux).

## Versioning

All four libraries share one version (`CHANGELOG.md`). Tag releases as
`vX.Y.Z` so apps can pin them.

## Licence

MIT (`LICENSE`): use it anywhere, including in closed-source apps, as long as
the copyright and licence notice is kept. Bricolage Grotesque is under the
SIL Open Font License (`fonts/OFL.txt`).
