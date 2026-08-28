/*
 * Caches the shell so the app opens without a network, and nothing else.
 *
 * Messages are deliberately not cached. A chat that shows you yesterday's
 * conversation and does not say so is worse than one that says it is offline,
 * and the relay is the only thing that knows what has actually been said.
 */

const SHELL = 'eos-shell-v1';
const FILES = [
  '/',
  '/static/app.css',
  '/static/app.js',
  '/static/icon.svg',
  '/manifest.webmanifest',
];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(SHELL).then((cache) => cache.addAll(FILES)));
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((names) => Promise.all(
      names.filter((name) => name !== SHELL).map((name) => caches.delete(name)),
    )).then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  if (event.request.method !== 'GET' || url.pathname.startsWith('/api/')) return;

  /* Network first, so a redeployed shell is picked up on the next load rather
   * than whenever the cache happens to be cleared. */
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        const copy = response.clone();
        caches.open(SHELL).then((cache) => cache.put(event.request, copy));
        return response;
      })
      .catch(() => caches.match(event.request).then((hit) => hit || caches.match('/'))),
  );
});
