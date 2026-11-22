// Every component ships on every platform; tools/check-parity.mjs enforces it.
export const ALL = ['Compose', 'Flutter', 'SwiftUI', 'Web'];

export const surfaces = [
  {
    id: 'sticker-card', name: 'StickerCard', group: 'Surfaces', platforms: ALL,
    summary: 'The basic sticker: a white or bright fill, a 2.5 ink outline, radius 22 and a 4/4 hard shadow. The hero variant is yellow with a 6/6 shadow and an optional slight tilt; info cards are blue, lilac or mint.',
    states: [
      { label: 'Default', html: '<div class="sp-card full sp-text-body">Everything stays on this phone.</div>' },
      { label: 'Hero', html: '<div class="sp-card sp-card--hero sp-tilt-l full"><div class="sp-text-section-label">Net worth</div><div class="sp-text-hero-amount">₹12,40,500</div></div>' },
      { label: 'Info', html: '<div class="sp-card sp-card--info full sp-text-body">Prices refresh once a day.</div>' },
      { label: 'Gradient', html: '<div class="sp-card sp-fill-sunrise full sp-text-row-title">sunrise</div><div class="sp-card sp-fill-candy full sp-text-row-title">candy</div><div class="sp-card sp-fill-lagoon full sp-text-row-title">lagoon</div>' },
      { label: 'Tappable (press it)', html: '<button class="sp-card sp-fill-mint full sp-text-row-title" data-snack="Opened">Groceries · ₹8,210</button>' },
    ],
    code: {
      flutter: "StickerCard(child: PopText('Everything stays on this phone.', spec: PopTextSpecs.body))\n\nStickerCard.hero(\n  tiltDegrees: PopTilt.hero,\n  onTap: openMonth,\n  child: PopText(formatInr(spent), spec: PopTextSpecs.heroAmount),\n)\n\nStickerCard.info(color: PopColors.lilac, child: …)\n\nStickerCard(gradient: PopGradients.sunrise, child: …)",
      compose: 'StickerCard { PopText("Everything stays on this phone.", PopTextSpecs.body) }\n\nStickerHeroCard(onClick = ::openMonth) {\n    PopText(spent, PopTextSpecs.heroAmount)\n}\n\nStickerCard(gradient = PopGradients.sunrise) { … }',
      swift: 'StickerCard { PopText("Everything stays on this phone.", PopTextSpecs.body) }\n\nStickerHeroCard(action: openMonth) {\n    PopText(spent, PopTextSpecs.heroAmount)\n}\n\nStickerCard(gradient: PopGradients.sunrise) { … }',
      html: '<div class="sp-card">…</div>\n<div class="sp-card sp-card--hero sp-tilt-l">…</div>\n<div class="sp-card sp-card--info">…</div>\n<button class="sp-card sp-fill-mint">…</button>\n<div class="sp-card sp-fill-sunrise">…</div>',
    },
    spec: [['Fill', 'white, a bright, or a gradient token'], ['Outline', '2.5 ink'], ['Radius', '22'], ['Padding', '16 (hero 20)'], ['Shadow', '4/4 ink (hero 6/6)'], ['Tilt', 'up to ±3°; hero cards ±1.5°'], ['Pressed', 'moves 4/4, shadow disappears']],
    rules: ['Most cards stay straight. Never tilt text-heavy cards.', 'Gap between cards is 16.'],
  },
  {
    id: 'hint-card', name: 'Hint card (empty state)', group: 'Surfaces', platforms: ALL,
    summary: 'A lilac info card with one or two sentences saying what will appear here and how to start.',
    states: [
      { label: 'Empty state', html: '<div class="sp-card sp-hint full"><span class="sp-icon">lightbulb</span><span class="sp-text-body">Goals you add show up here. Tap Add goal to start one.</span></div>' },
      { label: 'With action', html: '<div class="sp-card sp-hint full"><span class="sp-icon">sms</span><div><div class="sp-text-row-title">No bank SMS yet</div><div class="sp-text-body">Messages are read on the phone and not kept.</div><button class="sp-text-button sp-text-button--underline">Allow SMS</button></div></div>' },
    ],
    code: {
      compose: "PopHintCard(\n    \"Goals you add show up here. Tap Add goal to start one.\",\n    icon = Icons.Rounded.Lightbulb,\n)",
      swift: "PopHintCard(\"Goals you add show up here. Tap Add goal to start one.\", systemImage: \"lightbulb.fill\")",
      flutter: "const PopHintCard(\n  icon: Icon(Icons.lightbulb_rounded),\n  message: 'Goals you add show up here. Tap Add goal to start one.',\n)",
      html: '<div class="sp-card sp-hint">\n  <span class="sp-icon">lightbulb</span>\n  <span class="sp-text-body">Goals you add show up here…</span>\n</div>',
    },
    spec: [['Fill', 'lilac'], ['Text', 'body 15/600; optional 16/800 title'], ['Action', 'a text button']],
  },
  {
    id: 'sticker-list', name: 'StickerList', group: 'Surfaces', platforms: ALL,
    summary: 'A card holding rows separated by 2px divider lines. Each row has a 42 category dot, a 16/800 title over a 13/600 muted line, and a right-aligned 16/800 tabular amount.',
    states: [
      { label: 'Rows', html: '<div class="sp-card sp-list full"><div class="sp-row"><span class="sp-dot" style="--sp-dot-fill:var(--sp-color-orange)"><span class="sp-icon">local_cafe</span></span><div class="sp-row__main"><div class="sp-row__title"><span class="sp-text-row-title">Chai Point</span><span class="sp-badge" style="font-size:11px">UPI</span></div><div class="sp-text-caption">Today · 1:12 pm · HDFC</div></div><div class="sp-text-row-amount">−₹120</div></div><div class="sp-row"><span class="sp-dot" style="--sp-dot-fill:var(--sp-color-mint)"><span class="sp-icon">work</span></span><div class="sp-row__main"><div class="sp-text-row-title">Salary</div><div class="sp-text-caption">15 Nov 2026 · HDFC</div></div><div class="sp-text-row-amount">+₹1,25,000</div></div></div>' },
      { label: 'Selected row', html: '<div class="sp-card sp-list full"><div class="sp-row" aria-selected="true"><span class="sp-dot" style="--sp-dot-fill:var(--sp-color-blue)"><span class="sp-icon">directions_car</span></span><div class="sp-row__main"><div class="sp-text-row-title">Uber</div><div class="sp-text-caption">Yesterday · ICICI</div></div><div class="sp-text-row-amount">−₹346.50</div></div></div>' },
    ],
    code: {
      flutter: "StickerList(children: [\n  StickerListRow(\n    leading: const CategoryDot(icon: Icons.local_cafe_rounded, color: PopColors.orange),\n    title: 'Chai Point',\n    badge: const StickerBadge(label: 'UPI', fontSize: 11),\n    subtitle: 'Today · 1:12 pm · HDFC',\n    amount: formatInr(-12000),\n    onTap: open,\n  ),\n])",
      compose: 'StickerList(rows = listOf(\n    { StickerListRow("Chai Point", subtitle = "Today · 1:12 pm", amount = "−₹120",\n        leading = { CategoryDot(Icons.Rounded.LocalCafe, PopColors.orange) }) },\n))',
      swift: 'StickerList(transactions) { t in\n    StickerListRow(t.title, subtitle: t.when, amount: t.amount,\n                   leading: AnyView(CategoryDot(systemImage: "cup.and.saucer.fill", fill: PopColors.orange)))\n}',
      html: '<div class="sp-card sp-list">\n  <div class="sp-row">\n    <span class="sp-dot" style="--sp-dot-fill:var(--sp-color-orange)">…</span>\n    <div class="sp-row__main">\n      <div class="sp-text-row-title">Chai Point</div>\n      <div class="sp-text-caption">Today · 1:12 pm</div>\n    </div>\n    <div class="sp-text-row-amount">−₹120</div>\n  </div>\n</div>',
    },
    spec: [['Card padding', 'none (a selected row fills to the outline)'], ['Row padding', '16 horizontal, 10–12 vertical'], ['Row min height', '52'], ['Divider', '2px divider colour'], ['Amount', '16/800 tabular, right-aligned']],
    rules: ['Never tilt lists.', 'Direction is the sign (+/−), not colour.'],
  },
  {
    id: 'sticker-badge', name: 'StickerBadge', group: 'Surfaces', platforms: ALL,
    summary: 'A small tilted label for "UPI", "Unsure", percentages and "COMING SOON".',
    states: [
      { label: 'White', html: '<span class="sp-badge">UPI</span>' },
      { label: 'Bright', html: '<span class="sp-badge sp-fill-orange">Unsure</span><span class="sp-badge sp-fill-mint">▲ 12.4%</span>' },
      { label: 'Caps', html: '<span class="sp-badge sp-badge--caps sp-fill-lilac">Coming soon</span>' },
    ],
    code: {
      flutter: "const StickerBadge(label: 'UPI')\nconst StickerBadge(label: 'Unsure', color: PopColors.orange)\nconst StickerBadge(label: 'Coming soon', caps: true, color: PopColors.lilac)",
      compose: 'StickerBadge("UPI")\nStickerBadge("Unsure", fill = PopColors.orange)',
      swift: 'StickerBadge("UPI")\nStickerBadge("Unsure", fill: PopColors.orange)',
      html: '<span class="sp-badge">UPI</span>\n<span class="sp-badge sp-fill-orange">Unsure</span>\n<span class="sp-badge sp-badge--caps sp-fill-lilac">Coming soon</span>',
    },
    spec: [['Outline', '2 ink'], ['Radius', '10'], ['Padding', '9 × 2'], ['Text', '11–13 / 800, tabular'], ['Tilt', '−4°']],
  },
  {
    id: 'category-dot', name: 'Category dot', group: 'Surfaces', platforms: ALL,
    summary: 'A 42 circle in a bright with a 2 ink outline and an ink icon at 48% of its size, tilted −5°. It marks what a row is: a category, a type, an account. Mapping your data to an icon and colour is your app\'s job; reuse colours by meaning so the same kind of thing always gets the same colour.',
    states: [
      { label: 'Brights', html: ['orange:local_cafe', 'mint:shopping_cart', 'blue:directions_car', 'lilac:bolt', 'pink:shopping_bag', 'white:more_horiz'].map((p) => { const [c, i] = p.split(':'); return `<span class="sp-dot" style="--sp-dot-fill:var(--sp-color-${c})"><span class="sp-icon">${i}</span></span>`; }).join('') },
    ],
    code: {
      flutter: "CategoryDot(icon: Icons.flight_rounded, color: PopColors.blue)",
      compose: 'CategoryDot(Icons.Rounded.Flight, PopColors.blue)',
      swift: 'CategoryDot(systemImage: "airplane", fill: PopColors.blue)',
      html: '<span class="sp-dot" style="--sp-dot-fill:var(--sp-color-orange)">\n  <span class="sp-icon">local_cafe</span>\n</span>',
    },
    spec: [['Size', '42'], ['Outline', '2 ink'], ['Icon', '48% of size, ink'], ['Tilt', '−5°']],
    a11y: 'Decorative: hidden from screen readers. The row title says what the category is.',
  },
  {
    id: 'settings-row', name: 'Settings row', group: 'Surfaces', platforms: ALL,
    summary: 'The row for settings lists, inside a sticker list: an optional icon, a title and subtitle, and on the right a switch, or the current value and a chevron when it opens something. The whole row is the tap target.',
    states: [{ label: 'A settings list (tap the rows)', html: '<div class="sp-card sp-list full"><button class="sp-settings-row" data-snack="Language opens here"><span class="sp-icon" aria-hidden="true">translate</span><span class="sp-settings-row__text"><span class="sp-settings-row__title">Language</span></span><span class="sp-settings-row__value">English</span><span class="sp-icon sp-settings-row__chevron" aria-hidden="true">chevron_right</span></button><div class="sp-settings-row"><span class="sp-icon" aria-hidden="true">notifications</span><span class="sp-settings-row__text"><span class="sp-settings-row__title" id="rem-l">Daily reminder</span><span class="sp-settings-row__subtitle">At 9 pm</span></span><button class="sp-switch" role="switch" aria-checked="true" aria-labelledby="rem-l"></button></div><button class="sp-settings-row" data-snack="Export data opens here"><span class="sp-icon" aria-hidden="true">ios_share</span><span class="sp-settings-row__text"><span class="sp-settings-row__title">Export data</span></span><span class="sp-icon sp-settings-row__chevron" aria-hidden="true">chevron_right</span></button><div class="sp-settings-row"><span class="sp-icon" aria-hidden="true">info</span><span class="sp-settings-row__text"><span class="sp-settings-row__title">Version</span></span><span class="sp-settings-row__value">0.1.0</span></div></div>' }],
    code: {
      flutter: "StickerList(children: [\n  PopSettingsRow(title: 'Language', icon: Icons.translate_rounded, value: 'English', onTap: openLanguage),\n  PopSettingsRow(title: 'Daily reminder', subtitle: 'At 9 pm', switchValue: reminder, onSwitch: setReminder),\n  const PopSettingsRow(title: 'Version', value: '0.1.0'),\n])",
      compose: 'StickerList(rows = listOf(\n    { PopSettingsRow("Language", icon = Icons.Rounded.Translate, value = "English", onClick = ::openLanguage) },\n    { PopSettingsRow("Daily reminder", subtitle = "At 9 pm", checked = reminder, onCheckedChange = { reminder = it }) },\n))',
      swift: 'PopSettingsRow("Language", systemImage: "character.bubble", value: "English") { openLanguage() }\nPopSettingsRow("Daily reminder", subtitle: "At 9 pm", isOn: $reminder)',
      html: '<div class="sp-card sp-list">\n  <button class="sp-settings-row">\n    <span class="sp-icon" aria-hidden="true">translate</span>\n    <span class="sp-settings-row__text"><span class="sp-settings-row__title">Language</span></span>\n    <span class="sp-settings-row__value">English</span>\n    <span class="sp-icon sp-settings-row__chevron" aria-hidden="true">chevron_right</span>\n  </button>\n  <div class="sp-settings-row">… <button class="sp-switch" role="switch" aria-checked="true"></button></div>\n</div>',
    },
    spec: [['Row', '52 min height, 16 left padding, 12 gaps'], ['Icon', '22 ink'], ['Title', '16/700; subtitle 13/600 muted'], ['Value', '16/700 muted, one line'], ['Chevron', '26, only when the row opens something'], ['Switch', 'PopSwitch; the row flips it too']],
    rules: ['Settings that apply at once get a switch; ones with several values show the value and open a picker.', 'Group related rows in one list with a section label above.'],
    a11y: 'Each row reads as one control: its title, subtitle and value, as a button, or as a switch with its state.',
  },
];
