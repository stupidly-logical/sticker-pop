import { ALL } from './c-surfaces.js';

const navHtml = (current = 0) => {
  const items = [['home', 'Home'], ['receipt_long', 'Activity'], null, ['insights', 'Insights'], ['savings', 'Wealth']];
  return `<nav class="sp-nav full" aria-label="Demo" style="border:2.5px solid var(--sp-color-ink);border-radius:18px;overflow:hidden">${items.map((it, i) => it
    ? `<button class="sp-nav__item" ${i === current ? 'aria-current="page"' : ''}><span class="sp-nav__pill"><span class="sp-icon">${it[0]}</span></span><span class="sp-nav__label">${it[1]}</span></button>`
    : '<div class="sp-nav__add"><button class="sp-add" aria-label="Add transaction" data-snack="Add sheet opens here"><span class="sp-icon">add</span></button></div>').join('')}</nav>`;
};

export const display = [
  {
    id: 'progress-bar', name: 'Progress bar', group: 'Data display', platforms: ALL,
    summary: 'For goals and budgets: a white track 18 high with a 2 ink outline and a bright fill. State the numbers in words next to it.',
    states: [
      { label: 'On track', html: '<div class="full"><div class="sp-progress" style="--value:45%"><span></span></div><div class="sp-text-caption" style="margin-top:6px">₹4,500 of ₹10,000 · 45% used</div></div>' },
      { label: 'Warning', html: '<div class="full"><div class="sp-progress" style="--value:92%;--sp-progress-fill:var(--sp-color-orange)"><span></span></div><div class="sp-text-caption" style="margin-top:6px">₹9,200 of ₹10,000 · 92% used</div></div>' },
      { label: 'Empty', html: '<div class="full"><div class="sp-progress" style="--value:0%"><span style="border:0"></span></div><div class="sp-text-caption" style="margin-top:6px">Nothing saved yet</div></div>' },
    ],
    code: {
      flutter: "PopProgressBar(value: 0.92, color: PopColors.orange, semanticLabel: 'Food budget')",
      compose: 'PopProgressBar(0.92f, fill = PopColors.orange, label = "Food budget")',
      swift: 'PopProgressBar(value: 0.92, fill: PopColors.orange, label: "Food budget")',
      html: '<div class="sp-progress" role="progressbar" aria-valuenow="92" aria-label="Food budget"\n     style="--value:92%;--sp-progress-fill:var(--sp-color-orange)"><span></span></div>',
    },
    spec: [['Track', 'white, 18 high, 2 outline, radius 9'], ['Fill', 'a bright, clipped to radius 7']],
    rules: ['Over 100%, keep the bar full and say so in words.'],
  },
  {
    id: 'charts', name: 'Charts', group: 'Data display', platforms: ALL,
    summary: 'Donuts with one bright per slice, each outlined in 2.5 ink, around a yellow centre disc. Bars with bright fills and ink outlines. No gridlines, gradients or 3D.',
    states: [
      { label: 'Donut + legend', html: `<div class="full row" style="gap:20px;flex-wrap:nowrap"><svg viewBox="0 0 140 140" width="130" height="130" role="img" aria-label="Spending by category"><g stroke="#141414" stroke-width="2.5"><circle cx="70" cy="70" r="51" fill="none" stroke="#FF9C5B" stroke-width="30" stroke-dasharray="102.5 320.4" transform="rotate(-90 70 70)"/><circle cx="70" cy="70" r="51" fill="none" stroke="#5EE0A8" stroke-width="30" stroke-dasharray="76.9 320.4" stroke-dashoffset="-102.5" transform="rotate(-90 70 70)"/><circle cx="70" cy="70" r="51" fill="none" stroke="#8DB8FF" stroke-width="30" stroke-dasharray="57.7 320.4" stroke-dashoffset="-179.4" transform="rotate(-90 70 70)"/><circle cx="70" cy="70" r="51" fill="none" stroke="#C3AEFF" stroke-width="30" stroke-dasharray="51.3 320.4" stroke-dashoffset="-237.1" transform="rotate(-90 70 70)"/><circle cx="70" cy="70" r="51" fill="none" stroke="#FF6FAE" stroke-width="30" stroke-dasharray="32 320.4" stroke-dashoffset="-288.4" transform="rotate(-90 70 70)"/><circle cx="70" cy="70" r="66" fill="none"/><circle cx="70" cy="70" r="36" fill="none"/><circle cx="70" cy="70" r="28" fill="#FFD43B"/></g><text x="70" y="75" text-anchor="middle" font-family="Bricolage Grotesque" font-weight="800" font-size="15">₹51.2k</text></svg>
        <div class="sp-legend" style="flex:1">${[['orange', 'Food', 32], ['mint', 'Groceries', 24], ['blue', 'Transport', 18], ['lilac', 'Bills', 16], ['pink', 'Shopping', 10]].map(([c, l, v]) => `<div><i class="sp-swatch" style="--sp-swatch-fill:var(--sp-color-${c})"></i>${l}<b>${v}%</b></div>`).join('')}</div></div>` },
      { label: 'Bars (current month emphasised)', html: `<div class="sp-bars full" role="img" aria-label="Spend by month">${[['Jun', 76], ['Jul', 84], ['Aug', 62], ['Sep', 94], ['Oct', 104], ['Nov', 58]].map(([m, h], i) => `<div class="${i === 5 ? 'is-current' : ''}"><i style="--h:${h}px${i === 5 ? ';--sp-bar-fill:var(--sp-color-yellow)' : ''}"></i>${m}</div>`).join('')}</div>` },
    ],
    code: {
      compose: "PopDonut(slices, \"Spending by category\") { PopText(\"₹51.2k\", PopTextSpecs.rowAmount) }\nPopLegend(slices)\nPopBarChart(months, \"Spend by month\", highlightIndex = 5)",
      swift: "PopDonut(slices, label: \"Spending by category\") { PopText(\"₹51.2k\", PopTextSpecs.rowAmount) }\nPopLegend(slices)\nPopBarChart(months, label: \"Spend by month\", highlightIndex: 5)",
      html: "import { popDonutSvg, popLegendHtml, popBarsHtml } from '@sticker-pop/web/charts';\n\nel.innerHTML = popDonutSvg(slices, { center: '₹51.2k', label: 'Spending by category' })\n  + popLegendHtml(slices)\n  + popBarsHtml(months, { highlightIndex: 5, label: 'Spend by month' });",
      flutter: "PopDonut(\n  semanticLabel: 'Spending by category',\n  data: const [PopDatum(label: 'Food', value: 32, color: PopColors.orange), …],\n  center: PopText('₹51.2k', spec: PopTextSpecs.rowAmount),\n)\nPopLegend(data: slices)\nPopBarChart(data: months, highlightIndex: 5, semanticLabel: 'Spend by month')",
    },
    spec: [['Slices / bars', 'brights with 2.5 (bars 2) ink outlines'], ['Donut centre', 'yellow disc'], ['Legend swatch', '12 square, 1.5 outline, radius 4'], ['Legend text', 'label 14/700, percentage 14/800 tabular'], ['Emphasis', '3 outline + 2/2 shadow, not colour alone']],
  },
  {
    id: 'section-label', name: 'Section label', group: 'Data display', platforms: ALL,
    summary: 'A small caps label like "NET WORTH" or "RECENT", usually with a trailing text button.',
    states: [{ label: 'With action', html: '<div class="sp-section-label full"><span class="sp-text-section-label">Recent</span><button class="sp-text-button">See all</button></div>' }],
    code: {
      compose: "PopSectionLabel(\"Recent\") { PopTextButton(\"See all\", ::openAll) }",
      swift: "PopSectionLabel(\"Recent\") { PopTextButton(\"See all\", action: openAll) }",
      flutter: "PopSectionLabel('Recent', trailing: PopTextButton(label: 'See all', onPressed: openAll))",
      html: '<div class="sp-section-label">\n  <span class="sp-text-section-label">Recent</span>\n  <button class="sp-text-button">See all</button>\n</div>',
    },
    spec: [['Text', '13/800, +0.6 tracking, caps'], ['Screen readers', 'read in sentence case, marked as a heading']],
  },
  {
    id: 'nav-bar', name: 'Bottom navigation', group: 'Navigation', platforms: ALL,
    summary: 'White with a 2.5 ink line on top. Home, Activity, Add, Insights and Wealth. The selected icon sits in a small yellow pill; the add button is a pink sticker tilted −6°. It can open an add menu instead of a single action: see <a href="#add-menu">Motion: add menu</a>.',
    states: [
      { label: 'Home selected (tap around)', html: navHtml(0) },
      { label: 'Wealth selected', html: navHtml(4) },
    ],
    code: {
      flutter: "PopNavBar(\n  items: const [\n    PopNavItem(icon: Icons.home_rounded, label: 'Home'),\n    PopNavItem(icon: Icons.receipt_long_rounded, label: 'Activity'),\n    PopNavItem(icon: Icons.insights_rounded, label: 'Insights'),\n    PopNavItem(icon: Icons.savings_rounded, label: 'Wealth'),\n  ],\n  selectedIndex: tab,\n  onSelected: (i) => setState(() => tab = i),\n  onAdd: openAddSheet,\n)",
      compose: 'PopNavBar(items, selected = tab, onSelect = { tab = it }, onAdd = ::openAddSheet)',
      swift: 'PopNavBar(items: items, selection: $tab, onAdd: openAddSheet)',
      html: '<nav class="sp-nav" aria-label="Main">\n  <button class="sp-nav__item" aria-current="page">\n    <span class="sp-nav__pill"><span class="sp-icon">home</span></span>\n    <span class="sp-nav__label">Home</span>\n  </button>\n  …\n  <div class="sp-nav__add"><button class="sp-add" aria-label="Add transaction">…</button></div>\n</nav>',
    },
    spec: [['Bar', 'white, 2.5 top line, padding 8 × 10'], ['Item', '22 icon over a 12 label; tap target 48'], ['Selected', 'yellow pill (radius 12, 2 outline, 10 × 2), ink 800'], ['Others', 'inkMuted 700'], ['Add button', 'pink, radius 20, padding 13, 4/4 shadow, −6°, 28 +']],
    a11y: 'The add button is labelled "Add transaction"; the current tab is announced as selected.',
  },
  {
    id: 'quick-add', name: 'Quick-add row', group: 'Navigation', platforms: ALL,
    summary: 'Three equal tiles on Home, 12 apart: "Type it" (white, −1.5°), "Say it" (pink, +1.5°) and "Scan it" (mint, −1°).',
    states: [{ label: 'Home row (press a tile)', html: '<div class="sp-quick-add full"><button class="sp-card" style="transform:rotate(-1.5deg)" data-snack="Type it"><span class="sp-icon">keyboard</span>Type it</button><button class="sp-card sp-fill-pink" style="transform:rotate(1.5deg)" data-snack="Say it"><span class="sp-icon">mic</span>Say it</button><button class="sp-card sp-fill-mint" style="transform:rotate(-1deg)" data-snack="Scan it"><span class="sp-icon">document_scanner</span>Scan it</button></div>' }],
    code: {
      flutter: 'PopQuickAddRow.standard(onType: type, onSay: listen, onScan: scan)',
      compose: 'PopQuickAddRow(listOf(\n    PopQuickAddTile("Type it", Icons.Rounded.Keyboard, PopColors.white, -1.5f, ::type),\n    PopQuickAddTile("Say it", Icons.Rounded.Mic, PopColors.pink, 1.5f, ::listen),\n    PopQuickAddTile("Scan it", Icons.Rounded.DocumentScanner, PopColors.mint, -1f, ::scan),\n))',
      swift: 'PopQuickAddRow(onType: type, onSay: listen, onScan: scan)',
      html: '<div class="sp-quick-add">\n  <button class="sp-card" style="transform:rotate(-1.5deg)"><span class="sp-icon">keyboard</span>Type it</button>\n  …\n</div>',
    },
    spec: [['Tile', 'StickerCard, 12 vertical padding'], ['Icon', '26 ink'], ['Label', '15/800'], ['Gap', '12']],
  },
];
