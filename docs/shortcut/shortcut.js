"use strict";

(() => {
  const ru = navigator.language.toLowerCase().startsWith("ru");
  document.documentElement.lang = ru ? "ru" : "en";
  const text = ru ? {
    ready: "Название и иконка уже готовы. Осталось добавить приложение на экран «Домой».",
    share: "Открой меню «Поделиться» в Safari.",
    home: "Выбери «На экран „Домой“».",
    add: "Нажми «Добавить» — менять название и картинку не нужно.",
    open: "Открыть приложение",
    launching: "Открываем приложение в MeowContainer… Если переход не произошёл, нажми кнопку ниже.",
    privacy: "Иконка и адрес запуска обрабатываются в браузере. Они не отправляются на сервер.",
    invalid: "Открой MeowContainer, зажми приложение и выбери «Добавить на экран „Домой“ → Создать ярлык»."
  } : {
    ready: "The name and icon are ready. Add this app to your Home Screen.",
    share: "Open the Share menu in Safari.",
    home: "Choose Add to Home Screen.",
    add: "Tap Add. The name and artwork are already filled in.",
    open: "Open app",
    launching: "Opening your app in MeowContainer… If it doesn't open, tap the button below.",
    privacy: "The icon and launch address stay in your browser. They aren't sent to the server.",
    invalid: "Open MeowContainer, hold an app, then choose Add to Home Screen → Create shortcut."
  };
  const element = id => document.getElementById(id);

  try {
    const fragment = location.hash.slice(1);
    if (!/^v1\.[A-Za-z0-9_-]+$/.test(fragment) || fragment.length > 100000) throw new Error("payload");
    const encoded = fragment.slice(3).replace(/-/g, "+").replace(/_/g, "/");
    const bytes = Uint8Array.from(atob(encoded), character => character.charCodeAt(0));
    const payload = JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(bytes));
    if (payload.v !== 1 || typeof payload.name !== "string" || !payload.name.trim() ||
        payload.name.length > 1024 || typeof payload.launchURL !== "string" ||
        typeof payload.icon !== "string" || payload.icon.length > 50000 ||
        !/^iVBORw0KGgo[A-Za-z0-9+/]*={0,2}$/.test(payload.icon)) throw new Error("metadata");

    // Accept only LiveContainer launch links, including the existing clone schemes.
    const launch = new URL(payload.launchURL);
    if (!/^livecontainer\d*:$/.test(launch.protocol) || launch.hostname !== "livecontainer-launch" ||
        launch.username || launch.password || launch.port || (launch.pathname && launch.pathname !== "/") ||
        launch.hash || !launch.searchParams.get("bundle-name")) throw new Error("launch");
    for (const key of launch.searchParams.keys()) {
      if (key !== "bundle-name" && key !== "container-folder-name") throw new Error("parameter");
      if (launch.searchParams.getAll(key).length !== 1) throw new Error("duplicate");
    }

    const icon = `data:image/png;base64,${payload.icon}`;
    document.title = payload.name;
    element("name").textContent = payload.name;
    element("app-title").content = payload.name;
    element("app-icon").href = icon;
    element("preview").src = icon;
    element("preview").hidden = false;
    element("privacy").textContent = text.privacy;
    element("open").textContent = text.open;
    element("open").href = launch.href;
    element("open").hidden = false;

    const standalone = navigator.standalone || matchMedia("(display-mode: standalone)").matches;
    if (standalone) {
      element("instructions").textContent = text.launching;
      location.replace(launch.href);
    } else {
      element("instructions").textContent = text.ready;
      element("step-share").textContent = text.share;
      element("step-home").textContent = text.home;
      element("step-add").textContent = text.add;
      element("steps").hidden = false;
    }

    // Cache only the static launcher. App metadata remains in the URL fragment.
    if ("serviceWorker" in navigator && location.protocol === "https:") {
      navigator.serviceWorker.register("./sw.js").catch(() => {});
    }
  } catch {
    element("instructions").textContent = text.invalid;
  }
})();
