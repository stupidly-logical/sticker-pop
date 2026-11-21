// Content and accessibility guidelines.

/** The add menu markup used by the demos (Type it, Say it, Scan it). */
export function dialHtml(id, extra = '') {
  return `<div class="sp-dial ${extra}" data-pop-dial id="${id}" data-close-label="Close add menu">
    <button class="sp-add" aria-label="Add transaction"><span class="sp-icon">add</span></button>
    <div class="sp-dial__menu">
      <button class="sp-dial__option" data-value="Type it"><span class="sp-dial__sticker sp-fill-white"><span class="sp-icon">keyboard</span></span><span class="sp-dial__label">Type it</span></button>
      <button class="sp-dial__option" data-value="Say it"><span class="sp-dial__sticker sp-fill-pink"><span class="sp-icon">mic</span></span><span class="sp-dial__label">Say it</span></button>
      <button class="sp-dial__option" data-value="Scan it"><span class="sp-dial__sticker sp-fill-mint"><span class="sp-icon">document_scanner</span></span><span class="sp-dial__label">Scan it</span></button>
    </div>
  </div>`;
}

export const guidePages = [
  {
    id: 'content',
    title: 'Content and data',
    render: ({ codeBlock }) => `
      <h1>Content and data</h1>
      <p class="lede">Plain, short and specific. Say what happened and what to do next.</p>
      <h2>Money</h2>
      <div class="table-wrap"><table>
        <thead><tr><th>Case</th><th>Write</th><th>Not</th></tr></thead>
        <tbody>
          <tr><td>Full amount, Indian grouping</td><td class="sp-text-row-amount">₹1,25,000</td><td>₹125,000</td></tr>
          <tr><td>With paise</td><td class="sp-text-row-amount">₹1,250.50</td><td>Rs 1250.5</td></tr>
          <tr><td>Compact</td><td class="sp-text-row-amount">₹51.2k · ₹1.25L · ₹2.1Cr</td><td>₹51,200 in a tight chip</td></tr>
          <tr><td>Money out</td><td class="sp-text-row-amount">−₹450</td><td>-₹450 (hyphen) or red ₹450</td></tr>
          <tr><td>Money in</td><td class="sp-text-row-amount">+₹52,000</td><td>green ₹52,000</td></tr>
        </tbody>
      </table></div>
      <p>Every library has the same helpers, and their tests all run the same cases (<code>parity/format-cases.json</code>), so a figure looks identical on every platform.</p>
      ${codeBlock({
        compose: 'PopFormat.formatInr(12500000)                          // ₹1,25,000  (amounts are paise)\nPopFormat.formatInr(-45000)                            // −₹450\nPopFormat.formatInr(5200000, PopFormat.Sign.Always)    // +₹52,000\nPopFormat.formatInrCompact(12500000)                   // ₹1.25L',
        flutter: "formatInr(12500000)                        // ₹1,25,000  (amounts are int paise)\nformatInr(-45000)                           // −₹450\nformatInr(5200000, sign: PopSign.always)    // +₹52,000\nformatInrCompact(12500000)                  // ₹1.25L",
        swift: 'PopFormat.formatInr(12_500_000)                 // ₹1,25,000  (amounts are paise)\nPopFormat.formatInr(-45000)                     // −₹450\nPopFormat.formatInr(5_200_000, sign: .always)   // +₹52,000\nPopFormat.formatInrCompact(12_500_000)          // ₹1.25L',
        html: "import { formatInr, formatInrCompact } from '@sticker-pop/web/format';\n\nformatInr(12500000)                        // ₹1,25,000  (amounts are paise)\nformatInr(-45000)                          // −₹450\nformatInr(5200000, { sign: 'always' })     // +₹52,000\nformatInrCompact(12500000)                 // ₹1.25L",
      })}
      <h2>Dates and times</h2>
      <p>"18 Nov 2026", "Today", "Yesterday", "Nov 2026". Times are 12-hour: "1:12 pm". In Flutter: <code>formatPopDate</code>, <code>formatPopMonth</code>, <code>formatPopTime</code>.</p>
      <h2>Voice</h2>
      <div class="dd">
        <div class="state"><span class="sp-badge sp-fill-mint dd__tag">Do</span><div class="state__body"><span class="sp-text-body">Couldn't load prices. Check your connection and try again.</span></div></div>
        <div class="state"><span class="sp-badge sp-fill-orange dd__tag">Don't</span><div class="state__body"><span class="sp-text-body">Error 503: price fetch failed!</span></div></div>
      </div>
      <ul>
        <li>Second person, sentence case, no jargon.</li>
        <li>No exclamation marks, except to celebrate a reached goal.</li>
        <li>When an app handles personal data, say plainly what happens to it: "read on the phone and not kept", "Everything stays on this phone".</li>
        <li>Empty states are a lilac hint card: one or two sentences saying what will appear and how to start.</li>
        <li>Form errors appear inline above the primary button, never in a snackbar. Snackbars are for "Saved" and "Deleted · Undo".</li>
      </ul>`,
  },
  {
    id: 'accessibility',
    title: 'Accessibility',
    render: () => `
      <h1>Accessibility</h1>
      <p class="lede">Bold and playful, and usable by everyone.</p>
      <div class="grid grid--wide">
        <div class="sp-card"><h3>Contrast</h3><p>Ink on every fill is at least 4.5:1. The token build fails if a colour change breaks this.</p></div>
        <div class="sp-card"><h3>Tap targets</h3><p>At least 48 × 48. Pills are 40 high with generous horizontal padding; switches pad out to 48.</p></div>
        <div class="sp-card"><h3>Never colour alone</h3><p>Selection adds outline weight, a shadow and bolder text. Money direction uses words, signs and ▲/▼. Errors add a ⚠ and a message.</p></div>
        <div class="sp-card"><h3>Screen readers</h3><p>Every icon-only control has a label ("Add transaction", "Back"). Selected and toggled states are announced. Caps labels are read in sentence case.</p></div>
        <div class="sp-card"><h3>Larger text</h3><p>Layouts survive bigger system text: long labels scale down to fit rather than overflow, and rows wrap rather than clip.</p></div>
        <div class="sp-card"><h3>Motion</h3><p>Motion is still being designed. Today's few transitions are short, and every duration is a token. When animation arrives it must honour reduce-motion. No ripples or splashes.</p></div>
      </div>`,
  },
  {
    id: 'add-menu',
    title: 'Motion: add menu',
    render: ({ codeBlock }) => `
      <h1>Motion: add menu</h1>
      <p class="lede">The pink add button can open a small menu of ways to add something: for an expense app, Type it, Say it and Scan it. The button turns into a close button and the options pop out of it like stickers peeled off a sheet. This is Sticker Pop's first motion pattern; its timings are tokens, so the same feel ships on every platform.</p>
      <p class="sp-text-caption">Status: design preview. It runs here in the web library; Compose, Flutter and SwiftUI follow once the motion is signed off.</p>

      <div class="dial-lab">
        <div class="phone sp-paper dial-lab__phone" data-pop-dial-root id="dial-phone" aria-label="Add menu demo">
          <div class="phone__body">
            <div class="sp-text-screen-title" role="heading" aria-level="2">Home</div>
            <div class="sp-card sp-card--hero sp-tilt-l"><span class="sp-text-section-label">Spent in Nov 2026</span><div class="sp-text-hero-amount">₹4,461.70</div></div>
            <div class="sp-card sp-list">
              <div class="sp-row"><span class="sp-dot" style="--sp-dot-fill:var(--sp-color-orange)"><span class="sp-icon">local_cafe</span></span><div class="sp-row__main"><div class="sp-row__title"><span class="sp-text-row-title">Chai Point</span></div><div class="sp-text-caption">Today · 12:32 pm</div></div><span class="sp-text-row-amount">−₹120</span></div>
              <div class="sp-row"><span class="sp-dot" style="--sp-dot-fill:var(--sp-color-blue)"><span class="sp-icon">directions_car</span></span><div class="sp-row__main"><div class="sp-row__title"><span class="sp-text-row-title">Uber</span></div><div class="sp-text-caption">Today · 9:12 am</div></div><span class="sp-text-row-amount">−₹346.50</span></div>
            </div>
          </div>
          <nav class="sp-nav" aria-label="Main">
            <button class="sp-nav__item" aria-current="page"><span class="sp-nav__pill"><span class="sp-icon">home</span></span><span class="sp-nav__label">Home</span></button>
            <button class="sp-nav__item"><span class="sp-nav__pill"><span class="sp-icon">receipt_long</span></span><span class="sp-nav__label">Activity</span></button>
            <div class="sp-nav__add">${dialHtml('dial-demo')}</div>
            <button class="sp-nav__item"><span class="sp-nav__pill"><span class="sp-icon">insights</span></span><span class="sp-nav__label">Insights</span></button>
            <button class="sp-nav__item"><span class="sp-nav__pill"><span class="sp-icon">savings</span></span><span class="sp-nav__label">Wealth</span></button>
          </nav>
        </div>
        <div class="sp-card dial-lab__controls">
          <div class="sp-text-section-label">Try it</div>
          <p class="sp-text-body" style="margin:0">Tap the pink button. Pick an option, tap outside, or press Escape to close.</p>
          <div class="sp-text-section-label">Layout</div>
          <div class="sp-segmented" data-dial-layout="dial-demo"><button aria-pressed="true" data-layout="fan">Fan</button><button aria-pressed="false" data-layout="stack">Stack</button></div>
          <label class="dial-lab__toggle"><span>Slow motion (×4)</span><button class="sp-switch" role="switch" aria-checked="false" aria-label="Slow motion" data-dial-slow="dial-phone"></button></label>
          <label class="dial-lab__toggle"><span>Reduced motion</span><button class="sp-switch" role="switch" aria-checked="false" aria-label="Reduced motion" data-dial-reduced="dial-phone"></button></label>
          <button class="sp-button" data-dial-replay="dial-demo">Play open and close</button>
        </div>
      </div>

      <h2>Choreography</h2>
      <p>Everything starts on the tap. Options leave from behind the button, left to right, and come back in reverse, faster. Opening uses an overshoot so each option lands like a sticker slapped down; closing has none, so the menu gets out of the way.</p>
      <div class="table-wrap"><table>
        <thead><tr><th>What</th><th>Duration</th><th>Easing</th><th>Starts at</th></tr></thead>
        <tbody>
          <tr><td>Paper scrim fades in (paper at 88%, so outlines and shadows stay crisp)</td><td>200 <code>dialScrim</code></td><td>linear</td><td>0</td></tr>
          <tr><td>The + spins 45° into ×; the button straightens from −6° to 0°</td><td>280 <code>dialOpen</code></td><td>pop</td><td>0</td></tr>
          <tr><td>Each option flies from the button to its spot, grows from 40% to 100% and settles at its tilt (−3°, +2°, −2°)</td><td>280 <code>dialOpen</code></td><td>pop</td><td>0, 40, 80 <code>dialStagger</code></td></tr>
          <tr><td>Each label fades up 4</td><td>140</td><td>ease-out</td><td>its option + 150</td></tr>
          <tr><td>Choosing: the option presses into its shadow (moves 4/4), then the menu closes</td><td>90 <code>dialPress</code></td><td>linear</td><td>on tap</td></tr>
          <tr><td>Closing: options return behind the button, last one first; × turns back into +; scrim fades out</td><td>180 <code>dialClose</code></td><td>ease-in</td><td>0, 20, 40</td></tr>
        </tbody>
      </table></div>
      <p>Pop easing is <code>cubic-bezier(0.34, 1.56, 0.64, 1)</code>: it goes about 10% past the end and settles back. Ease-in is <code>cubic-bezier(0.4, 0, 1, 1)</code>. The whole open takes 360 ms, including the last option's 80 ms delay; the close takes 220 ms.</p>

      <h2>Layout</h2>
      <div class="table-wrap"><table>
        <tbody>
          <tr><td>Option</td><td>56 × 56 sticker, radius 18, 2.5 outline, 4/4 shadow, 26 icon, a bright fill each (Type it white, Say it pink, Scan it mint)</td></tr>
          <tr><td>Label</td><td>white badge under the sticker, 2 outline, 13/800</td></tr>
          <tr><td>Fan (default)</td><td>2 to 4 options on an arc above the button: 120° wide (64° for two), 96 out to each side, the middle one highest. Fits a 320 wide phone.</td></tr>
          <tr><td>Stack</td><td>a column straight up, 76 apart, labels on the left. Use it for 4 or more options or long labels.</td></tr>
          <tr><td>Scrim</td><td>covers the screen and the other nav items; the add button stays above it as the close button</td></tr>
        </tbody>
      </table></div>

      <h2>Reduced motion</h2>
      <p>With the system's reduce-motion setting on, nothing travels, grows or spins: the options and scrim fade in place in 150 ms (<code>fade</code>) and the × swaps instantly. Try the switch above.</p>

      <h2>Accessibility</h2>
      <ul>
        <li>The button is labelled "Add transaction" when closed and "Close add menu" when open, and says whether the menu is expanded.</li>
        <li>Opening by keyboard moves focus to the first option; the arrow keys move between options; Escape closes and returns focus to the button. A tap outside or focus leaving the menu also closes it.</li>
        <li>On Android the back gesture closes the menu. On phones, opening gives a light haptic tap and choosing gives a selection tick.</li>
        <li>Every option keeps its label visible; the icon is never the only cue.</li>
      </ul>

      <h2>Usage</h2>
      ${codeBlock({
        html: `<div class="phone" data-pop-dial-root>  <!-- the screen the scrim covers -->
  …
  <nav class="sp-nav">
    …
    <div class="sp-nav__add">
      <div class="sp-dial" data-pop-dial data-close-label="Close add menu">
        <button class="sp-add" aria-label="Add transaction"><span class="sp-icon">add</span></button>
        <div class="sp-dial__menu">
          <button class="sp-dial__option" data-value="type"><span class="sp-dial__sticker sp-fill-white"><span class="sp-icon">keyboard</span></span><span class="sp-dial__label">Type it</span></button>
          <button class="sp-dial__option" data-value="say"><span class="sp-dial__sticker sp-fill-pink"><span class="sp-icon">mic</span></span><span class="sp-dial__label">Say it</span></button>
          <button class="sp-dial__option" data-value="scan"><span class="sp-dial__sticker sp-fill-mint"><span class="sp-icon">document_scanner</span></span><span class="sp-dial__label">Scan it</span></button>
        </div>
      </div>
    </div>
    …
  </nav>
</div>

<script type="module">
  import { wirePopDials } from '@sticker-pop/web/behaviors.mjs';
  wirePopDials();
  document.addEventListener('pop-dial-select', (e) => start(e.detail.value));
</script>`,
        flutter: `// Planned API
PopNavBar(
  items: items,
  selectedIndex: tab,
  onSelected: (i) => setState(() => tab = i),
  addMenu: [
    PopAddMenuItem(icon: Icons.keyboard_rounded, label: 'Type it', color: PopColors.white, onTap: typeIt),
    PopAddMenuItem(icon: Icons.mic_rounded, label: 'Say it', color: PopColors.pink, onTap: sayIt),
    PopAddMenuItem(icon: Icons.document_scanner_rounded, label: 'Scan it', color: PopColors.mint, onTap: scanIt),
  ],
)`,
        compose: `// Planned API
PopNavBar(
    items, selected = tab, onSelect = { tab = it },
    addMenu = listOf(
        PopAddMenuItem(Icons.Rounded.Keyboard, "Type it", PopColors.white, ::typeIt),
        PopAddMenuItem(Icons.Rounded.Mic, "Say it", PopColors.pink, ::sayIt),
        PopAddMenuItem(Icons.Rounded.DocumentScanner, "Scan it", PopColors.mint, ::scanIt),
    ),
)`,
        swift: `// Planned API
PopNavBar(items: items, selection: $tab, addMenu: [
    PopAddMenuItem(systemImage: "keyboard", label: "Type it", fill: PopColors.white, action: typeIt),
    PopAddMenuItem(systemImage: "mic.fill", label: "Say it", fill: PopColors.pink, action: sayIt),
    PopAddMenuItem(systemImage: "doc.viewfinder", label: "Scan it", fill: PopColors.mint, action: scanIt),
])`,
      })}
      <p>With no add menu, the button keeps its single action (<code>onAdd</code>), as today.</p>
    `,
  },
];
