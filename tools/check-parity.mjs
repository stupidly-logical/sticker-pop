// Checks that every component in parity/components.json exists on every
// platform, and that every docs page has a parity entry. Prints the matrix.
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join, extname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(fileURLToPath(new URL('.', import.meta.url)), '..');
const manifest = JSON.parse(readFileSync(join(root, 'parity/components.json'), 'utf8'));

function files(dir, exts) {
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) out.push(...files(p, exts));
    else if (exts.includes(extname(p))) out.push(p);
  }
  return out;
}
const source = {
  flutter: files(join(root, manifest.platforms.flutter), ['.dart']).map((f) => readFileSync(f, 'utf8')).join('\n'),
  compose: files(join(root, manifest.platforms.compose), ['.kt']).map((f) => readFileSync(f, 'utf8')).join('\n'),
  swiftui: files(join(root, manifest.platforms.swiftui), ['.swift']).map((f) => readFileSync(f, 'utf8')).join('\n'),
  web: files(join(root, manifest.platforms.web), ['.css', '.mjs']).map((f) => readFileSync(f, 'utf8')).join('\n'),
};
const esc = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const declared = {
  flutter: (n) => new RegExp(`(class|enum|mixin)\\s+${esc(n)}\\b|^[\\w<>?, ]*\\b${esc(n)}(<[^>]*>)?\\s*\\(`, 'm').test(source.flutter),
  compose: (n) => new RegExp(`(class|object|fun)\\s+(<[^>]*>\\s+)?(\\w+\\.)?${esc(n)}\\b`).test(source.compose),
  swiftui: (n) => new RegExp(`(struct|class|enum|func|let|var)\\s+${esc(n)}\\b`).test(source.swiftui),
  web: (n) => n.startsWith('.')
    ? new RegExp(`${esc(n)}(?![\\w-])`).test(source.web)
    : new RegExp(`export\\s+(async\\s+)?(function|const)\\s+${esc(n.replace(/\(\)$/, ''))}\\b`).test(source.web),
};

const platforms = Object.keys(manifest.platforms);
const errors = [];
const rows = [];
for (const entry of [...manifest.components, ...manifest.foundations]) {
  const cells = platforms.map((p) => {
    const missing = (entry[p] ?? []).filter((n) => !declared[p](n));
    missing.forEach((n) => errors.push(`${entry.id}: ${p} is missing ${n}`));
    if (!(entry[p] ?? []).length && entry.id !== 'samples') errors.push(`${entry.id}: no ${p} symbols listed`);
    return missing.length ? '✗' : '✓';
  });
  rows.push(`${entry.id.padEnd(16)} ${cells.map((c) => c.padEnd(9)).join('')}`);
}

// Every component page on the docs site needs a parity entry, and vice versa.
const { components: pages } = await import(new URL('../apps/site/content/components.js', import.meta.url));
const ids = new Set(manifest.components.map((c) => c.id));
for (const p of pages) if (!ids.has(p.id)) errors.push(`docs page ${p.id} has no parity entry`);
for (const id of ids) if (!pages.find((p) => p.id === id)) errors.push(`parity entry ${id} has no docs page`);

if (process.argv.includes('--table') || errors.length) {
  console.log(`${''.padEnd(16)} ${platforms.map((p) => p.padEnd(9)).join('')}`);
  console.log(rows.join('\n'));
}
if (errors.length) {
  console.error('\nparity check failed:\n  ' + errors.join('\n  '));
  process.exit(1);
}
console.log(`parity check passed (${manifest.components.length} components × ${platforms.length} platforms).`);
