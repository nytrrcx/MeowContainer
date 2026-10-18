"use strict";

const CACHE = "meow-home-shortcut-v1";
const assets = ["./", "./shortcut.js", "./shortcut.css"].map(path => new URL(path, self.location).href);

self.addEventListener("install", event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(assets)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(
    keys.filter(key => key.startsWith("meow-home-shortcut-") && key !== CACHE).map(key => caches.delete(key))
  )).then(() => self.clients.claim()));
});

self.addEventListener("fetch", event => {
  if (event.request.method !== "GET") return;
  const url = new URL(event.request.url);
  url.hash = "";
  const asset = assets.find(value => {
    const candidate = new URL(value);
    return url.origin === candidate.origin && url.pathname === candidate.pathname;
  });
  if (!asset) return;
  event.respondWith(caches.open(CACHE).then(async cache => {
    const cached = await cache.match(asset);
    return cached || fetch(event.request);
  }));
});
