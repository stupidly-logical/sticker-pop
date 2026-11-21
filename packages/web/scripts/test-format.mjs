// Runs the shared cases in parity/format-cases.json against src/format.mjs.
import { readFileSync } from 'node:fs';
import { formatInr, formatInrCompact, formatPopDate, formatPopMonth, formatPopTime } from '../src/format.mjs';

const cases = JSON.parse(readFileSync(new URL('../../../parity/format-cases.json', import.meta.url), 'utf8'));
// "2026-11-18T13:12" without a zone parses as local time, like the other platforms.
const local = (s) => new Date(s);
const fails = [];
const check = (name, c, got) => { if (got !== c.out) fails.push(`${name} ${JSON.stringify(c)} → ${got}`); };

for (const c of cases.formatInr) check('formatInr', c, formatInr(c.paise, { sign: c.sign, alwaysPaise: c.alwaysPaise }));
for (const c of cases.formatInrCompact) check('formatInrCompact', c, formatInrCompact(c.paise, { sign: c.sign }));
for (const c of cases.formatPopDate) check('formatPopDate', c, formatPopDate(local(c.date), local(c.now)));
for (const c of cases.formatPopMonth) check('formatPopMonth', c, formatPopMonth(local(c.date)));
for (const c of cases.formatPopTime) check('formatPopTime', c, formatPopTime(local(c.time)));

if (fails.length) {
  console.error('web format tests failed:\n  ' + fails.join('\n  '));
  process.exit(1);
}
const total = Object.entries(cases).filter(([k]) => !k.startsWith('$')).reduce((n, [, v]) => n + v.length, 0);
console.log(`web format tests passed (${total} shared cases).`);
