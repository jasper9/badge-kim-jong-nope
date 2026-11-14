# badge-kim-jong-nope

A Solana OS badge app that draws the "Kim Jong Un is a Wanker" pin-back button
(with the Union Jack) on the badge's 320 x 218 screen.

- `main.lua`: the app. Uses only `ui` (rects, labels, a canvas for the flag), so it
  needs no permissions. The flag needs `ui.canvas` (Solana OS 0.5.9+); older badges
  get a simplified flag without the diagonals. CANCEL exits.
- `app.json`: the manifest, which fills in the form on the App Store submit page.

API reference: [solana-os/docs/LUA_API.md](https://github.com/solana-foundation/solana-os/blob/main/docs/LUA_API.md)

## Try it

Drop this folder on the App Store submit page (`/apps/submit`) and use
**Try in emulator** or **Run on badge**.
