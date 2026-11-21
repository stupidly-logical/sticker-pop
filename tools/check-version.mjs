// Kept for CI and scripts that call it: same as `node tools/version.mjs check`.
//   node tools/check-version.mjs [--tag v0.2.0]
import { check } from './version.mjs';

const i = process.argv.indexOf('--tag');
check({ tag: i >= 0 ? process.argv[i + 1] : undefined });
