# Working on Sticker Pop

A standalone design system used by several apps. Read `README.md` first;
`docs/spec.md` is the spec, and its numbers are not suggestions.

- Keep it app-agnostic: no product names, app IDs or app-specific data
  (category mappings, account types, copy about one product). Those live
  in the apps that use the library. Package IDs use `dev.stickerpop`.
- Tokens: edit only `tokens/sticker-pop.tokens.json`, then run
  `node tools/build-tokens.mjs`. Never hand-edit `*.g.dart`,
  `PopTokens.kt`, `PopTokens.swift` or `packages/web/src/tokens.*`.
- A change is done when `bash tools/check.sh` passes (from a Linux sandbox
  sharing this folder with a Mac, use `bash tools/mirror_check.sh`).
- Flutter 3.50: import `package:material_ui/material_ui.dart`, not
  `package:flutter/material.dart`.
- Rules the code must keep: outline everything (no 1px or borderless),
  hard shadows only (zero blur), flat colour by default and gradients only
  from the gradient tokens, ink text on every fill and
  white only on ink, never colour alone for meaning, weights 600 to 800,
  tilt at most ±6° (cards ±3°) and never on lists, inputs or long text,
  one primary button per view, tap targets at least 48.
- Money in the helpers is `int` paise; format with `formatInr` /
  `formatInrCompact` (Indian grouping, real minus sign).
- All four platforms are equals. A component change lands on Compose,
  Flutter, SwiftUI and web together: same parameters and states, each
  platform's gallery and (if relevant) Home sample, `parity/components.json`,
  the docs entry in `apps/site/content/c-*.js` (code for all four), and
  `docs/components.md`. A formatting change adds a case to
  `parity/format-cases.json` and passes on all four.
- SwiftUI can't be compiled from a Linux sandbox: rely on CI (macOS runner)
  or a Mac, and never report it as tested when it wasn't.
- Motion is still to be designed: any duration or animation goes through
  the `motion` tokens, never a hard-coded number.
- The version lives only in `VERSION`; change it with `node tools/version.mjs patch|minor|major` (or edit it and run `node tools/version.mjs sync`), never by hand in other files. Breaking changes bump it; apps pin tags.
