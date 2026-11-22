# Sticker Pop for the web

A bold, friendly design system: bright paper stickers on cream notebook
paper, with thick ink outlines, hard blur-free shadows and big, bold numbers.
Plain CSS classes and small behaviour scripts, so it works with any framework
or none. The same 48 components as the Flutter, Compose and SwiftUI libraries.

**Docs and live examples:** https://stupidly-logical.github.io/sticker-pop/

## Install

With a bundler (Vite, webpack, Next and so on):

```sh
npm install @sticker-pop/web
```

```js
import '@sticker-pop/web/sticker-pop.css';
import { wirePopControls } from '@sticker-pop/web/behaviors.mjs';

wirePopControls(); // menus, selects, tabs, sliders and the rest
```

Without a build step, from jsDelivr:

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@sticker-pop/web@0.1.0/src/sticker-pop.css">
<script type="module">
  import { wirePopControls } from 'https://cdn.jsdelivr.net/npm/@sticker-pop/web@0.1.0/src/behaviors.mjs';
  wirePopControls();
</script>
```

Either way, add the icon font and turn the styles on for a container:

```html
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,500,1,0">
<body class="sp-root sp-paper">
  <button class="sp-button">Save</button>
</body>
```

## What's in the package

| Import | What it is |
|---|---|
| `@sticker-pop/web/sticker-pop.css` | everything: tokens, components, fills, the bundled font |
| `@sticker-pop/web/behaviors.mjs` | `wirePopControls()` and the per-component helpers |
| `@sticker-pop/web/format.mjs` | `formatInr`, dates, `applyPopKey` and other shared rules |
| `@sticker-pop/web/charts.mjs` | donut and bar charts |
| `@sticker-pop/web` | the design tokens as a JS object (with types) |

In React or Vue, use the same class names and call the wiring helpers after
the markup renders.

## License

MIT. Bricolage Grotesque is under the SIL Open Font License.
