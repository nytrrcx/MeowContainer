# Native Home Screen shortcuts

The browser-based Create shortcut action has been removed. MeowContainer no
longer opens this website to prepare or launch a Home Screen shortcut.
The page remains only to retire the old service worker and explain the change
to anyone who installed a web icon from the previous build.

Use the original LiveContainer workflow:

1. Select the app's data container in MeowContainer.
2. Hold the app and choose Add to Home Screen → Copy Launch URL.
3. In Apple's Shortcuts app, create a shortcut with MeowContainer's **Launch App**
   action and paste the URL into its Launch URL parameter.
4. Add that shortcut to the Home Screen. Use Save App Icon in MeowContainer to
   export the app's icon if needed.

Launch App runs through the existing LaunchAppExtension. Keep the required app
extensions when installing/signing the IPA. It does not use this website or
Safari. The existing Open URLs action is an alternative native shortcut.

Automatic creation/import of a complete native Launch App shortcut has **not**
been implemented. Do not label a website bookmark or an unsigned `.shortcut`
export as equivalent to that feature.

Official guide: https://livecontainer.github.io/docs/guides/add-to-home-screen
