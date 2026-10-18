"use strict";
// Retire only this launcher's static cache; there is no launch or redirect handler.
self.addEventListener("install", event => {
  event.waitUntil(self.skipWaiting());
});
self.addEventListener("activate", event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(
    keys.filter(key => key.startsWith("meow-home-shortcut-")).map(key => caches.delete(key))
  )).then(() => self.clients.claim()).then(() => self.registration.unregister()));
});
