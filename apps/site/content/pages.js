// Overview, install and the two example pages.
import { dialHtml } from './guides.js';

const homeRows = [
  ['orange', 'local_cafe', 'Chai Point', 'UPI', 'Today · 12:32 pm · HDFC', '−₹120'],
  ['blue', 'directions_car', 'Uber', 'UPI', 'Today · 9:12 am · ICICI', '−₹346.50'],
  ['mint', 'shopping_cart', 'BigBasket', 'Unsure', 'Yesterday · HDFC', '−₹1,845.20'],
  ['mint', 'work', 'Salary', '', '15 Nov 2026 · HDFC', '+₹1,25,000'],
  ['lilac', 'bolt', 'Electricity bill', '', '13 Nov 2026 · SBI', '−₹2,150'],
];

export const otherPages = [
  {
    id: '',
    title: '',
    render: ({ components }) => `
      <h1>Sticker Pop</h1>
      <p class="lede">A bold, friendly design system for apps. Bright paper stickers on cream notebook paper: thick ink outlines, hard shadows, a little tilt, and numbers that are always the biggest, boldest thing on the screen. One token file, four platforms.</p>
      <div class="row">
        <a class="sp-button" style="width:auto;padding:0 28px;text-decoration:none" href="#install">Get started</a>
        <a class="sp-text-button sp-text-button--underline" style="display:inline-flex;align-items:center" href="#c-${components[0].id}">Browse ${components.length} components</a>
      </div>
      <div class="sp-card sp-card--hero sp-tilt-l" style="max-width:520px;margin-top:8px">
        <div class="row" style="justify-content:space-between"><span class="sp-text-section-label">Spent in Nov 2026</span><span class="sp-badge">11% of budget</span></div>
        <div class="sp-text-hero-amount">₹4,461.70</div>
        <div class="sp-progress" style="--value:11%;--sp-progress-fill:var(--sp-color-pink);margin:12px 0 8px"><span></span></div>
        <div class="sp-text-body">₹35,538.30 left of ₹40k · 12 days to go</div>
      </div>
      <h2>One source, four platforms</h2>
      <p>Every value lives in one token file, <code>tokens/sticker-pop.tokens.json</code>. A generator turns it into Kotlin, Dart, Swift, CSS and JavaScript, and fails the build if a token breaks a rule: a weight under 600, a tilt over 6°, or ink contrast under 4.5:1. All four libraries have the same ${components.length} components, the same states, the same formatting helpers (checked against one shared list of cases) and the same samples, and CI builds and tests each one.</p>
      <div class="grid">
        ${[['android', 'Jetpack Compose', 'Native Android. Kotlin, Compose, Paparazzi screenshot tests.', 'sp-fill-mint'],
           ['flutter_dash', 'Flutter', 'Android, iOS and web from one codebase. Golden screenshot tests.', 'sp-fill-yellow'],
           ['phone_iphone', 'SwiftUI', 'Native iOS and macOS. Swift package, snapshot tests.', 'sp-fill-blue'],
           ['code', 'Web', 'CSS components, JS behaviours and charts. This site is built with it.', 'sp-fill-lilac']]
          .map(([icon, t, d, fill]) => `<div class="sp-card ${fill}"><span class="sp-icon" style="font-size:28px">${icon}</span><h3>${t}</h3><p style="margin:4px 0 0">${d}</p></div>`).join('')}
      </div>
      <h2>Start here</h2>
      <div class="grid">
        ${[['principles', 'auto_awesome', 'Principles', 'The six rules every screen follows.'],
           ['colour', 'palette', 'Colour', 'Neutrals, brights and category colours.'],
           ['home', 'smartphone', 'Home screen', 'The reference screen, built from components.'],
           ['app', 'play_circle', 'Gallery apps', 'Every component, on every platform.']]
          .map(([href, icon, t, d]) => `<a class="sp-card tile-link" href="#${href}"><span class="sp-icon">${icon}</span><b class="sp-text-row-title">${t}</b><span class="sp-text-caption">${d}</span></a>`).join('')}
      </div>`,
  },
  {
    id: 'install',
    title: 'Install',
    render: ({ codeBlock }) => `
      <h1>Install</h1>
      <p class="lede">Every version is a tagged <a href="https://github.com/stupidly-logical/sticker-pop/releases">GitHub release</a>, published to npm and pub.dev at the same time; Swift Package Manager installs straight from the tag. Pin the version so library changes never reach your app by surprise.</p>
      ${codeBlock({
        compose: `# Add the repo as a submodule (JDK 21, AGP 8.11+)
git submodule add https://github.com/stupidly-logical/sticker-pop.git third_party/sticker-pop
git -C third_party/sticker-pop checkout v0.1.0

// settings.gradle.kts
includeBuild("third_party/sticker-pop/packages/android")

// app/build.gradle.kts
dependencies { implementation("dev.stickerpop:stickerpop:0.1.0") }`,
        flutter: `flutter pub add sticker_pop

# or in pubspec.yaml
dependencies:
  sticker_pop: ^0.1.0

// main.dart
import 'package:sticker_pop/sticker_pop.dart';

MaterialApp(theme: buildPopTheme(), home: const HomeScreen());`,
        swift: `// Xcode › File › Add Package Dependencies…
//   https://github.com/stupidly-logical/sticker-pop.git  (Up to Next Major: 0.1.0)
// or Package.swift:
.package(url: "https://github.com/stupidly-logical/sticker-pop.git", from: "0.1.0")

import StickerPop

@main struct MyApp: App {
    init() { StickerPopFonts.register() }
    var body: some Scene { WindowGroup { ContentView() } }
}`,
        html: `# With a bundler (Vite, webpack, Next…)
npm install @sticker-pop/web

// main.js
import '@sticker-pop/web/sticker-pop.css';
import { wirePopControls } from '@sticker-pop/web/behaviors.mjs';
wirePopControls();

<!-- Or no build step, from jsDelivr -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@sticker-pop/web@0.1.0/src/sticker-pop.css">
<script type="module">
  import { wirePopControls } from 'https://cdn.jsdelivr.net/npm/@sticker-pop/web@0.1.0/src/behaviors.mjs';
  wirePopControls();
</script>

<!-- Either way: the icon font, and turn the styles on -->
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,500,1,0">
<body class="sp-root sp-paper">
  <button class="sp-button">Save</button>
</body>`,
      })}
      <p class="sp-text-caption">Pick a platform once; every code sample on the site follows it.</p>
      <h2>Changing a token</h2>
      <p>Edit <code>tokens/sticker-pop.tokens.json</code> and regenerate. Never edit the generated files.</p>
      <div class="code"><pre><code>node tools/build-tokens.mjs           # regenerate every platform
node tools/build-tokens.mjs --check   # CI: fail if anything is stale
bash tools/check.sh                   # tokens, Flutter analyze + tests, web lint
node tools/build-site.mjs --serve     # rebuild and serve this site</code></pre></div>
      <h2>Fonts and icons</h2>
      <p>Bricolage Grotesque (SIL Open Font License) is bundled with every package. Text uses weights 600, 700 and 800 only. Icons are Material Symbols Rounded, always in ink: 22 in navigation and headers, 16 in chips, 26–28 on big action tiles.</p>`,
  },
  {
    id: 'home',
    title: 'Home screen',
    render: ({ codeBlock }) => `
      <h1>Home screen</h1>
      <p class="lede">A sample Home screen for an expense app, built only from Sticker Pop components: the yellow month card, Type it / Say it / Scan it, a Recent list and the bottom navigation with the tilted pink add button, which opens the add menu. Tap things; it works.</p>
      <div class="phone sp-paper" aria-label="Home sample" data-pop-dial-root>
        <div class="phone__body">
          <div class="row" style="justify-content:space-between"><div class="sp-text-screen-title" role="heading" aria-level="2">Home</div><button class="sp-icon-button" aria-label="Settings" data-snack="Settings open here"><span class="sp-icon">settings</span></button></div>
          <button class="sp-card sp-card--hero sp-tilt-l" data-snack="Month details open here">
            <div class="row" style="justify-content:space-between"><span class="sp-text-section-label">Spent in Nov 2026</span><span class="sp-badge">11% of budget</span></div>
            <div class="sp-text-hero-amount">₹4,461.70</div>
            <div class="sp-progress" style="--value:11%;--sp-progress-fill:var(--sp-color-pink);margin:12px 0 8px"><span></span></div>
            <div class="sp-text-body">₹35,538.30 left of ₹40k · 12 days to go</div>
          </button>
          <div class="sp-quick-add">
            <button class="sp-card" style="transform:rotate(-1.5deg)" data-snack="Type it opens here"><span class="sp-icon">keyboard</span>Type it</button>
            <button class="sp-card sp-fill-pink" style="transform:rotate(1.5deg)" data-snack="Say it opens here"><span class="sp-icon">mic</span>Say it</button>
            <button class="sp-card sp-fill-mint" style="transform:rotate(-1deg)" data-snack="Scan it opens here"><span class="sp-icon">document_scanner</span>Scan it</button>
          </div>
          <div class="sp-section-label"><span class="sp-text-section-label">Recent</span><button class="sp-text-button">See all</button></div>
          <div class="sp-card sp-list">
            ${homeRows.map(([cat, icon, title, badge, sub, amt]) => `<div class="sp-row"><span class="sp-dot" style="--sp-dot-fill:var(--sp-color-${cat})"><span class="sp-icon">${icon}</span></span><div class="sp-row__main"><div class="sp-row__title"><span class="sp-text-row-title">${title}</span>${badge ? `<span class="sp-badge ${badge === 'Unsure' ? 'sp-fill-orange' : ''}" style="font-size:11px">${badge}</span>` : ''}</div><div class="sp-text-caption">${sub}</div></div><div class="sp-text-row-amount">${amt}</div></div>`).join('')}
          </div>
        </div>
        <nav class="sp-nav" aria-label="Main">
          <button class="sp-nav__item" aria-current="page"><span class="sp-nav__pill"><span class="sp-icon">home</span></span><span class="sp-nav__label">Home</span></button>
          <button class="sp-nav__item"><span class="sp-nav__pill"><span class="sp-icon">receipt_long</span></span><span class="sp-nav__label">Activity</span></button>
          <div class="sp-nav__add">${dialHtml('home-dial')}</div>
          <button class="sp-nav__item"><span class="sp-nav__pill"><span class="sp-icon">insights</span></span><span class="sp-nav__label">Insights</span></button>
          <button class="sp-nav__item"><span class="sp-nav__pill"><span class="sp-icon">savings</span></span><span class="sp-nav__label">Wealth</span></button>
        </nav>
      </div>
      <h2>Build it</h2>
      ${codeBlock({
        compose: 'import dev.stickerpop.samples.PopHomeSample\n\nsetContent { PopHomeSample() }',
        flutter: "import 'package:sticker_pop/samples.dart';\n\nMaterialApp(theme: buildPopTheme(), home: const PopHomeSample());",
        swift: 'import StickerPop\n\nWindowGroup { PopHomeSample() }',
        html: '<!-- packages/web/index.html: the right-hand phone is the Home sample -->',
      })}
      <p>Each library ships the same sample, composed from the hero card, the quick-add row, a sticker list and the nav bar, with an add sheet behind the + button.</p>`,
  },
  {
    id: 'app',
    title: 'Gallery apps',
    render: ({ codeBlock }) => `
      <h1>Gallery apps</h1>
      <p class="lede">Every library has the same gallery (every component in each of its states) and the same Home sample. Two run right here in the browser; the native ones run on a device, an emulator or your Mac.</p>
      <div class="grid grid--wide">
        <a class="sp-card tile-link sp-fill-lilac" href="web-gallery/" target="_blank" rel="noopener"><span class="sp-icon">code</span><b class="sp-text-row-title">Web gallery</b><span class="sp-text-body">The CSS and JS library, with the Home sample. Opens in a new tab.</span></a>
        <a class="sp-card tile-link sp-fill-yellow" href="app/" target="_blank" rel="noopener"><span class="sp-icon">flutter_dash</span><b class="sp-text-row-title">Flutter gallery</b><span class="sp-text-body">The Flutter library compiled for the web. Opens in a new tab.</span></a>
      </div>
      <h2>Run them yourself</h2>
      ${codeBlock({
        compose: '# Android Studio: open packages/android and run the "sample" app, or\ncd packages/android && ./gradlew :sample:installDebug',
        flutter: 'cd packages/flutter/sticker_pop/example\nflutter run            # device or emulator\nflutter run -d chrome  # browser',
        swift: '# A Mac window with the gallery and Home sample:\nswift run StickerPopDemo\n\n# iOS: add the package to an app and show PopGallery()',
        html: 'npm run site   # then open http://localhost:4173/web-gallery/',
      })}
      <h2>Flutter gallery</h2>
      <iframe class="app-frame" src="app/" title="Sticker Pop Flutter gallery" loading="lazy"></iframe>`,
  },
];
