/*
 * The page's glass, rendered in 3D.
 *
 * One full-window WebGL canvas sits behind the page. In it is a room: a back
 * wall with the calculator's purple in it, a few glass and glossy forms
 * drifting in front of the wall, and a slab of glass behind every panel of the
 * page -- matched to the panel's box on screen, so the page's real, accessible
 * DOM sits on real glass. A light follows the pointer. It is what lights the
 * wall, puts the highlights on every slab, and throws the panels' shadows, so
 * moving the mouse moves all of them together; the slabs refract the wall and
 * the forms behind them as physical glass does, and reflect the room.
 *
 * The camera is placed so that the z = 0 plane maps one world unit to one CSS
 * pixel. A DOM rectangle is then a world rectangle with no conversion but a
 * flipped y axis.
 *
 * Optional: main.js imports this and carries on without it. With no WebGL2, or
 * if three.js does not load, the page keeps its flat purple design; `glass-3d`
 * on <body> is what switches the CSS over, and it is only set once this runs.
 */

import * as THREE from 'three';
import { RoundedBoxGeometry } from 'three/addons/RoundedBoxGeometry.js';
import { RoomEnvironment } from 'three/addons/RoomEnvironment.js';

const FOV = 32;
const WALL_Z = -420;
const LIGHT_Z = 520;
const MAX_DPR = 1.5;
const DRIFT_FPS = 30;
const IDLE_MS = 5000;

/* How each kind of element's glass is made: thickness, corner radius, how
 * frosted, and how far it stands off the wall's side of z = 0. */
const KINDS = {
  bar:    { depth: 14, radius: 10, roughness: 0.22, lift: 0 },
  panel:  { depth: 26, radius: 14, roughness: 0.2, lift: 0 },
  card:   { depth: 34, radius: 18, roughness: 0.16, lift: 30, tilt: true },
  dialog: { depth: 30, radius: 16, roughness: 0.18, lift: 60, tilt: true },
  /* A rounded box's corners can be no rounder than half its thickness, so a
   * pill is as thick as it is tall -- or its slab shows square corners round
   * a round shape. */
  pill:   { depth: 'height', radius: 999, roughness: 0.12, lift: 6 },
  button: { depth: 20, radius: 9, roughness: 0.08, lift: 8 },
};

const THEMES = {
  dark: {
    exposure: 1.0,
    environment: 0.16,
    wallBase: '#120d1c',
    blobs: ['#7c3aed', '#8b5cf6', '#c026d3', '#4f46e5', '#a855f7', '#0ea5e9'],
    blobAlpha: 0.55,
    glassTint: 0xe9e1ff,
    attenuation: 0x6d28d9,
    light: 0xf3edff,
    hemiSky: 0x9f7aea,
    hemiGround: 0x120d1c,
    orb: 0x8b5cf6,
  },
  light: {
    exposure: 1.15,
    environment: 0.4,
    wallBase: '#efe9fb',
    blobs: ['#a78bfa', '#8b5cf6', '#e879f9', '#818cf8', '#c4b5fd', '#7dd3fc'],
    blobAlpha: 0.7,
    glassTint: 0xffffff,
    attenuation: 0xb79cf7,
    light: 0xffffff,
    hemiSky: 0xffffff,
    hemiGround: 0xd8ccf5,
    orb: 0x7c3aed,
  },
};

/* ------------------------------------------------------------ textures */

/* The wall's colour: soft blobs of the purples on a dark or pale base. */
function auroraTexture(theme) {
  const canvas = document.createElement('canvas');
  canvas.width = 1024;
  canvas.height = 640;
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = theme.wallBase;
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  /* Fixed rather than random, so the page looks the same every visit. */
  const blobs = [
    [0.18, 0.22, 0.42], [0.78, 0.18, 0.36], [0.55, 0.62, 0.5],
    [0.12, 0.85, 0.34], [0.9, 0.78, 0.3], [0.42, 0.08, 0.26],
  ];
  blobs.forEach(([x, y, r], i) => {
    const g = ctx.createRadialGradient(x * 1024, y * 640, 0, x * 1024, y * 640, r * 1024);
    g.addColorStop(0, theme.blobs[i % theme.blobs.length]);
    g.addColorStop(1, 'transparent');
    ctx.globalAlpha = theme.blobAlpha;
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, 1024, 640);
  });
  ctx.globalAlpha = 1;

  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  return texture;
}

/*
 * A fine, soft relief for the wall, as a normal map: what makes the light's
 * pool on it read as light on a surface rather than a brightened picture.
 */
function reliefTexture() {
  const size = 256;
  const height = new Float32Array(size * size);
  /* A few octaves of smoothed noise, seeded, so it is the same every time. */
  let seed = 7;
  const random = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);
  for (let octave = 0, cell = 64, amp = 1; octave < 4; octave++, cell /= 2, amp /= 2) {
    const n = size / cell + 1;
    const grid = Array.from({ length: n * n }, random);
    for (let y = 0; y < size; y++) {
      for (let x = 0; x < size; x++) {
        const gx = x / cell, gy = y / cell;
        const x0 = Math.floor(gx), y0 = Math.floor(gy);
        const fx = gx - x0, fy = gy - y0;
        const sx = fx * fx * (3 - 2 * fx), sy = fy * fy * (3 - 2 * fy);
        const at = (i, j) => grid[((j % (n - 1)) * n) + (i % (n - 1))];
        const top = at(x0, y0) * (1 - sx) + at(x0 + 1, y0) * sx;
        const bottom = at(x0, y0 + 1) * (1 - sx) + at(x0 + 1, y0 + 1) * sx;
        height[y * size + x] += (top * (1 - sy) + bottom * sy) * amp;
      }
    }
  }

  const data = new Uint8Array(size * size * 4);
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const h = (i, j) => height[((j + size) % size) * size + ((i + size) % size)];
      const dx = (h(x + 1, y) - h(x - 1, y)) * 3;
      const dy = (h(x, y + 1) - h(x, y - 1)) * 3;
      const len = Math.hypot(dx, dy, 1);
      const o = (y * size + x) * 4;
      data[o] = ((-dx / len) * 0.5 + 0.5) * 255;
      data[o + 1] = ((-dy / len) * 0.5 + 0.5) * 255;
      data[o + 2] = ((1 / len) * 0.5 + 0.5) * 255;
      data[o + 3] = 255;
    }
  }
  const texture = new THREE.DataTexture(data, size, size);
  texture.wrapS = texture.wrapT = THREE.RepeatWrapping;
  texture.repeat.set(1.5, 1);
  texture.needsUpdate = true;
  return texture;
}

/* ---------------------------------------------------------------- glass */

function glassMaterial(theme, kind) {
  return new THREE.MeshPhysicalMaterial({
    color: theme.glassTint,
    metalness: 0,
    roughness: kind.roughness,
    transmission: 1,
    thickness: kind.depth,
    ior: 1.45,
    dispersion: 0.3,
    attenuationColor: theme.attenuation,
    attenuationDistance: 260,
    clearcoat: 1,
    clearcoatRoughness: 0.06,
    specularIntensity: 1,
    envMapIntensity: 1.1,
  });
}

/* ------------------------------------------------------------------ main */

export function start({ theme = 'dark', busy = () => false } = {}) {
  const probe = document.createElement('canvas');
  if (!probe.getContext('webgl2')) throw new Error('no WebGL2');

  const canvas = document.createElement('canvas');
  canvas.id = 'scene';
  canvas.setAttribute('aria-hidden', 'true');
  document.body.prepend(canvas);

  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: false });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, MAX_DPR));
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  renderer.toneMappingExposure = (THEMES[theme] || THEMES.dark).exposure;

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(FOV, 1, 10, 8000);

  const pmrem = new THREE.PMREMGenerator(renderer);
  scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
  scene.environmentIntensity = (THEMES[theme] || THEMES.dark).environment;

  /* --- the room --- */

  let palette = THEMES[theme] || THEMES.dark;

  const wallMaterial = new THREE.MeshStandardMaterial({
    map: auroraTexture(palette),
    normalMap: reliefTexture(),
    normalScale: new THREE.Vector2(0.18, 0.18),
    roughness: 0.5,
    metalness: 0.08,
  });
  const wall = new THREE.Mesh(new THREE.PlaneGeometry(1, 1), wallMaterial);
  wall.position.z = WALL_Z;
  wall.receiveShadow = true;
  scene.add(wall);

  const hemi = new THREE.HemisphereLight(palette.hemiSky, palette.hemiGround, 0.5);
  scene.add(hemi);

  /* The light the pointer carries: a wide, soft spot aimed at the wall, so it
   * lays a pool of light there, lights every slab from where it is, and casts
   * the panels' shadows away from itself. */
  const lamp = new THREE.SpotLight(palette.light, 3.4, 0, Math.PI / 3.2, 1, 0);
  lamp.castShadow = true;
  lamp.shadow.mapSize.set(1024, 1024);
  lamp.shadow.radius = 6;
  lamp.shadow.bias = -0.0004;
  lamp.shadow.intensity = 0.45;
  scene.add(lamp);
  scene.add(lamp.target);

  /* Forms drifting between the wall and the glass: something for the glass to
   * refract, and for the light to catch. Placed as fractions of the view. */
  const forms = [];
  const formGlass = new THREE.MeshPhysicalMaterial({
    color: 0xffffff, transmission: 1, thickness: 60, roughness: 0.05, ior: 1.5,
    dispersion: 0.6, iridescence: 0.6, iridescenceIOR: 1.3, clearcoat: 1,
  });
  const formGloss = new THREE.MeshPhysicalMaterial({
    color: palette.orb, roughness: 0.18, metalness: 0.1, clearcoat: 1,
    clearcoatRoughness: 0.05, sheen: 0.6, sheenColor: 0xf0abfc,
  });
  const addForm = (geometry, material, fx, fy, z, spin) => {
    const mesh = new THREE.Mesh(geometry, material);
    mesh.castShadow = true;
    mesh.userData = { fx, fy, z, spin, phase: forms.length * 1.7 };
    scene.add(mesh);
    forms.push(mesh);
  };
  addForm(new THREE.TorusGeometry(110, 34, 48, 128), formGlass, 0.14, 0.3, -230, [0.2, 0.3]);
  addForm(new THREE.SphereGeometry(90, 64, 48), formGloss, 0.86, 0.22, -300, [0, 0]);
  addForm(new THREE.CapsuleGeometry(46, 140, 16, 48), formGlass, 0.8, 0.8, -200, [0.25, -0.2]);
  addForm(new THREE.SphereGeometry(60, 64, 48), formGlass, 0.32, 0.86, -170, [0, 0]);
  addForm(new THREE.IcosahedronGeometry(70, 0), formGloss, 0.55, 0.12, -330, [0.3, 0.2]);

  /* --- slabs behind the page --- */

  const slabs = new Map();   /* element -> mesh */
  const geometries = new Map();

  const depthOf = (kind, h) => (kind.depth === 'height' ? Math.round(h) : kind.depth);

  const geometryFor = (w, h, kind) => {
    const depth = depthOf(kind, h);
    const radius = Math.min(kind.radius, h / 2, w / 2, depth / 2) - 0.5;
    const key = `${Math.round(w)}x${Math.round(h)}x${depth}x${radius.toFixed(1)}`;
    if (!geometries.has(key)) {
      geometries.set(key, new RoundedBoxGeometry(w, h, depth, 6, Math.max(1, radius)));
    }
    return geometries.get(key);
  };

  const tracked = () => {
    const splash = document.getElementById('splash');
    const splashUp = splash && !splash.hidden;
    const out = [];
    for (const element of document.querySelectorAll('[data-glass]')) {
      if (splashUp && !splash.contains(element)) continue;
      if (!element.getClientRects().length) continue;
      out.push([element, KINDS[element.dataset.glass] || KINDS.panel]);
    }
    for (const dialog of document.querySelectorAll('dialog[open]')) out.push([dialog, KINDS.dialog]);
    return out;
  };

  let width = 0;
  let height = 0;
  let distance = 0;

  const resize = () => {
    width = window.innerWidth;
    height = window.innerHeight;
    distance = (height / 2) / Math.tan(THREE.MathUtils.degToRad(FOV / 2));
    camera.aspect = width / height;
    camera.position.set(0, 0, distance);
    camera.far = distance + 4000;
    camera.updateProjectionMatrix();
    renderer.setSize(width, height, false);

    /* The wall is further away than z = 0, so it has to be bigger to fill the
     * same view -- and a little more, for the drift. */
    const scale = (distance - WALL_Z) / distance * 1.15;
    wall.scale.set(width * scale, height * scale, 1);
    lamp.shadow.camera.far = distance + 2000;
    dirty = true;
  };

  /* A point in CSS pixels to world coordinates at depth z, as seen from the
   * camera -- so a form placed at a fraction of the view stays there at any
   * depth. */
  const toWorld = (px, py, z) => {
    const scale = (distance - z) / distance;
    return [(px - width / 2) * scale, (height / 2 - py) * scale, z];
  };

  /* --- the light --- */

  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
  const fixed = new URLSearchParams(location.search).get('light');
  let target = [width * 0.2, height * 0.12];
  let light = [...target];
  let lastMove = 0;

  if (fixed) {
    const [fx, fy] = fixed.split(',').map(Number);
    target = [fx, fy];
  }

  window.addEventListener('pointermove', (event) => {
    if (fixed) return;
    target = [event.clientX, event.clientY];
    lastMove = performance.now();
    dirty = true;
  }, { passive: true });

  /* --- keeping up with the page --- */

  let dirty = true;
  const markDirty = () => { dirty = true; };
  window.addEventListener('resize', resize);
  window.addEventListener('scroll', markDirty, { capture: true, passive: true });
  new MutationObserver(markDirty).observe(document.body, {
    attributes: true, childList: true, subtree: true,
    attributeFilter: ['hidden', 'open', 'class', 'style'],
  });

  let lastRects = '';
  const syncSlabs = (pointer) => {
    const seen = new Set();
    const signature = [];
    for (const [element, kind] of tracked()) {
      const rect = element.getBoundingClientRect();
      /* A bar runs off both edges, so its rounded ends never show. */
      const w = element.dataset.glass === 'bar' ? rect.width + 60 : rect.width;
      const h = rect.height;
      if (w < 4 || h < 4) continue;
      seen.add(element);
      signature.push(`${rect.left},${rect.top},${w},${h}`);

      let slab = slabs.get(element);
      if (!slab) {
        slab = new THREE.Mesh(geometryFor(w, h, kind),
                              glassMaterial(palette, { ...kind, depth: depthOf(kind, h) }));
        slab.castShadow = true;
        slab.userData.kind = kind;
        scene.add(slab);
        slabs.set(element, slab);
      }
      const geometry = geometryFor(w, h, kind);
      if (slab.geometry !== geometry) slab.geometry = geometry;

      const cx = rect.left + rect.width / 2;
      const cy = rect.top + h / 2;
      slab.position.set(cx - width / 2, height / 2 - cy, -depthOf(kind, h) / 2 + kind.lift);

      /* Cards and dialogs lean a few degrees toward the light, for depth. The
       * working panels stay square: nothing should move under the tree. */
      if (kind.tilt) {
        slab.rotation.y = THREE.MathUtils.clamp((pointer[0] - cx) / width, -1, 1) * 0.06;
        slab.rotation.x = THREE.MathUtils.clamp((pointer[1] - cy) / height, -1, 1) * 0.06;
      }
    }
    for (const [element, slab] of slabs) {
      if (!seen.has(element)) {
        scene.remove(slab);
        slab.material.dispose();
        slabs.delete(element);
      }
    }
    const key = signature.join('|');
    const changed = key !== lastRects;
    lastRects = key;
    return changed;
  };

  /* --- the loop --- */

  let lastFrame = 0;
  const frame = (now) => {
    requestAnimationFrame(frame);
    if (document.hidden) return;

    /* Back to the top left after a while untouched, so the room is never lit
     * from somewhere odd because the pointer was left there. */
    if (!fixed && lastMove && now - lastMove > IDLE_MS) {
      target = [width * 0.2, height * 0.12];
      lastMove = 0;
    }

    const ease = reduced.matches || fixed ? 1 : 0.12;
    const dx = target[0] - light[0];
    const dy = target[1] - light[1];
    const moving = Math.abs(dx) + Math.abs(dy) > 0.5;
    light = [light[0] + dx * ease, light[1] + dy * ease];

    /* Ambient drift is the only thing that renders without a reason, and it
     * stops for reduced motion and while the page is busy syncing. */
    const drifting = !reduced.matches && !busy() && !fixed;
    const due = drifting && now - lastFrame > 1000 / DRIFT_FPS;
    const changed = syncSlabs(light);
    if (!(dirty || moving || changed || due)) return;
    lastFrame = now;
    dirty = false;

    const t = drifting ? now / 1000 : 0;
    for (const form of forms) {
      const { fx, fy, z, spin, phase } = form.userData;
      const [x, y] = toWorld(width * fx + Math.sin(t * 0.21 + phase) * 24,
                             height * fy + Math.cos(t * 0.17 + phase) * 18, z);
      form.position.set(x, y, z);
      form.rotation.x = phase + t * spin[0];
      form.rotation.y = phase + t * spin[1];
    }

    const [lx, ly] = toWorld(light[0], light[1], LIGHT_Z);
    lamp.position.set(lx, ly, LIGHT_Z);
    const [tx, ty] = toWorld(light[0], light[1], WALL_Z);
    lamp.target.position.set(tx * 0.6, ty * 0.6, WALL_Z);

    renderer.render(scene, camera);
  };

  resize();
  target = fixed ? target : [width * 0.2, height * 0.12];
  light = [...target];
  document.body.classList.add('glass-3d');
  requestAnimationFrame(frame);

  return {
    setTheme(name) {
      palette = THEMES[name] || THEMES.dark;
      renderer.toneMappingExposure = palette.exposure;
      scene.environmentIntensity = palette.environment;
      wallMaterial.map.dispose();
      wallMaterial.map = auroraTexture(palette);
      wallMaterial.needsUpdate = true;
      hemi.color.set(palette.hemiSky);
      hemi.groundColor.set(palette.hemiGround);
      lamp.color.set(palette.light);
      formGloss.color.set(palette.orb);
      for (const slab of slabs.values()) {
        slab.material.color.set(palette.glassTint);
        slab.material.attenuationColor.set(palette.attenuation);
      }
      dirty = true;
    },
  };
}
