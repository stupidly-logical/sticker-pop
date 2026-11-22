#!/usr/bin/env node
// One version for the whole project, kept in the VERSION file at the root.
//
//   node tools/version.mjs                 show the version and whether every place agrees
//   node tools/version.mjs patch           0.1.0 → 0.1.1, then sync everywhere
//   node tools/version.mjs minor           0.1.0 → 0.2.0
//   node tools/version.mjs major           0.1.0 → 1.0.0
//   node tools/version.mjs 0.3.0           set an exact version
//   node tools/version.mjs sync            after editing VERSION by hand: copy it everywhere
//   node tools/version.mjs check [--tag v0.2.0]   fail if any place disagrees (CI, releases)
//
// A bump also bumps the sample apps' build numbers and gives CHANGELOG.md a
// heading for the new version: an "## Unreleased" section becomes it, or a
// stub is added. `check --tag` refuses to release while that section still
// says TODO.
import { copyFileSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(fileURLToPath(new URL('.', import.meta.url)), '..');
const read = (p) => readFileSync(join(root, p), 'utf8');
const write = (p, s) => writeFileSync(join(root, p), s);
const SEMVER = /^\d+\.\d+\.\d+$/;
const V = '(\\d+\\.\\d+\\.\\d+)';

/**
 * Every place the version is written. `re` has the prefix in group 1 and the
 * version in group 2; `all` replaces every match (docs snippets).
 */
const PLACES = [
  { file: 'packages/flutter/sticker_pop/pubspec.yaml', re: new RegExp(`^(version: )${V}`, 'm') },
  { file: 'packages/flutter/sticker_pop/example/pubspec.yaml', re: new RegExp(`^(version: )${V}(?=\\+)`, 'm') },
  { file: 'packages/web/package.json', re: new RegExp(`^(  "version": ")${V}`, 'm') },
  { file: 'packages/android/stickerpop/build.gradle.kts', re: new RegExp(`^(version = ")${V}`, 'm') },
  { file: 'packages/android/stickerpop/build.gradle.kts', re: new RegExp(`("dev\\.stickerpop:stickerpop:)${V}`, 'g'), all: true },
  { file: 'packages/android/sample/build.gradle.kts', re: new RegExp(`(versionName = ")${V}`) },
  { file: 'apps/site/site.js', re: new RegExp(`(const VERSION = ')${V}`) },
  { file: 'apps/site/index.html', re: new RegExp(`(topbar__version">v)${V}`) },
  // Only the sticker-pop line: Package.swift also pins its own dependencies.
  { file: 'Package.swift', re: new RegExp(`(sticker-pop\\.git", from: ")${V}`, 'g'), all: true },
  // Install snippets in the README and on the docs Install page.
  ...['README.md', 'apps/site/content/pages.js'].map((file) => ({
    file,
    re: new RegExp(`(sticker-pop@v|@sticker-pop/web@|sticker_pop: \\^|ref: v|checkout v|\\(\`v|sticker-pop\\.git", from: "|stickerpop:stickerpop:|Next Major: |from \`)${V}`, 'g'),
    all: true,
  })),
];

/** Build numbers that go up by one on every bump (not on sync). */
const BUILD_NUMBERS = [
  { file: 'packages/flutter/sticker_pop/example/pubspec.yaml', re: /^(version: \d+\.\d+\.\d+\+)(\d+)/m },
  { file: 'packages/android/sample/build.gradle.kts', re: /(versionCode = )(\d+)/ },
];

const current = () => read('VERSION').trim();

function scan() {
  const found = [];
  for (const p of PLACES) {
    const text = read(p.file);
    const matches = [...text.matchAll(new RegExp(p.re.source, p.re.flags.includes('g') ? p.re.flags : p.re.flags + 'g'))];
    if (!matches.length) found.push({ file: p.file, version: '(not found)' });
    for (const m of matches) found.push({ file: p.file, version: m[2] });
  }
  const changelog = read('CHANGELOG.md').match(/^## (\d+\.\d+\.\d+)/m)?.[1] ?? '(no version heading)';
  found.push({ file: 'CHANGELOG.md', version: changelog });
  return found;
}

/** Registries want these inside each package; the root copies are the source. */
const PACKAGE_COPIES = ['LICENSE', 'CHANGELOG.md'].flatMap((f) =>
  ['packages/web', 'packages/flutter/sticker_pop'].map((dir) => ({ from: f, to: `${dir}/${f}` })));

function copyPackageFiles() {
  const changed = [];
  for (const { from, to } of PACKAGE_COPIES) {
    let old = null;
    try { old = read(to); } catch {}
    if (old !== read(from)) { copyFileSync(join(root, from), join(root, to)); changed.push(to); }
  }
  return changed;
}

function sync(version) {
  const changed = new Set(copyPackageFiles());
  for (const p of PLACES) {
    const before = read(p.file);
    const after = before.replace(p.re, (_, prefix) => `${prefix}${version}`);
    if (after !== before) { write(p.file, after); changed.add(p.file); }
  }
  return [...changed];
}

function bumpBuildNumbers() {
  for (const b of BUILD_NUMBERS) {
    write(b.file, read(b.file).replace(b.re, (_, prefix, n) => `${prefix}${Number(n) + 1}`));
  }
}

function changelogFor(version) {
  let text = read('CHANGELOG.md');
  if (new RegExp(`^## ${version.replaceAll('.', '\\.')}\\b`, 'm').test(text)) return false;
  const date = new Date().toISOString().slice(0, 10);
  if (/^## Unreleased\s*$/m.test(text)) {
    text = text.replace(/^## Unreleased\s*$/m, `## ${version} (${date})`);
  } else {
    text = text.replace(/^## /m, `## ${version} (${date})\n\n- TODO: describe this release.\n\n## `);
  }
  write('CHANGELOG.md', text);
  return true;
}

function next(version, kind) {
  const [a, b, c] = version.split('.').map(Number);
  if (kind === 'major') return `${a + 1}.0.0`;
  if (kind === 'minor') return `${a}.${b + 1}.0`;
  if (kind === 'patch') return `${a}.${b}.${c + 1}`;
  return kind;
}

function check({ tag } = {}) {
  const version = current();
  const problems = [];
  if (!SEMVER.test(version)) problems.push(`VERSION: "${version}" is not X.Y.Z`);
  for (const { file, version: v } of scan()) if (v !== version) problems.push(`${file}: ${v}`);
  for (const { from, to } of PACKAGE_COPIES) {
    let copy = null;
    try { copy = read(to); } catch {}
    if (copy !== read(from)) problems.push(`${to}: out of date with ${from}`);
  }
  if (tag !== undefined && tag.replace(/^v/, '') !== version) problems.push(`git tag: ${tag}`);
  if (tag !== undefined) {
    const section = read('CHANGELOG.md').split(/^## /m).find((s) => s.startsWith(version)) ?? '';
    if (/TODO/.test(section)) problems.push(`CHANGELOG.md: the ${version} section still says TODO`);
  }
  if (problems.length) {
    console.error(`version check failed (VERSION says ${version}):\n  ${problems.join('\n  ')}`);
    if (problems.some((p) => !p.includes('TODO') && !p.startsWith('git tag'))) console.error('Fix: node tools/version.mjs sync');
    if (problems.some((p) => p.includes('TODO'))) console.error('Fix: describe the release in CHANGELOG.md');
    if (problems.some((p) => p.startsWith('git tag'))) console.error('Fix: tag the version in VERSION, or bump it first');
    process.exit(1);
  }
  console.log(`version check passed (${version} in ${scan().length} places).`);
}

export { check };

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [cmd, ...rest] = process.argv.slice(2);
  if (!cmd) {
    console.log(`Sticker Pop ${current()}`);
    check();
  } else if (cmd === 'check') {
    const i = rest.indexOf('--tag');
    check({ tag: i >= 0 ? rest[i + 1] : undefined });
  } else if (cmd === 'sync') {
    const version = current();
    if (!SEMVER.test(version)) { console.error(`VERSION: "${version}" is not X.Y.Z`); process.exit(1); }
    const changed = sync(version);
    if (changelogFor(version)) changed.push('CHANGELOG.md', ...copyPackageFiles());
    console.log(changed.length ? `synced ${version}:\n  ${changed.join('\n  ')}` : `everything already says ${version}`);
    check();
  } else {
    const from = current();
    const to = next(from, cmd);
    if (!SEMVER.test(to)) { console.error(`Use patch, minor, major, sync, check or a version like 0.2.0 (got "${cmd}")`); process.exit(1); }
    if (to === from) { console.error(`Already ${from}`); process.exit(1); }
    write('VERSION', `${to}\n`);
    const changed = sync(to);
    bumpBuildNumbers();
    changelogFor(to);
    copyPackageFiles();
    console.log(`${from} → ${to}\n  VERSION\n  ${[...new Set([...changed, ...BUILD_NUMBERS.map((b) => b.file), 'CHANGELOG.md'])].join('\n  ')}`);
    console.log('Next: describe the release in CHANGELOG.md, run bash tools/check.sh, commit, then bash tools/publish.sh');
    check();
  }
}
