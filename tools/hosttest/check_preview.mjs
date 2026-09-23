/*
 * Renders viewports of a container through web/js/preview.js, for
 * check_preview.py to compare with the calculator's own renderer.
 *
 *   node tools/hosttest/check_preview.mjs <chunk-dir> <count> <out> layer,vx,vy[,limit] ...
 *
 * Chunks are read from <chunk-dir>/<index>.bin; the frames, 320x240 palette
 * indices each, are written to <out> back to back. The part table preview.js
 * parsed goes to stdout as JSON, so the comparison covers that too.
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { Decoder, parseContainer, renderViewport } from '../../web/js/preview.js';

const [, , dir, count, out, ...viewports] = process.argv;
const chunks = [];
for (let i = 0; i < Number(count); i++) chunks.push(new Uint8Array(readFileSync(`${dir}/${i}.bin`)));

const container = parseContainer(chunks);
const decoder = new Decoder(container);
const frames = viewports.map((spec) => {
  const [layer, vx, vy, limit] = spec.split(',').map(Number);
  return renderViewport(decoder, layer, vx, vy, Number.isFinite(limit) ? limit : Infinity);
});

const joined = new Uint8Array(frames.reduce((sum, f) => sum + f.length, 0));
let at = 0;
for (const frame of frames) {
  joined.set(frame, at);
  at += frame.length;
}
writeFileSync(out, joined);
console.log(JSON.stringify(container.parts.length > 1 ? container.parts : []));
