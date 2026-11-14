# badge-kim-jong-nope

A Solana OS badge app that shows the "Kim Jong Un is a Wanker" pin-back button
slogan (with the Union Jack) across the badge's whole 320 x 218 screen, white on
black, with "STAKE WITH [Valigator logo] VALIGATOR" along the bottom.

## Layout

- `app/`: the app itself. This folder is what you upload; everything in it ships
  to the badge.
  - `main.lua`: draws everything with `ui` (labels, a canvas for the flag) and
    shows `art/logo.png`. No permissions needed. CANCEL exits.
  - `art/logo.png`: the Valigator V, 27 x 28, white on see-through (~0.4 KB).
  - `app.json`: the manifest, which fills in the App Store submit form.
- `tools/make_logo.py`: regenerates `app/art/logo.png` from
  `tools/valigator-logo.png`. Needs Pillow: `python3 tools/make_logo.py`.

Older badges: `ui.image` and `ui.canvas` need Solana OS 0.5.9. Before that the
bottom row is text only and the flag has no diagonals.

API reference: [solana-os/docs/LUA_API.md](https://github.com/solana-foundation/solana-os/blob/main/docs/LUA_API.md)

## Try it

Drop the `app/` folder on the App Store submit page (`/apps/submit`) and use
**Try in emulator** or **Run on badge**.
