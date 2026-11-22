// Sticker Pop behaviours for the web: the interactive parts that CSS alone
// can't do. No dependencies; works with the markup in components.css.
import tokens from './tokens.mjs';
import { popInitials, popAvatarColor } from './format.mjs';

const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

/**
 * Makes chips, segments, switches and nav items in `root` toggle their ARIA
 * state on click (aria-pressed, aria-checked, aria-current), and wires add menus, menus
 * and selects.
 */
export function wirePopControls(root = document) {
  stabilizePopChips(root);
  wirePopDials(root);
  wirePopMenus(root);
  wirePopSelects(root);
  wirePopTopBars(root);
  wirePopSearch(root);
  wirePopDateTiles(root);
  wirePopTabs(root);
  wirePopSliders(root);
  wirePopSteppers(root);
  wirePopKeypads(root);
  wirePopAvatars(root);
  wirePopTooltips(root);
  root.querySelectorAll('.sp-chip[aria-pressed]:not(:disabled)').forEach((b) =>
    b.addEventListener('click', () => b.setAttribute('aria-pressed', String(b.getAttribute('aria-pressed') !== 'true'))));
  root.querySelectorAll('.sp-segmented:not([aria-disabled]) > button').forEach((b) =>
    b.addEventListener('click', () => b.parentElement.querySelectorAll('button').forEach((x) => x.setAttribute('aria-pressed', String(x === b)))));
  root.querySelectorAll('.sp-switch:not(:disabled)').forEach((b) =>
    b.addEventListener('click', () => b.setAttribute('aria-checked', String(b.getAttribute('aria-checked') !== 'true'))));
  root.querySelectorAll('.sp-nav').forEach((nav) => nav.querySelectorAll('.sp-nav__item').forEach((b) =>
    b.addEventListener('click', () => {
      nav.querySelectorAll('.sp-nav__item').forEach((x) => x.removeAttribute('aria-current'));
      b.setAttribute('aria-current', 'page');
    })));
}

/**
 * Wraps each chip's text in .sp-chip__label so it reserves the width of its
 * bold (selected) form; the chip then never changes size when toggled.
 */
export function stabilizePopChips(root = document) {
  root.querySelectorAll('.sp-chip').forEach((chip) => {
    if (chip.querySelector('.sp-chip__label')) return;
    for (const node of [...chip.childNodes]) {
      if (node.nodeType !== Node.TEXT_NODE || !node.textContent.trim()) continue;
      const label = document.createElement('span');
      label.className = 'sp-chip__label';
      label.dataset.label = node.textContent.trim();
      label.textContent = node.textContent.trim();
      node.replaceWith(label);
    }
  });
}

let snackTimer;
/**
 * Shows a floating ink snackbar: 3 s, or 6 s with an action. Only for
 * confirmations ("Saved", "Deleted · Undo"); never for form errors.
 */
export function showPopSnack(message, { actionLabel, onAction } = {}) {
  document.querySelector('.sp-snack-host')?.remove();
  const host = document.createElement('div');
  host.className = 'sp-root sp-snack-host';
  host.setAttribute('role', 'status');
  host.style.cssText = 'position:fixed;left:16px;right:16px;bottom:16px;z-index:1000;max-width:560px;margin:0 auto';
  host.innerHTML = `<div class="sp-snackbar">${esc(message)}${actionLabel ? `<button type="button">${esc(actionLabel)}</button>` : ''}</div>`;
  document.body.append(host);
  host.querySelector('button')?.addEventListener('click', () => { onAction?.(); host.remove(); });
  clearTimeout(snackTimer);
  snackTimer = setTimeout(() => host.remove(), actionLabel ? tokens.motion.snackbarWithAction : tokens.motion.snackbar);
}

/**
 * Opens a <dialog class="sp-dialog"> or <dialog class="sp-sheet"> modally.
 * Elements inside with [data-sp-close] close it.
 */
export function openPop(dialog) {
  dialog.querySelectorAll('[data-sp-close]').forEach((b) => b.addEventListener('click', () => dialog.close(), { once: true }));
  if (typeof dialog.showModal === 'function') dialog.showModal();
}

/**
 * Runs a coach-mark tour: a 72% ink scrim with a rounded, yellow-outlined
 * cut-out around each step's target and a tilted yellow tour card on the
 * roomier side. Resolves true when finished, false when skipped.
 * steps: [{ target: Element | selector, title, body }]
 */
export function showPopTour(steps) {
  return new Promise((resolve) => {
    let i = 0;
    // One overlay for the whole tour: steps move the spotlight and swap the
    // card's text, so the scrim never disappears between steps.
    const layer = document.createElement('div');
    layer.className = 'sp-root';
    layer.style.cssText = 'position:fixed;inset:0;z-index:1000';
    layer.innerHTML = `
      <div data-hole style="position:fixed;border:3px solid var(--sp-color-yellow);border-radius:var(--sp-radius-spotlight);box-shadow:0 0 0 100vmax var(--sp-color-scrim)"></div>
      <div class="sp-tour-card" role="dialog" aria-modal="true" aria-labelledby="sp-tour-title"
           style="position:fixed;left:16px;right:16px;max-width:420px;margin:0 auto">
        <div style="display:flex;align-items:center;justify-content:space-between">
          <div class="sp-dots" data-dots></div>
          <button type="button" class="sp-text-button sp-text-button--underline" data-skip>Skip</button>
        </div>
        <div class="sp-text-sheet-title" id="sp-tour-title" data-title></div>
        <div class="sp-text-body" data-body></div>
        <button type="button" class="sp-button" data-next></button>
      </div>`;
    document.body.append(layer);
    const hole = layer.querySelector('[data-hole]');
    const card = layer.querySelector('.sp-tour-card');
    const close = (done) => { layer.remove(); removeEventListener('resize', place); resolve(done); };
    layer.querySelector('[data-skip]').addEventListener('click', () => close(false));
    layer.querySelector('[data-next]').addEventListener('click', () => {
      if (i === steps.length - 1) close(true);
      else { i++; render(); }
    });

    function target() {
      const t = steps[i].target;
      return typeof t === 'string' ? document.querySelector(t) : t;
    }

    function place() {
      const r = target()?.getBoundingClientRect();
      const pad = 8;
      if (r) {
        Object.assign(hole.style, { left: `${r.left - pad}px`, top: `${r.top - pad}px`, width: `${r.width + pad * 2}px`, height: `${r.height + pad * 2}px`, border: '' });
      } else {
        Object.assign(hole.style, { left: '50%', top: '50%', width: '0', height: '0', border: '0' });
      }
      const below = !r || r.top + r.height / 2 < innerHeight / 2;
      card.style.top = below ? `${(r ? r.bottom + pad : 80) + 16}px` : '';
      card.style.bottom = below ? '' : `${innerHeight - r.top + pad + 16}px`;
    }

    function render() {
      const step = steps[i];
      const last = i === steps.length - 1;
      target()?.scrollIntoView({ block: 'center', behavior: 'instant' });
      layer.querySelector('[data-dots]').innerHTML = steps.map((_, k) => `<i class="${k < i ? 'is-reached' : k === i ? 'is-current' : ''}"></i>`).join('');
      layer.querySelector('[data-dots]').setAttribute('aria-label', `Step ${i + 1} of ${steps.length}`);
      layer.querySelector('[data-skip]').hidden = last;
      layer.querySelector('[data-title]').textContent = step.title;
      layer.querySelector('[data-body]').textContent = step.body;
      layer.querySelector('[data-next]').textContent = last ? 'Got it' : 'Next';
      card.style.transform = `rotate(${i % 2 ? 1.5 : -1.5}deg)`;
      // Measure after the scroll has been applied.
      requestAnimationFrame(place);
      place();
      layer.querySelector('[data-next]').focus({ preventScroll: true });
    }

    addEventListener('resize', place);
    render();
  });
}

// ---------------------------------------------------------------------------
// Add menu (speed dial on the nav add button)

const DIAL_TILTS = { fan: [-3, 2, -2, 3], stack: [-2, 2] };

/**
 * Places the options of one add menu: a fan (an arc above the button, the
 * default) or, with .sp-dial--stack, a column. Call again after changing the
 * layout class or the options.
 */
export function layoutPopDial(dial) {
  const options = [...dial.querySelectorAll('.sp-dial__option')];
  const n = options.length;
  const stack = dial.classList.contains('sp-dial--stack');
  const tilts = DIAL_TILTS[stack ? 'stack' : 'fan'];
  options.forEach((o, i) => {
    let x = 0;
    let y;
    if (stack) {
      y = -(96 + i * 76);
    } else {
      // Spread over 120° (64° for two); the middle option sits highest.
      const span = n <= 1 ? 0 : n === 2 ? 64 : 120;
      const deg = 90 + span / 2 - (n <= 1 ? 0 : (span * i) / (n - 1));
      const a = (deg * Math.PI) / 180;
      x = Math.round(96 * Math.cos(a));
      y = -Math.round(66 + 70 * Math.sin(a));
    }
    o.style.setProperty('--x', `${x}px`);
    o.style.setProperty('--y', `${y}px`);
    o.style.setProperty('--tilt', `${tilts[i % tilts.length]}deg`);
    o.style.setProperty('--i', String(i));
    o.style.setProperty('--ri', String(n - 1 - i));
  });
}

const motionScale = (el) => Number(getComputedStyle(el).getPropertyValue('--sp-motion-scale')) || 1;

/**
 * Wires every [data-pop-dial] in `root`. The add button toggles the menu;
 * Escape, a tap on the scrim or focus leaving the menu closes it; arrow keys
 * move between options. Choosing an option fires a bubbling
 * `pop-dial-select` event ({ value, label }) on the dial, presses the option
 * into its shadow, then closes the menu.
 */
export function wirePopDials(root = document) {
  root.querySelectorAll('[data-pop-dial]').forEach((dial) => {
    if (dial.dataset.popDialWired) return;
    dial.dataset.popDialWired = '1';
    const button = dial.querySelector('.sp-add');
    const menu = dial.querySelector('.sp-dial__menu');
    const options = [...menu.querySelectorAll('.sp-dial__option')];
    if (!menu.id) menu.id = `sp-dial-${Math.random().toString(36).slice(2, 8)}`;
    menu.setAttribute('role', 'menu');
    options.forEach((o) => { o.setAttribute('role', 'menuitem'); o.tabIndex = -1; });
    button.setAttribute('aria-haspopup', 'menu');
    button.setAttribute('aria-controls', menu.id);
    button.setAttribute('aria-expanded', 'false');
    const closedLabel = button.getAttribute('aria-label') || 'Add';
    const openLabel = dial.dataset.closeLabel || 'Close add menu';
    layoutPopDial(dial);

    const host = dial.closest('[data-pop-dial-root]');
    const scrim = document.createElement('div');
    scrim.className = host ? 'sp-dial-scrim' : 'sp-dial-scrim sp-dial-scrim--page';
    (host ?? document.body).appendChild(scrim);

    let open = false;
    const set = (next, { focus = true } = {}) => {
      if (next === open) return;
      open = next;
      dial.toggleAttribute('data-open', open);
      scrim.toggleAttribute('data-open', open);
      button.setAttribute('aria-expanded', String(open));
      button.setAttribute('aria-label', open ? openLabel : closedLabel);
      options.forEach((o) => { o.tabIndex = open ? 0 : -1; });
      if (focus) (open ? options[0] : button)?.focus({ preventScroll: true });
    };

    button.addEventListener('click', () => set(!open, { focus: open || button.matches(':focus-visible') }));
    scrim.addEventListener('click', () => set(false, { focus: false }));
    dial.addEventListener('keydown', (e) => {
      if (!open) return;
      if (e.key === 'Escape') { e.preventDefault(); set(false); return; }
      const i = options.indexOf(document.activeElement);
      if (i < 0) return;
      const step = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 }[e.key];
      if (step) { e.preventDefault(); options[(i + step + options.length) % options.length].focus(); }
      if (e.key === 'Home') { e.preventDefault(); options[0].focus(); }
      if (e.key === 'End') { e.preventDefault(); options.at(-1).focus(); }
    });
    dial.addEventListener('focusout', (e) => {
      if (open && e.relatedTarget && !dial.contains(e.relatedTarget)) set(false, { focus: false });
    });
    options.forEach((o) => o.addEventListener('click', () => {
      o.toggleAttribute('data-chosen', true);
      const label = o.querySelector('.sp-dial__label')?.textContent ?? '';
      dial.dispatchEvent(new CustomEvent('pop-dial-select', { bubbles: true, detail: { value: o.dataset.value ?? label, label } }));
      setTimeout(() => { set(false); o.removeAttribute('data-chosen'); }, tokens.motion.dialPress * motionScale(dial));
    }));
    dial.popDial = { open: () => set(true, { focus: false }), close: () => set(false, { focus: false }), get isOpen() { return open; } };
  });
}

// ---------------------------------------------------------------------------
// Menus and selects (popovers)

const EDGE = tokens.space.sm;

/**
 * Places a popover next to its anchor: below, lined up with the anchor's
 * trailing edge (`align: 'end'`, menus) or leading edge (`'start'`, selects),
 * flipped above when there's no room, and kept 8 from the window edges.
 */
export function placePopover(pop, anchor, { align = 'end', matchWidth = false } = {}) {
  const a = anchor.getBoundingClientRect();
  if (matchWidth) pop.style.minWidth = `${Math.max(a.width, tokens.size.menuMinWidth)}px`;
  const w = pop.offsetWidth;
  const h = pop.offsetHeight;
  const vw = document.documentElement.clientWidth;
  const vh = window.innerHeight;
  let x = align === 'end' ? a.right - w : a.left;
  x = Math.min(Math.max(x, EDGE), Math.max(EDGE, vw - w - EDGE));
  const below = a.bottom + EDGE;
  const above = below + h > vh - EDGE && a.top - EDGE - h >= EDGE;
  const y = above ? a.top - EDGE - h : Math.min(below, Math.max(EDGE, vh - h - EDGE));
  pop.style.left = `${Math.round(x)}px`;
  pop.style.top = `${Math.round(y)}px`;
  pop.classList.toggle('is-above', above);
}

/** Keeps an open popover next to its anchor while the page scrolls or resizes. */
function follow(pop, anchor, opts) {
  const place = () => pop.matches(':popover-open') && placePopover(pop, anchor, opts);
  pop.addEventListener('toggle', (e) => {
    if (e.newState === 'open') {
      window.addEventListener('scroll', place, true);
      window.addEventListener('resize', place);
    } else {
      window.removeEventListener('scroll', place, true);
      window.removeEventListener('resize', place);
    }
  });
}

/** Arrow keys, Home and End move focus between `items`. */
function roveFocus(container, items) {
  container.addEventListener('keydown', (e) => {
    const list = items().filter((x) => !x.disabled && x.getAttribute('aria-disabled') !== 'true');
    const i = list.indexOf(document.activeElement);
    const to = { ArrowDown: i + 1, ArrowUp: i - 1, Home: 0, End: list.length - 1 }[e.key];
    if (to === undefined || !list.length) return;
    e.preventDefault();
    list[(to + list.length) % list.length].focus();
  });
}

const supportsPopover = typeof HTMLElement !== 'undefined' && 'popover' in HTMLElement.prototype;

/**
 * Wires every `.sp-menu[popover]` in `root` that a `[popovertarget]` button
 * opens: positions it under the button (trailing edges lined up), moves focus
 * to the first item, arrow keys move between items, and picking an item
 * closes it. The browser handles Escape and taps outside.
 */
export function wirePopMenus(root = document) {
  if (!supportsPopover) return;
  root.querySelectorAll('.sp-menu[popover]:not(.sp-select__list)').forEach((menu) => {
    if (menu.dataset.popWired) return;
    menu.dataset.popWired = '1';
    if (!menu.getAttribute('role')) menu.setAttribute('role', 'menu');
    const items = () => [...menu.querySelectorAll('.sp-menu__item')];
    items().forEach((it) => { if (!it.getAttribute('role')) it.setAttribute('role', 'menuitem'); });
    const invoker = () => document.querySelector(`[popovertarget="${CSS.escape(menu.id)}"]`);
    invoker()?.setAttribute('aria-haspopup', 'menu');
    menu.addEventListener('toggle', (e) => {
      const button = invoker();
      button?.setAttribute('aria-expanded', String(e.newState === 'open'));
      if (e.newState !== 'open' || !button) return;
      placePopover(menu, button, { align: 'end' });
      items().find((x) => !x.disabled)?.focus({ preventScroll: true });
    });
    const button = invoker();
    if (button) follow(menu, button, { align: 'end' });
    roveFocus(menu, items);
    menu.addEventListener('keydown', (e) => { if (e.key === 'Tab') menu.hidePopover(); });
    menu.addEventListener('click', (e) => {
      const item = e.target.closest('.sp-menu__item');
      if (item && !item.disabled && item.getAttribute('aria-disabled') !== 'true') menu.hidePopover();
    });
  });
}

let popSeq = 0;

/**
 * Turns every native `select.sp-select` in `root` into a Sticker Pop select:
 * a field-style trigger and a listbox popover of sticker rows (the chosen one
 * yellow with a tick). The native select stays in the DOM and in sync, so
 * forms, `change` events and `select.value` keep working. Options can carry
 * `data-icon` (a Material Symbols name) and `data-caption`; an option with
 * `value=""` is the placeholder. Without popover support the native select is
 * left as it is (still styled).
 */
export function wirePopSelects(root = document) {
  if (!supportsPopover) return;
  root.querySelectorAll('select.sp-select').forEach((select) => {
    if (select.dataset.popWired) return;
    select.dataset.popWired = '1';
    const n = ++popSeq;
    const wrap = document.createElement('div');
    wrap.className = 'sp-select-wrap';
    select.before(wrap);
    wrap.append(select);
    select.tabIndex = -1;
    select.setAttribute('aria-hidden', 'true');

    const trigger = document.createElement('button');
    trigger.type = 'button';
    trigger.className = 'sp-select__trigger';
    trigger.setAttribute('aria-haspopup', 'listbox');
    trigger.setAttribute('aria-expanded', 'false');
    const list = document.createElement('div');
    list.className = 'sp-menu sp-select__list';
    list.id = `sp-select-list-${n}`;
    list.setAttribute('role', 'listbox');
    list.popover = 'auto';
    trigger.setAttribute('aria-controls', list.id);
    trigger.popoverTargetElement = list;
    wrap.append(trigger, list);

    const label = select.id ? document.querySelector(`label[for="${CSS.escape(select.id)}"]`) : null;
    const valueId = `sp-select-value-${n}`;
    if (label) {
      label.id ||= `sp-select-label-${n}`;
      trigger.setAttribute('aria-labelledby', `${label.id} ${valueId}`);
      label.addEventListener('click', (e) => { e.preventDefault(); trigger.focus(); });
    } else if (select.getAttribute('aria-label')) {
      trigger.setAttribute('aria-label', select.getAttribute('aria-label'));
    }

    const rows = () => [...list.querySelectorAll('.sp-menu__item')];
    const build = () => {
      list.replaceChildren(...[...select.options].filter((o) => o.value !== '' && !o.hidden).map((o) => {
        const row = document.createElement('div');
        row.className = 'sp-menu__item';
        row.setAttribute('role', 'option');
        row.tabIndex = -1;
        row.dataset.value = o.value;
        if (o.disabled) row.setAttribute('aria-disabled', 'true');
        row.innerHTML = `${o.dataset.icon ? `<span class="sp-icon" aria-hidden="true">${esc(o.dataset.icon)}</span>` : ''}<span class="sp-menu__text"><span class="sp-menu__label">${esc(o.textContent.trim())}</span>${o.dataset.caption ? `<span class="sp-menu__caption">${esc(o.dataset.caption)}</span>` : ''}</span><span class="sp-icon sp-menu__check" aria-hidden="true">check</span>`;
        return row;
      }));
    };
    const render = () => {
      const o = select.selectedOptions[0];
      const placeholder = !o || o.value === '';
      const icon = !placeholder && o.dataset.icon ? `<span class="sp-icon" aria-hidden="true">${esc(o.dataset.icon)}</span>` : '';
      trigger.innerHTML = `${icon}<span class="sp-select__value${placeholder ? ' is-placeholder' : ''}" id="${valueId}">${esc(o?.textContent.trim() ?? '')}</span><span class="sp-icon sp-select__chevron" aria-hidden="true">expand_more</span>`;
      trigger.disabled = select.disabled;
      wrap.classList.toggle('is-invalid', select.getAttribute('aria-invalid') === 'true');
      rows().forEach((r) => r.setAttribute('aria-selected', String(r.dataset.value === select.value && !placeholder)));
    };
    const pick = (row) => {
      if (!row || row.getAttribute('aria-disabled') === 'true') return;
      if (select.value !== row.dataset.value) {
        select.value = row.dataset.value;
        select.dispatchEvent(new Event('input', { bubbles: true }));
        select.dispatchEvent(new Event('change', { bubbles: true }));
      }
      render();
      list.hidePopover();
    };

    build();
    render();
    follow(list, trigger, { align: 'start', matchWidth: true });
    roveFocus(list, rows);
    list.addEventListener('toggle', (e) => {
      const open = e.newState === 'open';
      trigger.setAttribute('aria-expanded', String(open));
      if (open) {
        placePopover(list, trigger, { align: 'start', matchWidth: true });
        const current = rows().find((r) => r.getAttribute('aria-selected') === 'true') ?? rows()[0];
        current?.focus({ preventScroll: true });
        current?.scrollIntoView({ block: 'nearest' });
      } else if (list.contains(document.activeElement) || document.activeElement === document.body) {
        trigger.focus({ preventScroll: true });
      }
    });
    list.addEventListener('click', (e) => pick(e.target.closest('.sp-menu__item')));
    let typed = '';
    let typedAt = 0;
    list.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); pick(document.activeElement.closest?.('.sp-menu__item')); return; }
      if (e.key === 'Tab') { list.hidePopover(); return; }
      if (e.key.length === 1 && /\S/.test(e.key)) {
        // Type-ahead: jump to the first option starting with what was typed.
        typed = Date.now() - typedAt > 700 ? e.key : typed + e.key;
        typedAt = Date.now();
        rows().find((r) => r.textContent.trim().toLowerCase().startsWith(typed.toLowerCase()))?.focus();
      }
    });
    trigger.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowDown' || e.key === 'ArrowUp') { e.preventDefault(); list.showPopover(); }
    });
    select.addEventListener('change', render);
    new MutationObserver(() => { build(); render(); }).observe(select, { childList: true, subtree: true, attributes: true, attributeFilter: ['disabled', 'aria-invalid'] });
    select.popSelect = { refresh: () => { build(); render(); } };
  });
}

// ---------------------------------------------------------------------------
// Top app bar

function scrollParent(el) {
  for (let p = el.parentElement; p; p = p.parentElement) {
    const o = getComputedStyle(p).overflowY;
    if ((o === 'auto' || o === 'scroll') && p.scrollHeight > p.clientHeight) return p;
  }
  return window;
}

/**
 * Gives every `.sp-top-bar` in `root` its scrolled look (paper fill, ink line
 * along the bottom) while content is scrolled under it. Watches the bar's
 * nearest scrolling ancestor, or the window.
 */
export function wirePopTopBars(root = document) {
  root.querySelectorAll('.sp-top-bar').forEach((bar) => {
    if (bar.dataset.popWired) return;
    bar.dataset.popWired = '1';
    const scroller = scrollParent(bar);
    const update = () => {
      const y = scroller === window ? window.scrollY : scroller.scrollTop;
      bar.classList.toggle('is-scrolled', y > 0);
    };
    scroller.addEventListener('scroll', update, { passive: true });
    update();
  });
}

// ---------------------------------------------------------------------------
// Search field

/** Shows each `.sp-search` clear button while its input has text; the button empties the input and keeps focus there. */
export function wirePopSearch(root = document) {
  root.querySelectorAll('.sp-search').forEach((box) => {
    if (box.dataset.popWired) return;
    box.dataset.popWired = '1';
    const input = box.querySelector('input');
    const clear = box.querySelector('.sp-search__clear');
    if (!input || !clear) return;
    const sync = () => { clear.hidden = !input.value; };
    input.addEventListener('input', sync);
    clear.addEventListener('click', () => {
      input.value = '';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.focus();
    });
    sync();
  });
}

// ---------------------------------------------------------------------------
// Dates

const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const WEEKDAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const dayOnly = (d) => new Date(d.getFullYear(), d.getMonth(), d.getDate());
const sameDay = (a, b) => !!a && !!b && a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();

/** Makes each `.sp-date-tiles` group single-select: the pressed tile gets aria-pressed="true". */
export function wirePopDateTiles(root = document) {
  root.querySelectorAll('.sp-date-tiles').forEach((group) => {
    if (group.dataset.popWired) return;
    group.dataset.popWired = '1';
    group.addEventListener('click', (e) => {
      const tile = e.target.closest('.sp-date-tile[aria-pressed]');
      if (!tile) return;
      group.querySelectorAll('.sp-date-tile[aria-pressed]').forEach((t) => t.setAttribute('aria-pressed', String(t === tile)));
    });
  });
}

/**
 * Renders a month calendar into `el` and keeps it interactive: previous /
 * next month, a 7-column grid of day buttons (chosen: yellow; today: ink
 * ring), arrow keys to move by day or week, Enter to pick. Returns
 * `{ get value, set(date) }`.
 */
export function mountPopCalendar(el, { value = null, today = new Date(), min = null, max = null, firstWeekday = 1, onChange = () => {} } = {}) {
  let selected = value ? dayOnly(value) : null;
  let month = new Date((selected ?? today).getFullYear(), (selected ?? today).getMonth(), 1);
  let focusDay = null;
  const t = dayOnly(today);
  const lo = min ? dayOnly(min) : null;
  const hi = max ? dayOnly(max) : null;
  const ok = (d) => (!lo || d >= lo) && (!hi || d <= hi);
  const render = () => {
    const lead = (month.getDay() - firstWeekday + 7) % 7;
    const days = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
    const canPrev = !lo || new Date(month.getFullYear(), month.getMonth(), 0) >= lo;
    const canNext = !hi || new Date(month.getFullYear(), month.getMonth() + 1, 1) <= hi;
    const heads = Array.from({ length: 7 }, (_, i) => `<span class="sp-calendar__weekday" aria-hidden="true">${WEEKDAYS[(firstWeekday + 6 + i) % 7][0]}</span>`).join('');
    const blanks = '<span></span>'.repeat(lead);
    const cells = Array.from({ length: days }, (_, i) => {
      const d = new Date(month.getFullYear(), month.getMonth(), i + 1);
      const label = `${i + 1} ${MONTHS[d.getMonth()]} ${d.getFullYear()}${sameDay(d, t) ? ', today' : ''}`;
      return `<button type="button" class="sp-calendar__day${sameDay(d, t) ? ' is-today' : ''}" data-day="${i + 1}" aria-pressed="${sameDay(d, selected)}" aria-label="${label}"${ok(d) ? '' : ' disabled'} tabindex="-1">${i + 1}</button>`;
    }).join('');
    el.innerHTML = `<div class="sp-calendar"><div class="sp-calendar__head"><h3 class="sp-calendar__title" aria-live="polite">${MONTHS[month.getMonth()]} ${month.getFullYear()}</h3><button type="button" class="sp-icon-button" data-nav="-1" aria-label="Previous month"${canPrev ? '' : ' disabled'}><span class="sp-icon">chevron_left</span></button><button type="button" class="sp-icon-button" data-nav="1" aria-label="Next month"${canNext ? '' : ' disabled'}><span class="sp-icon">chevron_right</span></button></div><div class="sp-calendar__grid">${heads}${blanks}${cells}</div></div>`;
    const buttons = [...el.querySelectorAll('.sp-calendar__day')];
    const target = buttons.find((b) => focusDay && +b.dataset.day === focusDay.getDate() && focusDay.getMonth() === month.getMonth())
      ?? buttons.find((b) => b.getAttribute('aria-pressed') === 'true') ?? buttons.find((b) => b.classList.contains('is-today')) ?? buttons.find((b) => !b.disabled);
    if (target) target.tabIndex = 0;
    if (focusDay && target) target.focus();
  };
  el.addEventListener('click', (e) => {
    const nav = e.target.closest('[data-nav]');
    if (nav) { month = new Date(month.getFullYear(), month.getMonth() + Number(nav.dataset.nav), 1); focusDay = null; render(); return; }
    const day = e.target.closest('.sp-calendar__day');
    if (!day || day.disabled) return;
    selected = new Date(month.getFullYear(), month.getMonth(), Number(day.dataset.day));
    focusDay = selected;
    render();
    onChange(selected);
  });
  el.addEventListener('keydown', (e) => {
    const day = e.target.closest('.sp-calendar__day');
    const step = { ArrowLeft: -1, ArrowRight: 1, ArrowUp: -7, ArrowDown: 7 }[e.key];
    if (!day || step === undefined) return;
    e.preventDefault();
    const d = new Date(month.getFullYear(), month.getMonth(), Number(day.dataset.day) + step);
    if (!ok(d)) return;
    focusDay = d;
    if (d.getMonth() !== month.getMonth() || d.getFullYear() !== month.getFullYear()) month = new Date(d.getFullYear(), d.getMonth(), 1);
    render();
  });
  render();
  return { get value() { return selected; }, set(d) { selected = d ? dayOnly(d) : null; if (d) month = new Date(d.getFullYear(), d.getMonth(), 1); render(); } };
}

// ---------------------------------------------------------------------------
// Tabs

/**
 * Wires each `.sp-tabs[role=tablist]`: clicking or arrow keys select a tab
 * (aria-selected, roving tabindex), and a tab's `aria-controls` panel is
 * shown while the others are hidden.
 */
export function wirePopTabs(root = document) {
  root.querySelectorAll('.sp-tabs[role="tablist"]').forEach((list) => {
    if (list.dataset.popWired) return;
    list.dataset.popWired = '1';
    const tabs = () => [...list.querySelectorAll('[role="tab"]')];
    const select = (tab, focus) => {
      tabs().forEach((t) => {
        const on = t === tab;
        t.setAttribute('aria-selected', String(on));
        t.tabIndex = on ? 0 : -1;
        const panel = t.getAttribute('aria-controls') && document.getElementById(t.getAttribute('aria-controls'));
        if (panel) panel.hidden = !on;
      });
      if (focus) tab.focus();
      list.dispatchEvent(new CustomEvent('pop-tab-change', { bubbles: true, detail: { index: tabs().indexOf(tab) } }));
    };
    list.addEventListener('click', (e) => { const t = e.target.closest('[role="tab"]'); if (t) select(t, false); });
    list.addEventListener('keydown', (e) => {
      const all = tabs();
      const i = all.indexOf(document.activeElement);
      const to = { ArrowRight: i + 1, ArrowLeft: i - 1, Home: 0, End: all.length - 1 }[e.key];
      if (i < 0 || to === undefined) return;
      e.preventDefault();
      select(all[(to + all.length) % all.length], true);
    });
    select(tabs().find((t) => t.getAttribute('aria-selected') === 'true') ?? tabs()[0], false);
  });
}

// ---------------------------------------------------------------------------
// Slider

/** Keeps each `.sp-slider`'s mint fill (--sp-slider-fill) in step with its range input. */
export function wirePopSliders(root = document) {
  root.querySelectorAll('.sp-slider').forEach((box) => {
    const input = box.querySelector('input[type="range"]');
    if (!input || box.dataset.popWired) return;
    box.dataset.popWired = '1';
    const sync = () => {
      const min = Number(input.min || 0);
      const max = Number(input.max || 100);
      box.style.setProperty('--sp-slider-fill', String(max === min ? 0 : (Number(input.value) - min) / (max - min)));
    };
    input.addEventListener('input', sync);
    sync();
  });
}

// ---------------------------------------------------------------------------
// Stepper

/**
 * Wires each `.sp-stepper` (data-min, data-max, data-step, a value in
 * `.sp-stepper__value`): the − and + buttons step it, disable at the limits,
 * and fire a bubbling `pop-step` event with `{ value }`.
 */
export function wirePopSteppers(root = document) {
  root.querySelectorAll('.sp-stepper').forEach((box) => {
    if (box.dataset.popWired) return;
    box.dataset.popWired = '1';
    const out = box.querySelector('.sp-stepper__value');
    const [down, up] = box.querySelectorAll('button');
    const min = Number(box.dataset.min ?? 0);
    const max = Number(box.dataset.max ?? 99);
    const step = Number(box.dataset.step ?? 1);
    let value = Number(out.textContent);
    const render = () => {
      out.textContent = String(value);
      down.disabled = value - step < min;
      up.disabled = value + step > max;
    };
    const set = (v) => { value = v; render(); box.dispatchEvent(new CustomEvent('pop-step', { bubbles: true, detail: { value } })); };
    down.addEventListener('click', () => set(value - step));
    up.addEventListener('click', () => set(value + step));
    render();
  });
}

// ---------------------------------------------------------------------------
// Number keypad

/**
 * Wires each `.sp-keypad` (buttons with data-key="0"–"9", "." or "⌫"):
 * clicks fire a bubbling `pop-key` event with `{ key }`. Pair it with
 * `applyPopKey` from format.mjs.
 */
export function wirePopKeypads(root = document) {
  root.querySelectorAll('.sp-keypad').forEach((pad) => {
    if (pad.dataset.popWired) return;
    pad.dataset.popWired = '1';
    pad.addEventListener('click', (e) => {
      const b = e.target.closest('button[data-key]');
      if (b) pad.dispatchEvent(new CustomEvent('pop-key', { bubbles: true, detail: { key: b.dataset.key } }));
    });
  });
}

// ---------------------------------------------------------------------------
// Avatar

/** Fills each `.sp-avatar[data-name]` with its initials and the colour its name always gets, and labels it. */
export function wirePopAvatars(root = document) {
  root.querySelectorAll('.sp-avatar[data-name]').forEach((a) => {
    const name = a.dataset.name;
    a.textContent = popInitials(name);
    if (!a.style.getPropertyValue('--sp-avatar-fill')) a.style.setProperty('--sp-avatar-fill', `var(--sp-color-${popAvatarColor(name)})`);
    a.setAttribute('role', 'img');
    a.setAttribute('aria-label', name);
  });
}

// ---------------------------------------------------------------------------
// Tooltip

let tipSeq = 0;
/**
 * Wires every `[data-tip]` in `root`: a tap or click shows the bubble for
 * 3 s (hover and keyboard focus show it through CSS), and the text is linked
 * with aria-describedby so screen readers hear it.
 */
export function wirePopTooltips(root = document) {
  root.querySelectorAll('[data-tip]').forEach((el) => {
    if (el.dataset.popWired) return;
    el.dataset.popWired = '1';
    const note = document.createElement('span');
    note.className = 'sp-visually-hidden';
    note.id = `sp-tip-${++tipSeq}`;
    note.textContent = el.dataset.tip;
    el.after(note);
    el.setAttribute('aria-describedby', note.id);
    let timer;
    el.addEventListener('click', () => {
      el.classList.add('is-open');
      clearTimeout(timer);
      timer = setTimeout(() => el.classList.remove('is-open'), tokens.motion.snackbar);
    });
  });
}
