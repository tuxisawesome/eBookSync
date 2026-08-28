/*
 * End-to-end check of the browser encoder against the calculator's decoder.
 *
 * Builds a container with web/js/convert.js from the same indexed pixels the
 * Python tool produced, writes the chunks as appvars, and leaves it to
 * check_js.py to run them through the real calc/src renderer and diff the
 * frames. If the JS encoder and the C decoder disagree about a single byte of
 * layout, this catches it.
 *
 *   node tools/hosttest/check_js.mjs <layers.json> <outdir>
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { buildContainer, chunkName } from '../../web/js/convert.js';
import { writeAppvar } from '../../web/js/tifile.js';

const [, , layersPath, outDir] = process.argv;
if (!layersPath || !outDir) {
  console.error('usage: check_js.mjs <layers.json> <outdir>');
  process.exit(2);
}

const spec = JSON.parse(readFileSync(layersPath, 'utf8'));
const layers = spec.layers.map((layer) => ({
  width: layer.width,
  height: layer.height,
  indices: new Uint8Array(readFileSync(layer.indices)),
}));

for (const layer of layers) {
  if (layer.indices.length !== layer.width * layer.height) {
    console.error(`layer ${layer.width}x${layer.height}: got ${layer.indices.length} indices`);
    process.exit(1);
  }
}

const result = buildContainer({ layers, palette: spec.palette });
console.error(`js: ${result.chunks.length} chunks, ${result.totalBytes} bytes, `
  + `ratio ${(result.rawBytes / result.totalBytes).toFixed(2)}x`);

result.chunks.forEach((chunk, i) => {
  const name = chunkName(0, i);
  writeFileSync(`${outDir}/${name}.8xv`, writeAppvar(name, chunk));
});

writeFileSync(`${outDir}/js-summary.json`, JSON.stringify({
  chunks: result.chunks.length,
  totalBytes: result.totalBytes,
  layers: result.layers,
}));
