// Sticker Pop content formats for the web: Indian rupees with Indian digit
// grouping, compact amounts, and short dates and times. Amounts are integer
// paise. Output matches every other platform (parity/format-cases.json).

const MINUS = '−'; // −, a real minus sign

/** @typedef {'auto' | 'always' | 'none'} PopSign */

/** Groups digits the Indian way: 1,25,000 and 12,34,56,789. */
export function groupIndian(value) {
  const digits = String(Math.abs(Math.trunc(value)));
  if (digits.length <= 3) return digits;
  const last3 = digits.slice(-3);
  let rest = digits.slice(0, -3);
  const parts = [];
  while (rest.length > 2) {
    parts.unshift(rest.slice(-2));
    rest = rest.slice(0, -2);
  }
  if (rest) parts.unshift(rest);
  return `${parts.join(',')},${last3}`;
}

function signFor(paise, sign) {
  if (sign === 'none') return '';
  if (sign === 'always') return paise < 0 ? MINUS : paise > 0 ? '+' : '';
  return paise < 0 ? MINUS : '';
}

/** ₹1,25,000 or ₹1,250.50. Paise show only when non-zero, unless alwaysPaise. */
/**
 * Applies one keypad key ("0"–"9", "." or "⌫") to an amount being typed:
 * one decimal point, at most `decimals` decimal places, no leading zeros,
 * at most `maxDigits` digits before the point.
 */
export function applyPopKey(current, key, { decimals = 2, maxDigits = 9 } = {}) {
  if (key === '⌫') return current.slice(0, -1);
  if (key === '.') return decimals === 0 || current.includes('.') ? current : current === '' ? '0.' : `${current}.`;
  if (!/^\d$/.test(key)) return current;
  const dot = current.indexOf('.');
  if (dot >= 0 && current.length - dot - 1 >= decimals) return current;
  if (dot < 0 && current.replace(/^0/, '').length >= maxDigits) return current;
  if (current === '0') return key;
  return current + key;
}

export function formatInr(paise, { sign = 'auto', alwaysPaise = false } = {}) {
  const abs = Math.abs(paise);
  const rupees = Math.floor(abs / 100);
  const rem = abs % 100;
  const body = rem !== 0 || alwaysPaise ? `${groupIndian(rupees)}.${String(rem).padStart(2, '0')}` : groupIndian(rupees);
  return `${signFor(paise, sign)}₹${body}`;
}

function trim(v) {
  const decimals = v >= 100 ? 0 : v >= 10 ? 1 : 2;
  let s = v.toFixed(decimals);
  if (s.includes('.')) s = s.replace(/0+$/, '').replace(/\.$/, '');
  return s;
}

/** ₹950, ₹51.2k, ₹1.25L, ₹2.1Cr: at most three significant figures. */
export function formatInrCompact(paise, { sign = 'auto' } = {}) {
  const rupees = Math.abs(paise) / 100;
  let body;
  if (rupees >= 1e7) body = `${trim(rupees / 1e7)}Cr`;
  else if (rupees >= 1e5) body = `${trim(rupees / 1e5)}L`;
  else if (rupees >= 1e3) body = `${trim(rupees / 1e3)}k`;
  else body = groupIndian(Math.round(rupees));
  return `${signFor(paise, sign)}₹${body}`;
}

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const dayNumber = (d) => Math.round(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()) / 86400000);

/** "Today", "Yesterday", or "18 Nov 2026". Dates are local Date objects. */
export function formatPopDate(date, now = new Date()) {
  const days = dayNumber(now) - dayNumber(date);
  if (days === 0) return 'Today';
  if (days === 1) return 'Yesterday';
  return `${date.getDate()} ${MONTHS[date.getMonth()]} ${date.getFullYear()}`;
}

/** "Nov 2026". */
export const formatPopMonth = (date) => `${MONTHS[date.getMonth()]} ${date.getFullYear()}`;

/** 12-hour time: "1:12 pm", "9:05 am", "12:00 pm". */
export function formatPopTime(date) {
  const h = date.getHours() % 12 === 0 ? 12 : date.getHours() % 12;
  return `${h}:${String(date.getMinutes()).padStart(2, '0')} ${date.getHours() < 12 ? 'am' : 'pm'}`;
}
