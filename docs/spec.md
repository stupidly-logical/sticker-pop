# Sticker Pop specification

Sticker Pop is a standalone, bold, friendly design system for mobile-first apps (Android, iOS and the web). It began in an expense tracker, which is why its examples are about money, but nothing in it is tied to one product. Treat these numbers as the spec, not as suggestions. Units are density-independent pixels (dp/pt). The system is light only; there is no dark theme yet.

## 1. Character

Sticker Pop looks like a scrapbook of bright paper stickers stuck on cream notebook paper. Every surface has a thick black outline and a hard, blur-free drop shadow offset down and to the right, so it reads as a cut-out lifted off the page. A few elements sit slightly tilted, as if stuck on by hand. Colours are bold and cheerful, flat by default with gradients where they add something; type is chunky and confident. The mood is warm, playful and trustworthy at the same time: apps built with it often handle things people care about, like money, so playfulness lives in shape and colour, never in unclear numbers or words.

Principles:
- **Outline everything.** Every card, button, chip, input and badge has a solid ink outline. No borderless floating surfaces, no hairlines.
- **Hard shadows only.** Shadows are solid ink (or pink, on the primary button) with zero blur, offset to the bottom right. Never soft or blurred shadows, never elevation tints.
- **Flat colour first, gradients from tokens.** Flat fills are the default. Gradients are allowed when they come from the gradient tokens, which are built only from the brights, so ink text stays readable at every stop. Outlines and hard shadows still apply to gradient stickers. No glassmorphism, transparency effects or textures, apart from the paper dot grid behind screens.
- **Ink on colour.** Text on any colour fill is always ink black. White text only appears on ink (the primary button, snackbars).
- **Numbers first.** Amounts are the largest, boldest thing on a screen, with tabular figures.
- **A little tilt, sparingly.** Tilt is a garnish: badges, a hero card, the add button. Most cards stay straight.

## 2. Colour tokens

Neutrals:

| Token | Hex | Use |
| --- | --- | --- |
| `paper` | `#FFF3D6` | Screen background (cream), sheets, dialogs |
| `paperDot` | `#EBD9A6` | Dot grid on the paper background |
| `ink` | `#141414` | All text, outlines, hard shadows, primary button fill, snackbars |
| `inkMuted` | `#4A4A4A` | Secondary text, labels, hints, inactive nav icons, disabled button fill |
| `white` | `#FFFFFF` | Default card and input fill, nav bar, unselected chips and segments |
| `divider` | `#E3D3A6` | 2px lines between rows inside a card |

Brights (fills for cards, chips, badges, category dots and charts; never for text):

| Token | Hex | Typical role |
| --- | --- | --- |
| `yellow` | `#FFD43B` | Hero cards (a headline figure), selected nav pill, default selected chip, tour cards, snackbar action text |
| `pink` | `#FF6FAE` | Add button, primary button shadow, selected segment, voice/mic, progress dots |
| `blue` | `#8DB8FF` | Info cards and neutral highlights |
| `mint` | `#5EE0A8` | Positive and success states, switches on |
| `lilac` | `#C3AEFF` | Hints and empty states |
| `orange` | `#FF9C5B` | Warnings and needs-attention states |

Rules:
- Text on every bright, on white and on paper is `ink`; this keeps contrast at or above 4.5:1 everywhere. `inkMuted` on paper or white is for secondary text only.
- Money in and out is not colour-coded red/green. Direction is shown with words, signs (+/−) and ▲/▼ glyphs in ink. Colour supports meaning but never carries it alone.
- Gradients: use the `gradient` tokens (currently `sunrise` yellow→orange, `candy` pink→lilac, `lagoon` blue→mint, all at 135°; these are starters to replace). Every stop must be a palette bright; the token build checks ink contrast at every stop. Gradients fill cards, tiles and badges; text is never a gradient, and the primary button stays ink.
- Apps that colour their own kinds of thing (categories, account types, tags) repeat colours by meaning, so the same kind of thing always gets the same colour, and use white for "other". That mapping belongs to the app.

## 3. Typography

- **Typeface:** Bricolage Grotesque (Google Fonts, SIL Open Font License), one variable font for everything. Set the `wght` axis to match the weight.
- **Weights in use:** 600 (body), 700 (labels, secondary emphasis), 800 (titles, numbers, buttons, anything selected). Nothing lighter than 600.
- **Figures:** tabular figures for all amounts and anything in columns.
- **Case:** sentence case everywhere. ALL CAPS only for small section labels and badges, with +0.6 letter spacing.

Type scale (size / weight / letter spacing):

| Role | Spec |
| --- | --- |
| Welcome title | 44 / 800 / −1.5 |
| Screen title ("Home", "Wealth") | 34 / 800 / −1 |
| Hero amount (a headline figure) | 40 / 800, tabular |
| Amount entry with ₹ prefix | 32 / 800 |
| Sub-screen title (with back button) | 30 / 800 / −1 |
| Big figure in a card | 28 / 800 |
| Sheet or card title | 22 / 800 |
| Section heading | 20–22 / 800 |
| Primary button label | 18 / 800, white on ink |
| Row title | 16 / 800 |
| Input text | 16–17 / 700 |
| Body | 15 / 600 |
| Chip, segment, small button text | 14–15 / 700, selected 800 |
| Secondary line, caption | 13 / 600 in `inkMuted` |
| Section label (e.g. "NET WORTH", "PHONES") | 13 / 800 / +0.6, caps |
| Nav label | 12 / 700, selected 800 |
| Badge | 11–13 / 800 |

## 4. Spacing, shape and depth

- **Spacing scale:** 4, 8, 12, 16, 20, 24 (`xs` to `xxl`). Screen side padding is 20. Card padding is 16. The gap between cards is 16; between sections, 20–24.
- **Outlines:** 2.5 for cards, buttons, inputs, segmented controls, switches and the nav bar top edge. 2 ("thin") for chips at rest, badges, category dots and switch knobs.
- **Corner radius:**
  - cards 22
  - primary button 20
  - add button 20
  - tiles and segmented controls 18
  - pills and chips 19 (fully rounded at their 40 height)
  - text fields 14
  - badges 10
  - bottom sheets 24 (top corners only)
  - snackbars 16
  - the spotlight cut-out 18
- **Hard shadows** (solid, zero blur, offset x = y):

  | Size | Offset | Used on |
  | --- | --- | --- |
  | small | 3 | Icon buttons, date tiles |
  | default | 4 | Cards and the primary button |
  | large | 6 | Hero cards, dialogs, tour cards |
  | 2 | 2 | Selected chips |
  | none | 0 | Rows inside a card, segments, inputs |

- **Tilt:** rotate up to ±3° for cards (hero and tour cards alternate −1.5° / +1.5°). Badges can tilt −4° and the add button −6°. Never tilt text-heavy cards, lists or inputs.
- **Background:** every screen sits on `paper` with a dot grid: dots of radius 1.3 in `paperDot`, every 18, offset by half a step.

## 5. Components

**StickerCard.** White (or a bright) fill, 2.5 ink outline, radius 22, default 4/4 ink hard shadow, padding 16. Variants: hero card (yellow, large shadow, optional slight tilt) and info card (blue, lilac or mint).

**Avatar.** People, payees and shared accounts: up to two initials (first letters of the first and last words) in 800 at 38% of the size, in a bright circle with a 2 ink outline and no shadow. Sizes 32, 42 (default) and 56; the initials don't grow with system text size. The colour comes from the name: the sum of its UTF-16 code units modulo yellow, pink, blue, mint, lilac, orange, the same on every platform. Categories use the category dot, not an avatar.

**StickerList.** A StickerCard with no padding (so a selected row's fill reaches the outline) holding rows separated by 2px `divider` lines. Each row:
- 16 horizontal and 10–12 vertical padding, minimum height 52
- a 42 round category dot, title 16/800 and a 13/600 muted second line
- the amount right-aligned, 16/800 tabular

**Primary button (StickerButton).**
- full width, height 58, radius 20
- `ink` fill, 2.5 ink outline, a 4/4 **pink** hard shadow
- label 18/800 white
- disabled: `inkMuted` fill
- one primary button per screen or sheet, at the bottom

**Text button.** Secondary actions ("Cancel", "Skip", "Remove", "Show more") are plain ink text, 15–16 / 700–800. No outline, optionally underlined at 2 thickness.

**PopIconButton.** 46 circle, white (or a bright) fill, 2.5 ink outline, 3/3 ink shadow, 22 icon in ink. Used for back, settings and close.

**Checkbox.** A 24 rounded square, radius 7, padded to a 48 tap target. Off: white with a 2 ink outline. On: mint with a 2.5 outline and an ink tick (2.6 stroke, round ends). Some but not all: mint with an ink dash. Disabled: `paper` (or `divider` when on) with an `inkMuted` mark. Usually a row: the box, then a 16/700 label and an optional 13/600 caption, 52 min height, the whole row tappable. Use a switch for settings that apply at once.

**Radio.** A 24 circle padded to 48. Off: white, 2 ink outline. Chosen: yellow, 2.5 outline, a 10 ink dot. Rows as for the checkbox. For a short list that should all stay visible; a segmented control for two to five short options, a select for many.

**PopChip (selectable pill).**
- min height 40, padding 14 horizontal by 6 vertical, radius 19
- at rest: white with a 2 outline, 14/700 text
- selected: a bright fill (yellow by default), a 2.5 outline, a 2/2 ink shadow and 800 text
- optional leading 16 icon; removable chips get a trailing 16 "×"

**PopSegmented ("Expense | Income | Transfer").**
- white, 2.5 outline, radius 18, segments 44 high
- dividers between segments are 2.5 ink vertical lines
- the selected segment fills with a bright (pink by default), 15/800; the others are white 15/700

**PopSwitch.**
- 52 by 30 track, radius 15, 2.5 outline
- off: white; on: `mint`
- knob: 21 white circle with a 2 outline
- slides in 150 ms

**Text field.** White, 2 ink outline, radius 14, 12 horizontal padding, borderless input inside. Value 16–17/700; hint in `inkMuted` 16/600. Hero amount fields sit inside a yellow (expense), mint (income) or pink (taking money out) card with a "₹" prefix in the same size.

**PopFieldRow (inside a details card).** A 76-wide label column in 14/700 `inkMuted`, the value on the right, min height 52, and a 2px `divider` under each row. Optional chevron.

**StickerBadge.** Fill white or a bright, 2 outline, radius 10, padding 9 by 2, 11–13/800, tilted −4° by default. Used for short tags such as "UPI", "Unsure", percentages and "COMING SOON".

**Category dot.** A 42 circle in a bright (chosen by the app, by meaning), 2 ink outline, icon at 48% of the size in ink, tilted −5°.

**Tabs.** For switching between views of one screen. Labels in 15/700 `inkMuted` with no fill; the selected tab sits in a yellow pill (radius 19) with a 2 ink outline and 15/800 ink text. Tabs are 40 high (at least 48 wide), 16 side padding, 4 apart, and the row scrolls sideways when it doesn't fit. Bottom navigation moves between sections; a segmented control is for two or three equal choices in a form.

**Top app bar.** Compact, for sub-screens: 64 high, 20 side padding, a back icon button (46) then 12 before a one-line 22/800 title, and up to two trailing icon buttons 8 apart (more go in a menu). Large, for main screens: the 34/800 screen title (up to two lines) at the top of the scrolling content, with the actions on the right. Transparent over the paper at rest; when content scrolls under it, it fills with `paper` and draws a 2.5 ink line along its bottom (150 ms fade). Never tilted.

**Bottom navigation bar.**
- white, a 2.5 ink line on top only, padding 8 by 10
- five slots: Home, Activity, (Add), Insights, Wealth; minimum tap target 48
- each item: a 22 icon over a 12 label
- the selected icon sits in a small yellow pill (radius 12, 2 outline, 10 by 2 padding); selected text is ink 800, others `inkMuted` 700
- **Add button**, centred: a pink StickerCard, radius 20, padding 13, default shadow, tilted −6°, holding a 28 "+" icon
- the add slot is as wide as the button plus 8 each side and 4 more on the right for the shadow; the four items share the rest
- **Add menu (optional, design preview: web first).** Instead of one action the add button can open a menu of 1 to 4 ways to add (for example Type it, Say it, Scan it). Open: a paper scrim (paper at 88%) fades in over the screen and the other nav items (200); the "+" spins 45° into "×" and the button straightens to 0° (280, pop easing); each option, a 56 sticker (radius 18, 2.5 outline, 4/4 shadow, a bright fill, 26 icon) with a white 13/800 label badge under it, flies out from behind the button, grows from 40% to 100% and settles at a slight tilt (−3°, +2°, −2°), 40 apart (280, pop easing). Options sit on an arc (fan: 120° wide, 96 to each side, the middle one highest) or in a column (stack: 76 apart, labels on the left). Choosing presses the option into its shadow (90), then everything closes in reverse with ease-in (180, 20 apart). Pop easing is cubic-bezier(0.34, 1.56, 0.64, 1). Reduced motion: options and scrim only fade (150). The button reads "Add transaction" / "Close add menu"; focus moves into the menu; arrows move between options; Escape, back or a tap outside closes it.

**Quick-add row (Home).** Three equal tiles in a row, 12 apart: "Type it" (white, −1.5°), "Say it" (pink, +1.5°) and "Scan it" (mint, −1°). Each is a StickerCard with 12 vertical padding, a 26 icon over a 15/800 label.

**Search field.** A text field (white, 2 outline, focus 2.5, radius 14, 48 high) with a 22 ink search icon 8 before the text, and a 20 ✕ in a 40 target that clears it while it has text. On a search screen a "Cancel" text button sits 12 after it. Filter as people type; there is no search button.

**Date tiles and date picker.** Tiles are quick picks for recent days: 56 × 68 white stickers, radius 18, 2 outline, 3/3 shadow, the weekday in 13/800 muted caps over the day in 20/800 tabular ("Today" for today); the chosen tile is yellow with a 2.5 outline. A last tile with a calendar icon opens the date picker: a month calendar (in a bottom sheet on phones) with the month and year in 20/800 and previous / next icon buttons, weekday initials, and 40 day circles in 16/700. The chosen day is yellow with a 2.5 outline and 800 text; today has a 2 ink ring; days outside the allowed range are muted. Weeks start on Monday unless set otherwise.

**Tag input.** Free-form tags in a text-field box (white, 2 outline, focus 2.5, radius 14, 48 min height): removable chips 8 apart, wrapping, then an inline 16/700 text field at least 120 wide. Enter or a comma adds a tag; backspace in an empty field removes the last; duplicates are skipped regardless of case. For a fixed set of choices, use chips or a select.

**Select (dropdown).** For picking one of six or more options, or options with long names (two to five short ones: a segmented control or chips). The field looks like a text field (white, 2 outline, radius 14, 48 min height) with the chosen option in 16/700 (the hint in `inkMuted` 16/600), an optional 22 icon before it and a 22 chevron at the end; open, focused and error states use the 2.5 outline. On phones it opens a bottom sheet titled with the field label, listing the options in a sticker list: rows 52 high, an optional 22 icon and 13/600 caption, the chosen row yellow edge to edge with a tick and 800 text. On the web the same rows appear in a menu popover under the field, as wide as the field. Never tilted.

**Menu.** A short popover of actions for a row or a screen, opened from a "more" icon button. A white sticker: 2.5 outline, radius 16, 4/4 shadow, 6 padding top and bottom, 180 to 280 wide and never closer than 8 to the screen edge. Rows are 48 high with 16 side padding, a 22 icon and a 15/700 label; the row under the finger, pointer or keyboard focus fills yellow edge to edge. Groups are separated by a 2 divider with 6 above and below. A destructive action goes last after a divider, in 800 ink, never red, and is confirmed with a dialog or Undo. The menu opens below its button with the right edges lined up and flips above when there is no room; it fades and grows from 96% over 150 ms (fade only with reduced motion). Escape, back or a tap outside closes it and returns focus to the button.

**Slider.** For a number in a range, like a budget limit. The track is the progress bar (white, 18 high, radius 9, 2 ink outline) filled mint up to the knob's centre; the knob is a 28 white circle with a 2.5 outline (3 when focused) and a 3/3 shadow; 48 tall to touch. Always show the exact value in text next to the label, and step in sensible units (₹500).

**Number keypad.** For typing amounts under the amount field, in place of the system keyboard: a 3 × 4 grid, 8 apart, of white keys (56 high, radius 18, 2 outline, 3/3 shadow) holding 1–9, ".", 0 and a backspace icon; digits 26/800 tabular. A key presses 3/3 into its shadow, with a light haptic tick on phones. A shared helper (`applyPopKey`) keeps one decimal point, at most two decimal places and no leading zeros.

**Stepper.** A small counter: two PopIconButtons (− and +) with the value between them in 20/800 tabular figures, at least 48 wide. Each button disables at its limit. For small whole numbers only.

**Settings row.** A row for settings lists, inside a StickerList: 52 min height, 16 left padding, an optional 22 ink icon, a 16/700 title with an optional 13/600 muted subtitle, then either a PopSwitch (tapping the row flips it), or the current value in 16/700 muted and a 26 chevron when the row opens something. The whole row is the tap target.

**Expandable card.** A StickerCard with no padding: a header row (52 min height, 16/800 title, optional 13/600 subtitle, a 26 chevron that turns 180°) and a body with 16 padding under a 2 divider that slides open in 250 ms (instant with reduced motion). For FAQs, breakdowns and details most people won't need; stack them 12 apart.

**Tooltip.** A one-sentence explanation in an ink bubble (radius 10, 12 × 8 padding, up to 260 wide, 13/700 white) 8 above an ⓘ icon (22 in a 48 target), kept on screen. It shows on a tap or long-press on phones and on hover or keyboard focus on the web, and hides after 3 s. No links or buttons inside; screen readers get the text as the trigger's description.

**Banner.** A message that stays in the page until it is dealt with: a StickerCard in blue (information), orange (needs attention) or mint (good news), never red. 16 left and 12 top and bottom padding; a 22 ink icon, 12 before an optional 16/800 title and the 15/600 message; an optional underlined text-button action; an optional 20 ✕ in a 40 target. One per screen, at the top of the content. A snackbar is for passing confirmations.

**Empty and error screens.** For a whole screen with nothing to show yet, or one that couldn't load: a 96 tile (radius 22, 2.5 outline, 6/6 shadow, tilted −4°) with a 44 ink icon, lilac for empty and orange for errors or offline; then 24 below a 22/800 title, 8 below a 15/600 muted message, both centred; then a primary button and an optional text button. Up to 340 wide, centred. Say what will appear and how to start, or what went wrong and what to do.

**Loading states.** Skeletons show the shape of what is coming: `divider`-coloured lines (14 high, radius 6), circles (42) and blocks (radius 22), with no outline, pulsing from full to 55% opacity and back over 900 ms each way. A skeleton list mirrors StickerList rows. A spinner, for short waits with no layout to hint at, is a 24 ring with a 3 `divider` track and an ink quarter arc turning once per 800 ms. Under reduced motion both stand still. A group of skeletons is announced once as "Loading". Show either only past about 300 ms; a working button uses its busy label instead.

**Bottom sheet.** `paper` fill, a 2.5 ink line on top only, top radius 24, padding 20 (24 at the bottom), up to 90% of the screen height. Title 22/800, then content, then the primary button last. Form errors appear inline in 14/800 ink directly above the primary button, never in a snackbar.

**Dialog.** A StickerCard on `paper` with the large 6/6 shadow and 20 inset from the screen edges. Title 22/800, body 15/600, the primary button, then a "Cancel" text button.

**Snackbar.**
- floating, ink fill, radius 16, text 15/700 white
- the action label ("Undo") is yellow
- shown for 3 s, or 6 s with an action
- only for "Saved" and "Deleted · Undo"-style confirmations

**Stat tile.** A headline number on a dashboard: a StickerCard (white or a bright) with a 13/800 caps label, a 28/800 tabular figure on one line, an optional change badge ("+3.1%", "−8%" with a real minus), and an optional 13/600 caption. The badge is mint when the change is good and orange when it isn't, whichever way it points. Usually two side by side, with compact amounts.

**Progress bar (goals, budgets).** White track 18 high with a 2 ink outline and radius 9; the fill is a bright colour, clipped by the track to radius 7, with a straight 2 ink line at its leading edge (none at 0% or 100%).

**Charts.**
- Donut: one bright per slice, outlined in 2.5 ink, with a yellow centre disc.
- Bars: bright fills with ink outlines.
- Legends: 12 square swatches with a 1.5 outline and radius 4, label 14/700, percentage 14/800 tabular.
- No gridlines, gradients or 3D.

**Tour (coach marks).**
- the screen dims under an ink scrim at about 72% opacity, with a rounded cut-out (radius 18) around the real control
- the cut-out is outlined 3 in `yellow`
- a yellow tour card (large shadow, alternating ±1.5° tilt) sits on the roomier side of the spotlight, 16 from the edges
- the card holds progress dots (10 high, 10 wide or 22 when current, pink once reached, 2 outline), "Skip" as an underlined text button, a 22/800 title, a 15/600 body at 1.3 line height, then a primary button "Next" or "Got it"

## 6. Icons, imagery and motion

- **Icons:** Material Symbols, rounded style, always ink. 22 in navigation and headers, 16 in chips, 26–28 on big action tiles.
- **Illustration:** flat shapes with ink outlines in the same palette. No photos of people, no 3D.
- **Motion:** being designed one pattern at a time; the first is the add menu (section 5). The libraries also have a few small transitions (switch knob slide, sheet slide, dialog and snackbar fade, tour dots growing), and every duration comes from the `motion` tokens so animation can be added or retuned in one place. When motion is designed it must honour the system's reduce-motion setting.
- **Touch feedback:** no ripple or splash. Feedback comes from the state change itself (fill, outline weight, shadow).

## 7. Content and data

- **Money:** the bundled helpers format Indian rupees with Indian digit grouping: ₹1,25,000; ₹1,250.50. Compact forms are ₹51.2k, ₹1.25L and ₹2.1Cr. Apps for other currencies format their own amounts and follow the same rules (tabular figures, a real minus sign).
- **Signs:** a minus sign (−), not a hyphen. A "+" for money in where it helps.
- **Dates:** "18 Nov 2026", "Today", "Yesterday", "Nov 2026". Times are 12-hour: "1:12 pm".
- **Voice:**
  - plain, short and specific; second person; sentence case
  - say what happened and what to do next: "Couldn't load prices. Check your connection and try again."
  - no jargon, no exclamation marks except to celebrate a reached goal
- **Empty states:** a lilac hint card with one or two sentences saying what will appear and how to start.
- **Privacy reassurance** is part of the voice when an app handles personal data: "read on the phone and not kept", "Everything stays on this phone".

## 8. Accessibility

- **Contrast:** ink on every fill is at least 4.5:1.
- **Tap targets:** at least 48 by 48; pills are 40 high with generous horizontal padding.
- **Meaning:** never conveyed by colour alone; add words, glyphs or outline weight.
- **Screen readers:** every icon-only control has a label (e.g. "Add transaction", "Back"). Selected and toggled states are announced.
- **Text size:** layouts must survive larger system text. Long labels scale down to fit (FittedBox) rather than overflow; rows wrap rather than clip.

## 9. Don'ts

- No blurred shadows, glass effects or neon glows. No gradients except the gradient tokens.
- No thin (1px) borders or borderless cards.
- No white text on a bright fill; no coloured text.
- No red for spending or green for income as the only cue.
- No more than one primary (ink) button per view.
- No tilt beyond ±6°, and none on lists, inputs or long text.
- No fonts other than Bricolage Grotesque; no weights under 600.

Deliver the system as tokens (colour, type scale, spacing, radii, borders, shadows, tilt) plus a component library covering everything in section 5, each with its states (rest, selected, disabled, error), and a sample screen: Home, with the yellow month card, the Type it / Say it / Scan it row, a "Recent" StickerList and the bottom navigation with the tilted pink add button.