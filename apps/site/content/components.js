// The component registry: one entry per component page.
import { surfaces } from './c-surfaces.js';
import { controls } from './c-controls.js';
import { display } from './c-display.js';
import { overlays } from './c-overlays.js';

export const components = [...surfaces, ...controls, ...display, ...overlays];
export const groups = [...new Set(components.map((c) => c.group))];
