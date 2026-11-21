// Foundations: principles, colour, type, spacing/shape. Rendered from tokens.

export const foundationPages = [
  {
    id: 'principles',
    title: 'Principles',
    render: () => `
      <h1>Principles</h1>
      <p class="lede">Sticker Pop looks like bright paper stickers stuck on cream notebook paper. It's playful and trustworthy at once: playfulness lives in shape and colour, never in unclear numbers or words.</p>
      ${[
        ['Outline everything', 'Every card, button, chip, input and badge has a solid ink outline. No borderless floating surfaces, no hairlines.',
          '<div class="sp-card sp-text-body">Saved to HDFC</div>', '<div class="dont-soft" style="border:1px solid #ddd">Saved to HDFC</div>'],
        ['Hard shadows only', 'Shadows are solid ink (pink on the primary button), zero blur, offset down and right. Never soft shadows or elevation tints.',
          '<button class="sp-button">Save</button>', '<button class="sp-button" style="box-shadow:0 10px 30px rgba(0,0,0,.35);border-color:transparent">Save</button>'],
        ['Flat first, gradients from tokens', 'Flat fills are the default. Gradients are welcome when they come from the gradient tokens, built from the brights so ink text stays readable at every stop. Outlines and hard shadows still apply. No glass, transparency or textures.',
          '<div class="sp-card sp-fill-sunrise"><span class="sp-text-card-figure">₹51.2k</span></div>', '<div class="sp-card" style="background:linear-gradient(135deg,#3b0764,#0ea5e9);border-color:transparent;box-shadow:0 10px 30px rgba(0,0,0,.3)"><span class="sp-text-card-figure" style="color:#fff">₹51.2k</span></div>'],
        ['Ink on colour', 'Text on any fill is ink. White text appears only on ink: the primary button and snackbars.',
          '<span class="sp-badge sp-fill-mint">+12.4%</span>', '<span class="sp-badge sp-fill-mint" style="color:#fff">+12.4%</span>'],
        ['Numbers first', 'Amounts are the largest, boldest thing on a screen, in tabular figures. Direction is shown with words, signs and ▲/▼ in ink, never red or green alone.',
          '<div class="sp-text-hero-amount">−₹1,845.20</div>', '<div style="font-size:18px;color:#d00;font-weight:600">1845.2</div>'],
        ['A little tilt, sparingly', 'Tilt is a garnish: badges, a hero card, the add button. Never lists, inputs or long text, and never beyond ±6°.',
          '<span class="sp-badge">UPI</span>', '<div style="transform:rotate(-8deg);max-width:240px"><div class="sp-field__input" style="display:flex;align-items:center">Amount</div></div>'],
      ].map(([t, d, good, bad]) => `
        <h2>${t}</h2><p>${d}</p>
        <div class="dd">
          <div class="state"><span class="sp-badge sp-fill-mint dd__tag">Do</span><div class="state__body">${good}</div></div>
          <div class="state"><span class="sp-badge sp-fill-orange dd__tag">Don't</span><div class="state__body">${bad}</div></div>
        </div>`).join('')}`,
  },
  {
    id: 'colour',
    title: 'Colour',
    render: ({ tokens, kebab, contrast }) => {
      const desc = {
        paper: 'Screen background, sheets, dialogs', paperDot: 'Dot grid on paper', ink: 'Text, outlines, hard shadows, primary button, snackbars',
        inkMuted: 'Secondary text, hints, inactive icons, disabled fill', white: 'Cards, inputs, nav bar, unselected chips', divider: 'Lines between rows in a card',
        yellow: 'Hero cards, selected nav pill, default selected chip, tour cards', pink: 'Add button, primary button shadow, selected segment, voice',
        blue: 'Info cards and neutral highlights', mint: 'Positive and success states, switches on', lilac: 'Hints and empty states',
        orange: 'Warnings and needs-attention states',
      };
      const card = (name) => {
        const hex = tokens.color[name];
        const onInk = name === 'ink' || name === 'inkMuted';
        const ratio = contrast(onInk ? tokens.color.white : tokens.color.ink, hex);
        return `<div class="sp-card swatch-card">
          <div class="swatch-card__chip" style="background:${hex}"><span class="sp-badge ratio" style="transform:none">${onInk ? 'white' : 'ink'} text ${ratio.toFixed(1)}:1</span></div>
          <div class="swatch-card__meta"><b>${name}</b><code>${hex}</code><span class="sp-text-caption">${desc[name] ?? ''}</span><code style="font-size:11px">--sp-color-${kebab(name)}</code></div>
        </div>`;
      };
            return `
        <h1>Colour</h1>
        <p class="lede">Bold and cheerful, flat by default. Brights (and the gradients built from them) are fills only, never text. Each swatch shows the text colour it takes and the WCAG contrast ratio, computed live from the tokens.</p>
        <h2>Neutrals</h2>
        <div class="grid">${['paper', 'paperDot', 'ink', 'inkMuted', 'white', 'divider'].map(card).join('')}</div>
        <h2>Brights</h2>
        <div class="grid">${['yellow', 'pink', 'blue', 'mint', 'lilac', 'orange'].map(card).join('')}</div>
        <h2>Gradients</h2>
        <p>Built only from the brights, at a fixed angle, so ink text reads on every stop. Use them for cards, tiles and badges; never for text, and the primary button stays ink. These three are starters.</p>
        <div class="grid">${Object.entries(tokens.gradient).map(([name, g]) => {
          const worst = Math.min(...g.stops.map((s) => contrast(tokens.color.ink, s.color)));
          return `<div class="sp-card swatch-card">
            <div class="swatch-card__chip sp-fill-${kebab(name)}"><span class="sp-badge ratio" style="transform:none">ink text ≥ ${worst.toFixed(1)}:1</span></div>
            <div class="swatch-card__meta"><b>${name}</b><code>${g.angle}° · ${g.stops.map((s) => s.color).join(' → ')}</code><code style="font-size:11px">--sp-gradient-${kebab(name)} · .sp-fill-${kebab(name)}</code></div>
          </div>`;
        }).join('')}</div>
        <h2>Colour by meaning</h2>
        <p>When an app colours its own kinds of thing (categories, account types, tags), it should repeat colours by meaning so the same kind of thing is always the same colour, and use white for "other". That mapping lives in the app, not in Sticker Pop.</p>
        <h2>Rules</h2>
        <ul>
          <li>Text on every bright, on white and on paper is ink: at least 4.5:1 everywhere.</li>
          <li>Muted ink is for secondary text on paper or white only.</li>
          <li>Money in and out is never colour-coded red/green. Use words, signs (+ and −) and ▲/▼ in ink.</li>
          <li>No dark theme yet.</li>
        </ul>`;
    },
  },
  {
    id: 'type',
    title: 'Type',
    render: ({ tokens, kebab, esc, codeBlock }) => {
      const sample = {
        welcomeTitle: 'Welcome aboard', screenTitle: 'Home', heroAmount: '₹1,25,000', amountEntry: '₹1,250', subScreenTitle: 'Accounts',
        cardFigure: '₹51.2k', sheetTitle: 'Add a transaction', sectionHeading: 'This month', buttonLabel: 'Save', rowTitle: 'Chai Point',
        rowAmount: '−₹120', input: 'Lunch with Riya', inputHint: 'Add a note', body: 'Everything stays on this phone.', tileLabel: 'Say it',
        textButton: 'Show more', chip: 'Food', chipSelected: 'Food', segment: 'Income', segmentSelected: 'Expense', fieldLabel: 'Paid to',
        formError: 'Enter an amount above ₹0.', legendLabel: 'Groceries', legendValue: '24%', caption: 'Today · 1:12 pm · HDFC',
        sectionLabel: 'Net worth', navLabel: 'Activity', navLabelSelected: 'Home', badge: 'UPI', snackbar: 'Saved',
      };
      return `
        <h1>Type</h1>
        <p class="lede">Bricolage Grotesque, one variable font for everything. Weights 600 (body), 700 (labels) and 800 (titles, numbers, anything selected); nothing lighter. Sentence case everywhere; caps only for section labels and badges, with +0.6 tracking. Tabular figures for all amounts.</p>
        <div class="table-wrap"><table>
          <thead><tr><th>Role</th><th>Sample</th><th>Size / weight / tracking</th></tr></thead>
          <tbody>${Object.entries(tokens.text).map(([role, v]) => `<tr>
            <td><code>${role}</code></td>
            <td><span class="sp-text-${kebab(role)}" style="${v.color === 'white' ? 'background:var(--sp-color-ink);padding:4px 10px;border-radius:8px;' : ''}display:inline-block">${esc(sample[role] ?? role)}</span></td>
            <td style="white-space:nowrap">${v.size} / ${v.weight}${v.letterSpacing ? ` / ${v.letterSpacing > 0 ? '+' : ''}${v.letterSpacing}` : ''}${v.tabular ? ' · tabular' : ''}${v.caps ? ' · caps' : ''}</td>
          </tr>`).join('')}</tbody>
        </table></div>
        <h2>Usage</h2>
        ${codeBlock({
          flutter: "PopText('₹1,25,000', spec: PopTextSpecs.heroAmount)\n\n// or as a TextStyle\nText('Chai Point', style: popTextOf(PopTextSpecs.rowTitle))",
          compose: 'PopText("₹1,25,000", PopTextSpecs.heroAmount)\n\nBasicText("Chai Point", style = popTextStyle(PopTextSpecs.rowTitle))',
          swift: 'PopText("₹1,25,000", PopTextSpecs.heroAmount)',
          html: '<div class="sp-text-hero-amount">₹1,25,000</div>\n<div class="sp-text-row-title">Chai Point</div>',
        })}`;
    },
  },
  {
    id: 'shape',
    title: 'Spacing, shape and depth',
    render: ({ tokens }) => {
      const table = (group, viz, unit = '') => `<div class="table-wrap"><table><thead><tr><th>Token</th><th>Value</th><th></th></tr></thead><tbody>
        ${Object.entries(tokens[group]).map(([k, v]) => `<tr><td><code>${group}.${k}</code></td><td>${v}${unit}</td><td>${viz(k, v)}</td></tr>`).join('')}
      </tbody></table></div>`;
      return `
        <h1>Spacing, shape and depth</h1>
        <p class="lede">Units are dp/pt. Screens get 20 side padding, cards 16 padding and 16 between them, sections 20–24 apart.</p>
        <h2>Spacing</h2>
        ${table('space', (k, v) => `<div class="bar-viz" style="width:${v * 4}px"></div>`)}
        <h2>Outlines</h2>
        <p>2.5 for cards, buttons, inputs, segmented controls, switches and the nav bar's top edge; 2 for chips at rest, badges, category dots and switch knobs. Never 1px.</p>
        ${table('border', (k, v) => `<div style="width:120px;border-top:${v}px solid ${k === 'spotlight' ? 'var(--sp-color-yellow)' : k === 'divider' ? 'var(--sp-color-divider)' : 'var(--sp-color-ink)'}"></div>`)}
        <h2>Corner radius</h2>
        ${table('radius', (k, v) => `<div class="radius-viz" style="border-radius:${k === 'sheet' ? `${v}px ${v}px 0 0` : `${v}px`}"></div>`)}
        <h2>Hard shadows</h2>
        <p>Solid, zero blur, offset x = y. Pressing a sticker moves it by its shadow and the shadow disappears: that's the only touch feedback. No ripples.</p>
        ${table('shadow', (k, v) => `<div class="shadow-viz" style="box-shadow:${v}px ${v}px 0 var(--sp-color-ink)"></div>`)}
        <h2>Tilt</h2>
        <p>Cards up to ±3° (hero and tour cards alternate ±1.5°), badges −4°, category dots −5°, the add button −6°. Never lists, inputs or long text.</p>
        ${table('tilt', (k, v) => `<div class="tilt-viz" style="transform:rotate(${v}deg)"></div>`, '°')}
        <h2>Sizes</h2>
        ${table('size', () => '')}
        <h2>Motion</h2>
        <p>Motion is still to be designed. Today there are a few small transitions, and every duration comes from these tokens, so animation can be added or retuned in one place. When it's designed, it will honour the system's reduce-motion setting.</p>
        ${table('motion', () => '', ' ms')}`;
    },
  },
];
