#!/usr/bin/env python3
"""Render app/art/logo.png: the Valigator V, white on see-through, sized for
the bottom row of main.lua.

    python3 tools/make_logo.py [--height 28]

Needs Pillow. The badge has no alpha blending (a pixel is solid or
see-through), so edge pixels are blended against the app's black background
and made solid.
"""
import argparse
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--height", type=int, default=28, help="logo height on screen, px")
    ap.add_argument("--src", default=os.path.join(HERE, "valigator-logo.png"))
    ap.add_argument("--out", default=os.path.join(ROOT, "app", "art", "logo.png"))
    args = ap.parse_args()

    v = Image.open(args.src).convert("L")             # white V on black
    v = v.crop(v.point(lambda p: 255 if p > 128 else 0).getbbox())
    w = round(v.width * args.height / v.height)
    v = v.resize((w, args.height), Image.LANCZOS)

    # White blended against black is just grey; faint pixels become see-through.
    alpha = v.point(lambda p: 255 if p >= 24 else 0)
    out = Image.merge("RGBA", (v, v, v, alpha))
    pal = out.quantize(colors=16, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    pal.save(args.out, optimize=True)
    print(f"{args.out}: {w}x{args.height}, {os.path.getsize(args.out)} bytes")


if __name__ == "__main__":
    main()
