// Sticker Pop docs site. No build step and no dependencies: hash routes,
// pages rendered from the generated tokens and the component registry.
import tokens from './sp/tokens.mjs';
import { components, groups } from './content/components.js';
import { guidePages } from './content/guides.js';
import { foundationPages } from './content/foundations.js';
import { otherPages } from './content/pages.js';
import { esc, kebab, store, contrast } from './content/util.js';
import { stabilizePopChips, wirePopDials, layoutPopDial, wirePopMenus, wirePopSelects } from './sp/behaviors.mjs';

const VERSION = '0.1.0';
const main = document.getElementById('main');
const nav = document.getElementById('nav');

// Alphabetical, so no platform is the default. The site remembers the last pick.
const PLATFORMS = [
  ['compose', 'Compose'],
  ['flutter', 'Flutter'],
  ['swift', 'SwiftUI'],
  ['html', 'Web'],
];

/** A tabbed code block. `code` maps platform → source (missing = not available). */
export function codeBlock(code) {
  const available = PLATFORMS.filter(([k]) => code[k]);
  if (!available.length) return '';
  let current = store.get('sp-platform', PLATFORMS[0][0]);
  if (!code[current]) current = available[0][0];
  return `<div class="code">
    <div class="code__tabs" role="tablist" aria-label="Platform">
      ${available.map(([k, label]) => `<button role="tab" data-platform="${k}" aria-selected="${k === current}">${label}</button>`).join('')}
      <button class="code__copy" data-copy>Copy</button>
    </div>
    ${available.map(([k]) => `<pre ${k === current ? '' : 'hidden'} data-pane="${k}"><code>${esc(code[k].trim())}</code></pre>`).join('')}
  </div>`;
}

function wireCode(root) {
  root.querySelectorAll('.code').forEach((block) => {
    block.querySelectorAll('[role=tab]').forEach((tab) => tab.addEventListener('click', () => {
      const p = tab.dataset.platform;
      store.set('sp-platform', p);
      root.querySelectorAll('.code').forEach((b) => {
        if (!b.querySelector(`[data-pane="${p}"]`)) return;
        b.querySelectorAll('[role=tab]').forEach((t) => t.setAttribute('aria-selected', t.dataset.platform === p));
        b.querySelectorAll('pre').forEach((pre) => { pre.hidden = pre.dataset.pane !== p; });
      });
    }));
    block.querySelector('[data-copy]')?.addEventListener('click', async (e) => {
      const pre = block.querySelector('pre:not([hidden])');
      try {
        await navigator.clipboard.writeText(pre.textContent);
        e.target.textContent = 'Copied';
      } catch {
        e.target.textContent = 'Select and copy';
      }
      setTimeout(() => { e.target.textContent = 'Copy'; }, 1500);
    });
  });
}

/** The add menu demos and their review controls (layout, slow motion, reduced motion, replay). */
function wireDialLab(root) {
  wirePopDials(root);
  root.querySelectorAll('[data-pop-dial]').forEach((d) => d.addEventListener('pop-dial-select', (e) => toast(`${e.detail.label} opens here`)));
  root.querySelectorAll('[data-dial-layout]').forEach((seg) => seg.querySelectorAll('button').forEach((b) => b.addEventListener('click', () => {
    const dial = document.getElementById(seg.dataset.dialLayout);
    dial.popDial?.close();
    dial.classList.toggle('sp-dial--stack', b.dataset.layout === 'stack');
    layoutPopDial(dial);
  })));
  root.querySelectorAll('[data-dial-slow]').forEach((sw) => sw.addEventListener('click', () => {
    document.getElementById(sw.dataset.dialSlow).style.setProperty('--sp-motion-scale', sw.getAttribute('aria-checked') === 'true' ? '4' : '1');
  }));
  root.querySelectorAll('[data-dial-reduced]').forEach((sw) => sw.addEventListener('click', () => {
    document.getElementById(sw.dataset.dialReduced).classList.toggle('sp-motion-reduced', sw.getAttribute('aria-checked') === 'true');
  }));
  root.querySelectorAll('[data-dial-replay]').forEach((b) => b.addEventListener('click', () => {
    const dial = document.getElementById(b.dataset.dialReplay);
    const scale = Number(getComputedStyle(dial).getPropertyValue('--sp-motion-scale')) || 1;
    dial.popDial.open();
    setTimeout(() => dial.popDial.close(), 1600 * scale);
  }));
}

/** Makes the demos interactive: chips, segments, switches, nav, snackbars, dialogs. */
function wireDemos(root) {
  stabilizePopChips(root);
  wirePopMenus(root);
  wirePopSelects(root);
  root.querySelectorAll('input[data-indeterminate]').forEach((i) => { i.indeterminate = true; });
  root.querySelectorAll('.sp-chip[aria-pressed]:not(:disabled)').forEach((b) =>
    b.addEventListener('click', () => b.setAttribute('aria-pressed', b.getAttribute('aria-pressed') !== 'true')));
  root.querySelectorAll('.sp-segmented:not([aria-disabled]) > button').forEach((b) =>
    b.addEventListener('click', () => b.parentElement.querySelectorAll('button').forEach((x) => x.setAttribute('aria-pressed', x === b))));
  root.querySelectorAll('.sp-switch:not(:disabled)').forEach((b) =>
    b.addEventListener('click', () => b.setAttribute('aria-checked', b.getAttribute('aria-checked') !== 'true')));
  root.querySelectorAll('.sp-nav').forEach((n) => n.querySelectorAll('.sp-nav__item').forEach((b) =>
    b.addEventListener('click', () => { n.querySelectorAll('.sp-nav__item').forEach((x) => x.removeAttribute('aria-current')); b.setAttribute('aria-current', 'page'); })));
  root.querySelectorAll('[data-snack]').forEach((b) => b.addEventListener('click', () => toast(b.dataset.snack, b.dataset.action)));
  wireDialLab(root);
  root.querySelectorAll('[data-dialog]').forEach((b) => b.addEventListener('click', () => {
    const d = document.getElementById(b.dataset.dialog);
    if (d && typeof d.showModal === 'function') d.showModal();
  }));
  root.querySelectorAll('.app-frame').forEach(async (frame) => {
    // The Flutter app ships only with full builds (tools/build-site.mjs).
    let ok = false;
    try { ok = (await fetch('app/flutter_bootstrap.js', { method: 'HEAD' })).ok; } catch { ok = false; }
    if (!ok) {
      frame.outerHTML = `<div class="sp-card sp-hint"><span class="sp-icon">info</span><div><div class="sp-text-row-title">The gallery app isn't in this copy of the site</div><div class="sp-text-body">Build the site with <code>node tools/build-site.mjs</code> to include it, or run <code>flutter run -d chrome</code> in <code>packages/flutter/sticker_pop/example</code>.</div></div></div>`;
    }
  });
  root.querySelectorAll('dialog [data-close]').forEach((b) => b.addEventListener('click', () => b.closest('dialog').close()));
}

let toastTimer;
function toast(message, action) {
  document.querySelector('.toast-host')?.remove();
  const host = document.createElement('div');
  host.className = 'toast-host';
  host.setAttribute('role', 'status');
  host.innerHTML = `<div class="sp-snackbar">${esc(message)}${action ? `<button>${esc(action)}</button>` : ''}</div>`;
  document.body.append(host);
  host.querySelector('button')?.addEventListener('click', () => host.remove());
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => host.remove(), action ? tokens.motion.snackbarWithAction : tokens.motion.snackbar);
}

function renderNav(path) {
  const link = (href, label) => `<a href="#${href}" ${path === href ? 'aria-current="page"' : ''}>${esc(label)}</a>`;
  nav.innerHTML = `
    ${link('', 'Overview')}
    ${link('install', 'Install')}
    <h2>Foundations</h2>
    ${foundationPages.map((p) => link(p.id, p.title)).join('')}
    <h2>Guidelines</h2>
    ${guidePages.map((g) => link(g.id, g.title)).join('')}
    ${groups.map((g) => `<h2>${esc(g)}</h2>${components.filter((c) => c.group === g).map((c) => link(`c-${c.id}`, c.name)).join('')}`).join('')}
    <h2>Examples</h2>
    ${link('home', 'Home screen')}
    ${link('app', 'Gallery apps')}
  `;
}

function componentPage(c) {
  const i = components.indexOf(c);
  const prev = components[i - 1];
  const next = components[i + 1];
  return `<div class="page">
    <span class="sp-badge sp-fill-lilac" style="justify-self:start">${esc(c.group)}</span>
    <h1>${esc(c.name)}</h1>
    <p class="lede">${c.summary}</p>
    <h2>States</h2>
    <div class="state-grid">${c.states.map((s) => `<div class="state"><span class="state__label">${esc(s.label)}</span><div class="state__body">${s.html}</div></div>`).join('')}</div>
    ${c.extra ?? ''}
    <h2>Usage</h2>
    ${codeBlock(c.code)}
    <h2>Spec</h2>
    <div class="table-wrap"><table><tbody>${c.spec.map(([k, v]) => `<tr><th style="width:34%">${esc(k)}</th><td>${v}</td></tr>`).join('')}</tbody></table></div>
    ${c.rules?.length ? `<h2>Guidelines</h2><ul>${c.rules.map((r) => `<li>${r}</li>`).join('')}</ul>` : ''}
    ${c.a11y ? `<h2>Accessibility</h2><p>${c.a11y}</p>` : ''}
    <p class="sp-text-caption">Available in: ${c.platforms.join(' · ')}</p>
    <div class="pager">
      ${prev ? `<a class="sp-card tile-link" href="#c-${prev.id}"><span class="sp-text-caption">Previous</span><b>${esc(prev.name)}</b></a>` : '<span></span>'}
      ${next ? `<a class="sp-card tile-link" style="text-align:right" href="#c-${next.id}"><span class="sp-text-caption">Next</span><b>${esc(next.name)}</b></a>` : ''}
    </div>
  </div>`;
}

const ctx = { esc, kebab, tokens, codeBlock, contrast, components };
const allPages = [...otherPages, ...foundationPages, ...guidePages];

function route() {
  const path = location.hash.replace(/^#\/?/, '').replace(/^components\//, 'c-');
  let html;
  let title = 'Sticker Pop';
  if (path.startsWith('c-')) {
    const c = components.find((x) => x.id === path.slice(2));
    if (c) { html = componentPage(c); title = `${c.name} · Sticker Pop`; }
  } else {
    const p = allPages.find((x) => x.id === path);
    if (p) { html = `<div class="page"${p.wide ? ' style="max-width:none"' : ''}>${p.render(ctx)}</div>`; if (p.title) title = `${p.title} · Sticker Pop`; }
  }
  if (!html) html = '<div class="page"><h1>Page not found</h1><p class="lede">That page doesn\'t exist. <a href="#">Go to the overview</a>.</p></div>';
  main.innerHTML = html + `<footer class="site-footer sp-text-caption">Sticker Pop v${VERSION} · MIT licence · Bricolage Grotesque under the SIL OFL · <a href="https://github.com/stupidly-logical/sticker-pop">GitHub</a></footer>`;
  document.title = title;
  renderNav(path);
  wireCode(main);
  wireDemos(main);
  nav.classList.remove('is-open');
  document.querySelector('.menu-btn').setAttribute('aria-expanded', 'false');
  window.scrollTo(0, 0);
  main.focus({ preventScroll: true });
}

document.querySelector('.menu-btn').addEventListener('click', (e) => {
  const open = nav.classList.toggle('is-open');
  e.currentTarget.setAttribute('aria-expanded', open);
});
window.addEventListener('hashchange', route);
route();
