// Renders every docs page and component page in Node (no browser) and
// checks the content: each component has states, code and a spec, ids are
// unique, and internal links point at real pages.
import { readFileSync } from 'node:fs';
import tokens from '../packages/web/src/tokens.mjs';
import { components, groups } from '../apps/site/content/components.js';
import { foundationPages } from '../apps/site/content/foundations.js';
import { guidePages } from '../apps/site/content/guides.js';
import { otherPages } from '../apps/site/content/pages.js';
import { esc, kebab, contrast } from '../apps/site/content/util.js';

const errors = [];
const codeBlock = (code) => Object.keys(code).join(',');
const ctx = { esc, kebab, tokens, codeBlock, contrast, components };

const ids = new Set();
const html = [];
for (const p of [...otherPages, ...foundationPages, ...guidePages]) {
  if (ids.has(p.id)) errors.push(`duplicate page id "${p.id}"`);
  ids.add(p.id);
  try { html.push(p.render(ctx)); } catch (e) { errors.push(`page "${p.id}" threw: ${e.message}`); }
}
for (const c of components) {
  const id = `c-${c.id}`;
  if (ids.has(id)) errors.push(`duplicate component id "${c.id}"`);
  ids.add(id);
  if (!c.states?.length) errors.push(`${c.id}: no states`);
  for (const platform of ['compose', 'flutter', 'swift', 'html']) {
    if (!c.code?.[platform]) errors.push(`${c.id}: no ${platform} code sample`);
  }
  if (!c.spec?.length) errors.push(`${c.id}: no spec`);
  if (!groups.includes(c.group)) errors.push(`${c.id}: unknown group`);
  html.push(...c.states.map((s) => s.html), c.summary);
}

const all = html.join('\n');
for (const m of all.matchAll(/href="#([^"]*)"/g)) {
  if (!ids.has(m[1])) errors.push(`broken link #${m[1]}`);
}
const defined = new Set([...readFileSync(new URL('../packages/web/src/tokens.css', import.meta.url), 'utf8').matchAll(/(--sp-[a-z0-9-]+):/g)].map((m) => m[1]));
for (const m of all.matchAll(/var\((--sp-[a-z0-9-]+)/g)) {
  // Component hooks (--sp-chip-fill etc.) are set by callers, not tokens.
  if (!defined.has(m[1]) && !/^--sp-(chip|segment|dot|swatch|progress|bar)-fill$/.test(m[1])) errors.push(`unknown css var ${m[1]}`);
}

if (errors.length) {
  console.error('site check failed:\n  ' + errors.join('\n  '));
  process.exit(1);
}
console.log(`site check passed (${ids.size} pages, ${components.length} components).`);
