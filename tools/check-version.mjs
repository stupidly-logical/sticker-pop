// Checks that every place a version is written agrees with CHANGELOG.md.
//   node tools/check-version.mjs              compare files
//   node tools/check-version.mjs --tag v0.2.0 also require the tag to match
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(fileURLToPath(new URL('.', import.meta.url)), '..');
const read = (p) => readFileSync(join(root, p), 'utf8');
const grab = (p, re) => read(p).match(re)?.[1] ?? '(not found)';

const changelog = grab('CHANGELOG.md', /^## (\d+\.\d+\.\d+)/m);
const found = {
  'CHANGELOG.md': changelog,
  'packages/flutter/sticker_pop/pubspec.yaml': grab('packages/flutter/sticker_pop/pubspec.yaml', /^version: (\S+)/m),
  'packages/web/package.json': JSON.parse(read('packages/web/package.json')).version,
  'packages/android/stickerpop/build.gradle.kts': grab('packages/android/stickerpop/build.gradle.kts', /^version = "([^"]+)"/m),
  'packages/android/sample/build.gradle.kts': grab('packages/android/sample/build.gradle.kts', /versionName = "([^"]+)"/),
  'apps/site/site.js': grab('apps/site/site.js', /const VERSION = '([^']+)'/),
  'apps/site/index.html': grab('apps/site/index.html', /sp-badge[^>]*>v([\d.]+)</),
};

const tagIndex = process.argv.indexOf('--tag');
if (tagIndex > 0) found['git tag'] = process.argv[tagIndex + 1].replace(/^v/, '');

const wrong = Object.entries(found).filter(([, v]) => v !== changelog);
if (wrong.length) {
  console.error(`version check failed (CHANGELOG.md says ${changelog}):`);
  for (const [file, v] of wrong) console.error(`  ${file}: ${v}`);
  process.exit(1);
}
console.log(`version check passed (${changelog} in ${Object.keys(found).length} places).`);
