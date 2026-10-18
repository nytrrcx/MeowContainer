# Home Screen shortcuts

The native **Add to Home Screen → Create shortcut** action opens this static
launcher with the app's name, PNG icon, and encoded launch URL. In Safari the user
chooses **Share → Add to Home Screen → Add**. No configuration profile is used.
The selected data container and the current MeowContainer copy are retained.

## Hosting

Enable GitHub Pages for this fork, choosing the branch containing these files
and the `/docs` folder. The expected URL is
`https://nytrrcx.github.io/MeowContainer/shortcut/`.
Before distributing a build, check that this URL returns the launcher. If moving
to another fork or hostname, update `LCHomeScreenShortcut.pageURL` in Swift.
The repository's existing build workflow does not publish or enable this site.

## Data and offline behavior

Only a hash identifying the shortcut is put in the query string. The name,
image, and launch URL are encoded in the URL fragment, which isn't included in
HTTP requests. There are no external scripts, analytics, or icon uploads.
The page accepts only `livecontainer[digits]://livecontainer-launch` links with
the bundle name and optional data container.

The service worker caches the static launcher. An installed Home Screen web app
needs internet on its first launch to populate its own cache. Safari can evict
that cache; the page must remain hosted. Bump the service worker cache version
when updating the static assets.

## Validation

Run `node tests/home-screen-shortcut.test.cjs` from the repository root.
Installation, the copied icon, and handoff to MeowContainer still need a real
iPhone/iPad check; a desktop browser cannot verify those iOS behaviors.
