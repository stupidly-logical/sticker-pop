# Changelog

All four libraries share one version.

## 0.1.0 (2026-11-21)

- First release: Compose, Flutter, SwiftUI and web libraries at parity: 23
  components each, formatting helpers checked against shared cases, a
  gallery and Home sample per platform, screenshot tests per platform, the
  docs site, and CI for all four.
- Select (dropdown) and Menu on all four platforms. Select opens a sheet
  list on phones and a popover list on the web (built on a native
  `<select>`, so forms keep working); Menu is a sticker popover of actions.
  SwiftUI adds `.popOverlayHost()` so sheets and menus draw above the screen.
- Fill and gradient classes on the web (`.sp-fill-*`) live in a generated
  `fills.css` loaded after the components, so they always win.
- Add menu (design preview, web first): the nav add button can open a
  speed dial (fan or stack) with motion tokens, reduced-motion support and
  keyboard access. Compose, Flutter and SwiftUI follow.
- The nav add slot fits the tilted button and its shadow, so it never
  overlaps its neighbours on a 320 wide phone (all four platforms).
- Progress bars have a straight ink leading edge on every platform.
