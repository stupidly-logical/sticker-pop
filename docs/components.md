# Components and their states

Every component draws only from tokens. Interaction feedback comes from
the state itself (fill, outline weight, shadow). There are no ripples. A
pressed sticker moves down-right by its shadow offset and its shadow
disappears.

| Component | Rest | Selected / on | Disabled | Error | Pressed |
| --- | --- | --- | --- | --- | --- |
| StickerCard (+ hero, info) | white, bright or gradient-token fill, 2.5 outline, 4/4 shadow (hero 6/6) | — | — | — | when tappable: moves by shadow, shadow goes |
| PopHintCard | lilac info card | — | — | — | — |
| StickerButton | ink fill, white 18/800, pink 4/4 shadow | — | inkMuted fill, no taps | — | moves 4/4, shadow goes; busy shows "Label…" |
| PopTextButton | ink 15/800, optional 2px underline | — | inkMuted | — | — |
| PopIconButton | 46 circle, 3/3 shadow, 22 icon | 3 outline | paper fill, muted icon, no shadow | — | moves 3/3 |
| PopChip | white, 2 outline, 14/700 | bright fill, 2.5 outline, 2/2 shadow, 800 | paper fill, muted text | — | — |
| PopSegmented | white 15/700 segments, 2.5 ink dividers | pink (or bright) fill, 15/800 | paper, muted text | — | — |
| PopSwitch | white track | mint track, knob right (150 ms) | paper track, divider knob | — | — |
| PopCheckbox (+ row) | white, 2 outline | mint, 2.5 outline, ink tick; some: dash | paper (divider when on), muted mark | — | — |
| PopRadio (+ row) | white circle, 2 outline | yellow, 2.5 outline, 10 ink dot | paper (divider when on), muted dot | — | — |
| PopTextField | white, 2 outline, radius 14 | focused: 2.5 outline | paper fill, muted text | 2.5 outline + ⚠ 14/800 ink message | — |
| PopAmountField | bright card (colour, label and currency symbol are parameters), prefix 32/800 | — | — | ⚠ message under the card | — |
| PopFieldRow | 76 muted label column, 2px divider | — | — | — | — |
| StickerBadge | white or bright, 2 outline, −4° | — | — | — | — |
| CategoryDot | 42 circle in a bright chosen by the app, −5° | — | — | — | — |
| StickerList / StickerListRow | rows in a card, 2px dividers | yellow row fill | — | — | — |
| PopSectionLabel | 13/800 caps +0.6 | — | — | — | — |
| PopNavBar | white, 2.5 top line, muted 12/700 | yellow pill around icon, ink 800 | — | — | — |
| PopAddButton | pink sticker, radius 20, −6° | — | — | — | moves 4/4 |
| PopQuickAddRow | white −1.5°, pink +1.5°, mint −1° | — | — | — | moves 4/4 |
| PopSheet | paper, 2.5 top line, radius 24 top | — | — | inline error above the button | — |
| PopTopBar (compact, large) | transparent, 22/800 or 34/800 title, back + up to 2 icon buttons | scrolled: paper fill, 2.5 ink bottom line | — | — | — |
| PopSelect | field: white, 2 outline, radius 14, chevron; list rows white | chosen row yellow, 800, tick | paper fill, muted text, no list | 2.5 outline + ⚠ message | open: 2.5 outline |
| PopMenu | white sticker, radius 16, 4/4 shadow, rows 15/700 | — | row inkMuted, no taps | — | row (hover, focus, press): yellow |
| PopDialog | paper card, 6/6 shadow, 20 inset | — | — | — | — |
| Snackbar | ink, 15/700 white, yellow action; 3 s / 6 s | — | — | never used for errors | — |
| PopProgressBar | white track 18, 2 outline, bright fill clipped to radius 7, straight 2 ink leading edge | — | — | — | — |
| PopDonut / PopBarChart / PopLegend | bright fills, ink outlines, yellow centre disc | highlighted bar: 3 outline + 2/2 shadow | — | — | — |
| Tour (PopTourCard, PopProgressDots, spotlight) | yellow card ±1.5°, 72% ink scrim, yellow 3 cut-out | current dot 22 wide, reached dots pink | — | — | — |

Availability: every component above exists on all four platforms (Compose,
Flutter, SwiftUI, web) with the same states. The exact names per platform
are in `parity/components.json`, and `tools/check-parity.mjs` enforces it.
Platform idioms differ only where they must: overlays are a composable
(`PopBottomSheet`) in Compose, a function (`showPopSheet`) in Flutter, a view
modifier (`.popBottomSheet`) in SwiftUI and a `<dialog>` in web.
