// Lints the web package against the Sticker Pop rules:
// every var(--sp-*) exists, hard shadows only, no gradients except the
// paper dot grid, no weights under 600.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const dir = join(dirname(fileURLToPath(import.meta.url)), '..');
const tokens = readFileSync(join(dir, 'src/tokens.css'), 'utf8');
const components = readFileSync(join(dir, 'src/components.css'), 'utf8');
const errors = [];

const defined = new Set([...tokens.matchAll(/(--sp-[a-z0-9-]+):/g)].map((m) => m[1]));
// Component-level hooks callers may set: --sp-chip-fill etc. default via var(x, fallback).
for (const m of components.matchAll(/var\((--sp-[a-z0-9-]+)(,?)/g)) {
  if (!defined.has(m[1]) && m[2] !== ',' && !components.includes(`${m[1]}:`)) {
    errors.push(`unknown token ${m[1]}`);
  }
}

for (const m of components.matchAll(/box-shadow:\s*([^;]+);/g)) {
  const value = m[1].trim();
  if (value === 'none' || value.startsWith('0 0 0 100vmax')) continue; // spotlight scrim
  // x y blur colour: blur must be 0.
  const parts = value.replace(/var\([^)]*\)/g, 'V').split(/\s+/);
  if (parts[2] !== '0') errors.push(`soft shadow: ${value}`);
}

const gradients = [...components.matchAll(/(linear|radial|conic)-gradient/g)].length;
// Gradients come from tokens (var(--sp-gradient-*)); the only literal one in
// components.css is the paper dot grid.
if (gradients > 1) errors.push('use a gradient token (var(--sp-gradient-*)) instead of a literal gradient');

for (const m of components.matchAll(/font-weight:\s*(\d+)/g)) {
  if (Number(m[1]) < 600) errors.push(`font-weight ${m[1]} is under 600`);
}
if (/border[^:]*:\s*1px/.test(components)) errors.push('1px borders are not allowed');

// Fill utilities must come after the components, or a component's default
// background beats them (same specificity). They live in fills.css only.
if (/\.sp-fill-[a-z]/.test(components.replace(/\/\*[\s\S]*?\*\//g, ''))) errors.push('define .sp-fill-* in fills.css (generated), not components.css');
if (/\.sp-fill-[a-z]/.test(tokens)) errors.push('.sp-fill-* belongs in fills.css, which loads after components.css');
const entry = readFileSync(join(dir, 'src/sticker-pop.css'), 'utf8');
const order = ['tokens.css', 'components.css', 'fills.css'].map((f) => entry.indexOf(f));
if (order.some((i) => i < 0) || !(order[0] < order[1] && order[1] < order[2])) errors.push('sticker-pop.css must import tokens.css, components.css, then fills.css');

if (errors.length) {
  console.error('web check failed:\n  ' + errors.join('\n  '));
  process.exit(1);
}
console.log(`web check passed (${defined.size} tokens).`);
