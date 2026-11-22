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
- Loading states: skeleton lines, circles, blocks and lists, and a spinner,
  on all four platforms; still under reduced motion.
- Date tiles and a month-calendar date picker on all four platforms.
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
