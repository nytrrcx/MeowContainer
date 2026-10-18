const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const directory = path.join(__dirname, "../docs/shortcut");
const script = fs.readFileSync(path.join(directory, "shortcut.js"), "utf8");
const png = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Wl6P3sAAAAASUVORK5CYII=";
const app = {
  v: 1,
  name: "Котик & Friends 🐾",
  launchURL: "livecontainer3://livecontainer-launch?bundle-name=Shared%2FMy%20App.app&container-folder-name=container-3",
  icon: png
};

function openPage(payload = app, options = {}) {
  const elements = new Map();
  for (const id of ["preview", "steps", "open"]) elements.set(id, { hidden: true });
  const redirects = [];
  const registrations = [];
  const document = {
    documentElement: {},
    getElementById(id) {
      if (!elements.has(id)) elements.set(id, {});
      return elements.get(id);
    }
  };
  const fragment = options.fragment ?? `v1.${Buffer.from(JSON.stringify(payload)).toString("base64url")}`;
  vm.runInNewContext(script, {
    document,
    navigator: {
      language: options.language ?? "en-US",
      standalone: options.standalone ?? false,
      serviceWorker: { register: url => { registrations.push(url); return Promise.resolve(); } }
    },
    location: { hash: `#${fragment}`, protocol: "https:", replace: url => redirects.push(url) },
    matchMedia: () => ({ matches: options.displayMode ?? false }),
    atob, Uint8Array, TextDecoder, URL
  });
  return { document, elements, redirects, registrations };
}

test("prepares the app's name, artwork and exact clone/container link without launching during installation", () => {
  const page = openPage();
  assert.equal(page.document.title, app.name);
  assert.equal(page.elements.get("app-title").content, app.name);
  assert.equal(page.elements.get("app-icon").href, `data:image/png;base64,${png}`);
  assert.equal(page.elements.get("preview").src, page.elements.get("app-icon").href);
  assert.equal(page.elements.get("open").href, app.launchURL);
  assert.equal(page.elements.get("steps").hidden, false);
  assert.deepEqual(page.redirects, []);
  assert.deepEqual(page.registrations, ["./sw.js"]);
});

test("launches the selected clone and container from an installed icon", () => {
  for (const options of [{ standalone: true }, { displayMode: true }]) {
    const page = openPage(app, options);
    assert.deepEqual(page.redirects, [app.launchURL]);
    assert.equal(page.elements.get("open").href, app.launchURL);
    assert.equal(page.elements.get("steps").hidden, true);
  }
});

test("supports primary LiveContainer and a launch without a pinned container", () => {
  const payload = { ...app, launchURL: "livecontainer://livecontainer-launch?bundle-name=Test.app" };
  assert.deepEqual(openPage(payload, { standalone: true }).redirects, [payload.launchURL]);
});

test("uses Russian instructions and treats app names as text", () => {
  const name = '<img src=x onerror="alert(1)">';
  const page = openPage({ ...app, name }, { language: "ru-RU" });
  assert.equal(page.document.documentElement.lang, "ru");
  assert.equal(page.elements.get("name").textContent, name);
  assert.match(page.elements.get("step-add").textContent, /Добавить/);
  assert.equal(page.elements.get("name").innerHTML, undefined);
});

for (const launchURL of [
  "https://example.com/",
  "javascript:alert(1)",
  "otherapp://livecontainer-launch?bundle-name=App.app",
  "livecontainer://open-url?bundle-name=App.app",
  "livecontainer://user@livecontainer-launch?bundle-name=App.app",
  "livecontainer://livecontainer-launch:123?bundle-name=App.app",
  "livecontainer://livecontainer-launch/path?bundle-name=App.app",
  "livecontainer://livecontainer-launch?bundle-name=App.app#extra",
  "livecontainer://livecontainer-launch?container-folder-name=container",
  "livecontainer://livecontainer-launch?bundle-name=",
  "livecontainer://livecontainer-launch?bundle-name=App.app&bundle-name=Other.app",
  "livecontainer://livecontainer-launch?bundle-name=App.app&open-url=anything"
]) {
  test(`rejects unsupported or ambiguous launch URL: ${launchURL}`, () => {
    const page = openPage({ ...app, launchURL }, { standalone: true });
    assert.deepEqual(page.redirects, []);
    assert.deepEqual(page.registrations, []);
    assert.equal(page.elements.get("open").hidden, true);
    assert.equal(page.elements.get("preview").hidden, true);
  });
}

test("rejects missing, malformed, oversized or unsupported metadata", () => {
  for (const payload of [{ ...app, v: 2 }, { ...app, name: "" }, { ...app, name: "x".repeat(1025) },
                         { ...app, icon: "data:image/svg+xml,<svg/>" }, { ...app, icon: "x".repeat(50001) }, null]) {
    const page = openPage(payload, { standalone: true });
    assert.deepEqual(page.redirects, []);
    assert.equal(page.elements.get("open").hidden, true);
  }
  for (const fragment of ["", "v1.broken%", "v1.e30", "v1." + "A".repeat(100001)]) {
    assert.deepEqual(openPage(app, { fragment, standalone: true }).redirects, []);
  }
});

test("offline cache serves distinct shortcut IDs from the static page without a server request", async () => {
  const handlers = {};
  const lookedUp = [];
  const cached = { body: "cached launcher" };
  vm.runInNewContext(fs.readFileSync(path.join(directory, "sw.js"), "utf8"), {
    URL,
    self: {
      location: "https://nytrrcx.github.io/MeowContainer/shortcut/sw.js",
      addEventListener: (name, handler) => { handlers[name] = handler; }
    },
    caches: { open: async () => ({ match: async url => { lookedUp.push(url); return cached; } }) },
    fetch: () => { throw new Error("Offline: network unavailable"); }
  });
  for (const id of ["app-one", "app-two"]) {
    let response;
    handlers.fetch({
      request: { method: "GET", url: `https://nytrrcx.github.io/MeowContainer/shortcut/?id=${id}` },
      respondWith: value => { response = value; }
    });
    assert.equal(await response, cached);
  }
  assert.deepEqual(lookedUp, Array(2).fill("https://nytrrcx.github.io/MeowContainer/shortcut/"));
  handlers.fetch({
    request: { method: "GET", url: "https://example.com/" },
    respondWith: () => assert.fail("Must not intercept other origins")
  });
});
