#!/usr/bin/env node
// Builds the docs site into dist/site:
//   apps/site/*                 → dist/site/
//   packages/web/src/*          → dist/site/sp/
//   packages/web/fonts/*        → dist/site/fonts/
//   Flutter gallery (web build) → dist/site/app/
//
//   node tools/build-site.mjs                 build everything (runs flutter build web)
//   node tools/build-site.mjs --no-app        skip the Flutter app
//   node tools/build-site.mjs --app-from DIR  use an existing Flutter web build
//   node tools/build-site.mjs --serve [port]  build, then serve on http://localhost:4173
//   node tools/build-site.mjs --out DIR       write somewhere other than dist/site
//
// The output is static files: host dist/site anywhere (GitHub Pages,
// Netlify, Cloudflare Pages, an S3 bucket). Every path is relative, so it
// also works from a sub-folder.

import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync, statSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { createServer } from 'node:http';
import { spawnSync } from 'node:child_process';
import { dirname, extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const flag = (name) => args.includes(name);
const value = (name) => { const i = args.indexOf(name); return i >= 0 ? args[i + 1] : undefined; };
const out = value('--out') ?? join(root, 'dist/site');

// Tokens first, so the site never shows stale values.
const tokens = spawnSync(process.execPath, [join(root, 'tools/build-tokens.mjs')], { stdio: 'inherit' });
if (tokens.status !== 0) process.exit(tokens.status ?? 1);

try {
  rmSync(out, { recursive: true, force: true });
} catch {
  // Some sandboxes forbid deleting; overwrite in place instead.
}
mkdirSync(out, { recursive: true });
cpSync(join(root, 'apps/site'), out, { recursive: true });
cpSync(join(root, 'packages/web/src'), join(out, 'sp'), { recursive: true });
cpSync(join(root, 'packages/web/fonts'), join(out, 'fonts'), { recursive: true });
// The web package's own gallery, pointed at the copied package files.
mkdirSync(join(out, 'web-gallery'), { recursive: true });
writeFileSync(
  join(out, 'web-gallery/index.html'),
  readFileSync(join(root, 'packages/web/index.html'), 'utf8').replaceAll('"src/', '"../sp/').replaceAll("'./src/", "'../sp/"),
);
console.log('site: copied pages, web package, web gallery and fonts');

// Cache busting: every relative .js/.mjs/.css reference gets ?v=<build hash>,
// so browsers fetch fresh scripts after each deploy instead of mixing a new
// page with old cached modules. Same hash everywhere, so each module still
// loads once.
{
  const files = [];
  const walk = (dir) => {
    for (const name of readdirSync(dir)) {
      const f = join(dir, name);
      if (statSync(f).isDirectory()) walk(f);
      else if (/\.(m?js|css|html)$/.test(name)) files.push(f);
    }
  };
  walk(out);
  files.sort();
  const hash = createHash('sha256');
  for (const f of files) hash.update(readFileSync(f));
  const v = hash.digest('hex').slice(0, 10);
  const ref = '((?:\\.{1,2}/)[^\'"?#()\\s]+\\.(?:m?js|css))';
  const patterns = [
    new RegExp(`((?:\\bfrom|\\bimport)\\s*\\(?\\s*['"])${ref}(['"])`, 'g'),
    // src/href: local paths only (no scheme, no leading slash).
    new RegExp(`(\\b(?:src|href)=["'])((?:\\.{1,2}/)?[a-zA-Z0-9_][^'"?#()\\s:]*\\.(?:m?js|css))(["'])`, 'g'),
    new RegExp(`(url\\(\\s*['"]?)${ref}(['"]?\\s*\\))`, 'g'),
  ];
  for (const f of files) {
    let text = readFileSync(f, 'utf8');
    for (const re of patterns) text = text.replace(re, (_, a, path, b) => `${a}${path}?v=${v}${b}`);
    writeFileSync(f, text);
  }
  console.log(`site: versioned asset links (v=${v})`);
}

if (!flag('--no-app')) {
  let appBuild = value('--app-from');
  if (!appBuild) {
    const example = join(root, 'packages/flutter/sticker_pop/example');
    console.log('site: flutter build web (this takes a minute)…');
    const r = spawnSync('flutter', ['build', 'web', '--release', '--no-tree-shake-icons', '--no-wasm-dry-run'], { cwd: example, stdio: 'inherit' });
    if (r.status !== 0) {
      console.error('site: flutter build web failed; rerun with --no-app to skip the app');
      process.exit(r.status ?? 1);
    }
    appBuild = join(example, 'build/web');
  }
  cpSync(appBuild, join(out, 'app'), { recursive: true });
  // Make the app work from any sub-path: <base href="/"> → <base href="./">.
  const index = join(out, 'app/index.html');
  writeFileSync(index, readFileSync(index, 'utf8').replace(/<base href="[^"]*">/, '<base href="./">'));
  console.log('site: added the Flutter gallery app at app/');
}

console.log(`site: built ${out}`);

if (flag('--serve')) {
  const port = Number(value('--serve')) || 4173;
  const types = {
    '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.mjs': 'text/javascript', '.css': 'text/css',
    '.json': 'application/json', '.svg': 'image/svg+xml', '.png': 'image/png', '.ttf': 'font/ttf', '.otf': 'font/otf',
    '.wasm': 'application/wasm', '.ico': 'image/x-icon', '.map': 'application/json', '.txt': 'text/plain',
  };
  createServer((req, res) => {
    let path = normalize(decodeURIComponent(new URL(req.url, 'http://x').pathname)).replace(/^(\.\.[/\\])+/, '');
    let file = join(out, path);
    if (existsSync(file) && statSync(file).isDirectory()) file = join(file, 'index.html');
    if (!file.startsWith(out) || !existsSync(file)) { res.writeHead(404); res.end('Not found'); return; }
    res.writeHead(200, { 'content-type': types[extname(file)] ?? 'application/octet-stream' });
    res.end(readFileSync(file));
  }).listen(port, () => console.log(`site: serving on http://localhost:${port}`));
}
