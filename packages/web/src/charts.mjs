// Sticker Pop charts for the web, as SVG and HTML strings: a donut with one
// bright per slice outlined in 2.5 ink around a yellow centre disc, bars
// (see .sp-bars) and a legend (see .sp-legend). No gridlines, no gradients.
import tokens from './tokens.mjs';

const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const { ink, yellow, white } = tokens.color;

/**
 * Donut chart SVG. data: [{ label, value, color }]; color is a CSS colour,
 * e.g. tokens.color.orange or 'var(--sp-color-orange)'.
 */
export function popDonutSvg(data, { size = 180, thickness = 38, center = '', label = 'Chart' } = {}) {
  const total = data.reduce((s, d) => s + d.value, 0);
  const c = size / 2;
  const outer = c - tokens.border.regular / 2;
  const inner = outer - thickness;
  const pt = (r, a) => [c + r * Math.cos(a), c + r * Math.sin(a)].map((n) => n.toFixed(2)).join(' ');
  let start = -Math.PI / 2;
  const slices = total <= 0
    ? `<circle cx="${c}" cy="${c}" r="${outer}" fill="${white}" stroke="${ink}" stroke-width="2.5"/>`
    : data.map((d) => {
      const sweep = (d.value / total) * Math.PI * 2;
      const end = start + Math.min(sweep, Math.PI * 2 - 0.0001);
      const large = sweep > Math.PI ? 1 : 0;
      const path = `M ${pt(outer, start)} A ${outer} ${outer} 0 ${large} 1 ${pt(outer, end)} L ${pt(inner, end)} A ${inner} ${inner} 0 ${large} 0 ${pt(inner, start)} Z`;
      start += sweep;
      return `<path d="${path}" fill="${d.color}" stroke="${ink}" stroke-width="2.5" stroke-linejoin="round"/>`;
    }).join('');
  const disc = inner - 8;
  return `<svg class="sp-donut" viewBox="0 0 ${size} ${size}" width="${size}" height="${size}" role="img" aria-label="${esc(label)}">${slices}`
    + `<circle cx="${c}" cy="${c}" r="${disc}" fill="${yellow}" stroke="${ink}" stroke-width="2.5"/>`
    + (center ? `<text x="${c}" y="${c + 5}" text-anchor="middle" font-family="Bricolage Grotesque, sans-serif" font-weight="800" font-size="15" fill="${ink}">${esc(center)}</text>` : '')
    + '</svg>';
}

/** Bars HTML for .sp-bars; the bar at highlightIndex gets a heavier outline and shadow. */
export function popBarsHtml(data, { height = 140, highlightIndex, label = 'Chart' } = {}) {
  const max = Math.max(0, ...data.map((d) => d.value));
  return `<div class="sp-bars" role="img" aria-label="${esc(label)}">${data.map((d, i) => {
    const h = max === 0 ? 4 : Math.max(4, (d.value / max) * height);
    return `<div class="${i === highlightIndex ? 'is-current' : ''}"><i style="--h:${h.toFixed(0)}px;--sp-bar-fill:${d.color}"></i>${esc(d.label)}</div>`;
  }).join('')}</div>`;
}

/** Legend HTML for .sp-legend with rounded percentages. */
export function popLegendHtml(data) {
  const total = data.reduce((s, d) => s + d.value, 0);
  return `<div class="sp-legend">${data.map((d) => `<div><i class="sp-swatch" style="--sp-swatch-fill:${d.color}"></i>${esc(d.label)}<b>${total ? Math.round((d.value / total) * 100) : 0}%</b></div>`).join('')}</div>`;
}
