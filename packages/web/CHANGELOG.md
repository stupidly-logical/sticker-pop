# Changelog

All four libraries share one version.

## 0.1.1 (2026-11-22)

- SwiftUI now builds: 0.1.0 didn't compile (a gallery property declared
  twice, and a toggle accessibility trait that needs iOS 17 / macOS 14).
  The switch adds that trait only where it exists, so iOS 16 and macOS 13
  still work. If you added the package at 0.1.0, move to 0.1.1.
- The SwiftUI demo app is no longer offered to apps as a library product
  (`swift run StickerPopDemo` still works in the repo).
- Compose is on Maven Central as `io.github.stupidly-logical:stickerpop`
  (the Kotlin package is still `dev.stickerpop`). Building it from source
  now needs Gradle 9.1+ and AGP 8.13+.
- Web is on npm as `@sticker-pop/web`; its import paths now match the docs
  (`@sticker-pop/web/behaviors.mjs` and friends) and the CDN snippets use
  jsDelivr's npm mirror.
- Flutter is on pub.dev as `sticker_pop`.
- Every tag now publishes npm, pub.dev and Maven Central from CI, and the
  Compose and SwiftUI screenshot tests compare against recorded images.

## 0.1.0 (2026-11-21)

- First release: Compose, Flutter, SwiftUI and web libraries at parity: 23
  components each, formatting helpers checked against shared cases, a
  gallery and Home sample per platform, screenshot tests per platform, the
  docs site, and CI for all four.
- Select (dropdown) and Menu on all four platforms. Select opens a sheet
  list on phones and a popover list on the web (built on a native
  `<select>`, so forms keep working); Menu is a sticker popover of actions.
  SwiftUI adds `.popOverlayHost()` so sheets and menus draw above the screen.
- Loading states: skeleton lines, circles, blocks and lists, and a spinner,
  on all four platforms; still under reduced motion.
- Date tiles and a month-calendar date picker on all four platforms.
- Pagination (page numbers with a 7-slot rule, or "Page n of m" where narrow)
  on all four platforms.
- Pull to refresh (sticker indicator with a filling ring, then a spinner) on
  all four platforms; SwiftUI uses the system gesture tinted ink.
- Date range picker (start and end joined by a mint band, inline or in a
  sheet with Done) on all four platforms; on the web, `mountPopCalendar`
  takes `range: true`.
- Attachment tile (dashed pick tile, then a file row with remove) on all four
  platforms; the web one wraps a native file input.
- PIN entry (with the keypad) on all four platforms.
- Tag input (removable chips in a field) on all four platforms.
- Tooltip (ink bubble above an ⓘ) on all four platforms.
- Expandable card on all four platforms (a native details element on the web).
- Stat tile (label, figure, change badge coloured by meaning) on all four
  platforms.
- Empty and error screens on all four platforms.
- Avatar (initials, colour from the name with the same rule everywhere) on all
  four platforms.
- Number keypad and the `applyPopKey` amount helper on all four platforms.
- Stepper (− value +) on all four platforms.
- Slider (sticker knob on the progress-bar track) on all four platforms.
- Settings row (value and chevron, or a switch) on all four platforms.
- Banner (info, warning, success; action and dismiss) on all four platforms.
- Tabs (selected tab in a yellow pill) on all four platforms.
- Search field (icon, clear ✕, optional Cancel) on all four platforms.
- Top app bar (compact and large) on all four platforms, with a scrolled
  state: paper fill and an ink line once content scrolls under it.
- Checkbox and radio (with tappable rows) on all four platforms; on the web
  they are styled native inputs.
- Fill and gradient classes on the web (`.sp-fill-*`) live in a generated
  `fills.css` loaded after the components, so they always win.
- Add menu (design preview, web first): the nav add button can open a
  speed dial (fan or stack) with motion tokens, reduced-motion support and
  keyboard access. Compose, Flutter and SwiftUI follow.
- The nav add slot fits the tilted button and its shadow, so it never
  overlaps its neighbours on a 320 wide phone (all four platforms).
- Progress bars have a straight ink leading edge on every platform.
