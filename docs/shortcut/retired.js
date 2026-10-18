"use strict";
// Replace the old worker so previously installed web shortcuts stop using its cache.
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("./sw.js").catch(() => {});
}
