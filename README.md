# badge-kim-jong-nope

A Solana OS badge app that draws the "Kim Jong Un is a Wanker" pin-back button
(with the Union Jack) on the badge's 320 x 218 screen, with "STAKE WITH" and
"VALIGATOR" curved around the bottom and the Valigator logo at 6 o'clock.

## Layout

- `app/`: the app itself. This folder is what you upload; everything in it ships
  to the badge.
  - `main.lua`: draws the button with `ui` (rects, labels, a canvas for the flag)
    and shows `art/rim.png`. No permissions needed. CANCEL exits.
  - `art/rim.png`: the curved rim text and logo (212 x 95, 16 colours, ~2 KB).
  - `app.json`: the manifest, which fills in the App Store submit form.
- `tools/make_rim.py`: regenerates `app/art/rim.png`. The badge can't rotate text,
  so the curve is baked into a PNG, using the badge's own bold font
  (`sol_font_32.c` from solana-os, downloaded on first run) so it matches the
  labels. Needs Pillow: `python3 tools/make_rim.py`.
- `tools/valigator-logo.png`: the logo source.

Older badges: `ui.image` and `ui.canvas` need Solana OS 0.5.9. Before that the
rim is a straight line of text and the flag has no diagonals.

API reference: [solana-os/docs/LUA_API.md](https://github.com/solana-foundation/solana-os/blob/main/docs/LUA_API.md)

## Try it

Drop the `app/` folder on the App Store submit page (`/apps/submit`) and use
**Try in emulator** or **Run on badge**.
