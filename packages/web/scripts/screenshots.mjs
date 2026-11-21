// Screenshots the web gallery with Playwright (CI; needs
// `npm i playwright && npx playwright install chromium`). Serves the built
// site over HTTP, because browsers don't run ES modules from file:// pages.
//   node packages/web/scripts/screenshots.mjs <built site dir> <output dir>
import { existsSync, mkdirSync, readFileSync, statSync } from 'node:fs';
import { createServer } from 'node:http';
import { extname, join, normalize, resolve } from 'node:path';
import { chromium } from 'playwright';

const [siteDir = 'dist/site', outDir = 'screenshots'] = process.argv.slice(2);
const root = resolve(siteDir);
const types = { '.html': 'text/html', '.mjs': 'text/javascript', '.js': 'text/javascript', '.css': 'text/css', '.ttf': 'font/ttf', '.svg': 'image/svg+xml' };
const server = createServer((req, res) => {
  let file = join(root, normalize(decodeURIComponent(new URL(req.url, 'http://x').pathname)));
  if (existsSync(file) && statSync(file).isDirectory()) file = join(file, 'index.html');
  if (!file.startsWith(root) || !existsSync(file)) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { 'content-type': types[extname(file)] ?? 'application/octet-stream' });
  res.end(readFileSync(file));
}).listen(0);
const port = server.address().port;

mkdirSync(outDir, { recursive: true });
const browser = await chromium.launch();
const tab = await browser.newPage({ viewport: { width: 1200, height: 900 } });
await tab.goto(`http://localhost:${port}/web-gallery/`);
await tab.waitForSelector('[data-donut] svg');
await tab.screenshot({ path: `${outDir}/gallery.png`, fullPage: true });
await tab.locator('.phone').screenshot({ path: `${outDir}/home.png` });
await browser.close();
server.close();
console.log(`screenshots written to ${outDir}`);
