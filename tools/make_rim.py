#!/usr/bin/env python3
"""Render app/art/rim.png: "STAKE WITH" and "VALIGATOR" curved along the
bottom of the button, with the Valigator logo in a black circle at 6 o'clock.

The badge can't rotate text, so the curve is baked into a bundled PNG.
Letters come from the badge's own bold font (sol_font_32.c in solana-os,
ABC Diatype Bold, 4 bpp), so they match the labels in main.lua.

    python3 tools/make_rim.py            # downloads the font file once
    python3 tools/make_rim.py --font path/to/sol_font_32.c

Needs Pillow. Geometry must agree with main.lua (CX, CY, face radius).
"""
import argparse
import math
import os
import re
import urllib.request

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
FONT_URL = ("https://raw.githubusercontent.com/solana-foundation/solana-os/"
            "64a474b698008dfff09d321dd1a8584ba96ccb5f/main/assets/sol_font_32.c")

# Screen geometry, as in main.lua.
CX, CY = 160, 109           # button centre on the 320 x 218 app area
FACE_R = 106                # white face radius (218 / 2 - 3 px rim)

# Rim layout (screen pixels).
LEFT, RIGHT = "STAKE WITH", "VALIGATOR"
CAP_H = 12.0                # height of the capitals on screen
BASE_R = 99.0               # radius of the letters' baseline (their feet face the rim)
TRACK = 1.2                 # extra space between letters
LOGO_D = 32                 # logo circle diameter
LOGO_R = FACE_R - 3 - LOGO_D / 2   # radius of the logo centre
LOGO_GAP = 5.0              # space between the logo and the nearest letters

# Output image: the lower part of the face, placed at (IMG_X, IMG_Y) by main.lua.
IMG_X, IMG_Y = CX - FACE_R, 120
IMG_W, IMG_H = 2 * FACE_R, CY + FACE_R - 120
SS = 4                      # supersampling


def load_font(path):
    src = open(path, encoding="utf-8").read()
    body = re.search(r"glyph_bitmap\[\] = \{(.*?)\};", src, re.S).group(1)
    data = [int(x, 16) for line in body.splitlines()
            for x in re.findall(r"0x[0-9a-fA-F]+", line.split("/*")[0])]
    dsc = re.findall(r"\{\.bitmap_index = (\d+), \.adv_w = (\d+), \.box_w = (\d+), "
                     r"\.box_h = (\d+), \.ofs_x = (-?\d+), \.ofs_y = (-?\d+)\}", src)
    glyphs = {chr(0x20 + i): tuple(map(int, d)) for i, d in enumerate(dsc[1:96])}
    line_h = int(re.search(r"\.line_height = (\d+)", src).group(1))
    base = int(re.search(r"\.base_line = (\d+)", src).group(1))
    return data, glyphs, line_h, base


def glyph_cell(font, ch):
    """The glyph as an L image the size of its advance x line height, plus the
    baseline's y in it. Pixel values are coverage 0..255."""
    data, glyphs, line_h, base = font
    bi, adv, bw, bh, ox, oy = glyphs[ch]
    pad = 4
    cell = Image.new("L", (math.ceil(adv / 16) + 2 * pad, line_h + 2 * pad), 0)
    base_y = pad + line_h - base
    top = base_y - bh - oy
    for j in range(bh):
        for i in range(bw):
            n = j * bw + i
            b = data[bi + n // 2]
            a = (b >> 4) if n % 2 == 0 else (b & 15)
            if a:
                cell.putpixel((pad + ox + i, top + j), a * 17)
    return cell, pad, base_y, adv / 16


def cap_height(font):
    _, glyphs, _, _ = font
    return glyphs["H"][3]


def place(mask, cell, ax, ay, px, py, theta, k):
    """Stamp `cell` (anchor ax, ay, scaled k) on `mask` so the anchor lands on
    (px, py), rotated so its up points at the button's centre."""
    s, c = math.sin(theta), math.cos(theta)
    # Inverse map: canvas (X, Y) -> cell (gx, gy), cell scaled by k.
    a, b = c / k, -s / k
    d, e = s / k, c / k
    cc = ax - (px * c - py * s) / k
    f = ay - (px * s + py * c) / k
    stamp = cell.transform(mask.size, Image.AFFINE, (a, b, cc, d, e, f), Image.BICUBIC)
    mask.paste(255, (0, 0), stamp)


def arc_text(mask, font, text, start, k, scale):
    """Lay `text` left to right along the bottom arc, starting at angle `start`
    (radians from 6 o'clock, positive towards 3 o'clock). Returns end angle."""
    r = BASE_R * scale
    theta = start
    for i, ch in enumerate(text):
        cell, pad, base_y, adv = glyph_cell(font, ch)
        w = adv * k / scale     # advance on screen
        mid = theta + (w / 2) / BASE_R
        px = (CX - IMG_X) * scale + r * math.sin(mid)
        py = (CY - IMG_Y) * scale + r * math.cos(mid)
        place(mask, cell, pad + adv / 2, base_y, px, py, mid, k)
        theta += (w + (TRACK if i < len(text) - 1 else 0)) / BASE_R
    return theta


def arc_len(font, text, k, scale):
    _, glyphs, _, _ = font
    return sum(glyphs[ch][1] / 16 * k / scale for ch in text) + TRACK * (len(text) - 1)


def logo_disc(path, d):
    """The logo as an RGBA disc: black circle, white V, at d x d pixels."""
    src = Image.open(path).convert("L")
    n = src.width
    big = int(n * 1.18)                       # room so the V's tips stay inside the circle
    canvas = Image.new("L", (big, big), 0)
    canvas.paste(src, ((big - n) // 2, (big - n) // 2))
    disc = Image.new("L", (big, big), 0)
    ImageDraw.Draw(disc).ellipse([0, 0, big - 1, big - 1], fill=255)
    rgba = Image.merge("RGBA", (canvas, canvas, canvas, disc))
    return rgba.resize((d, d), Image.LANCZOS)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--font", help="path to sol_font_32.c (downloaded if omitted)")
    ap.add_argument("--out", default=os.path.join(ROOT, "app", "art", "rim.png"))
    args = ap.parse_args()

    font_path = args.font
    if not font_path:
        font_path = os.path.join(HERE, ".cache", "sol_font_32.c")
        if not os.path.exists(font_path):
            os.makedirs(os.path.dirname(font_path), exist_ok=True)
            urllib.request.urlretrieve(FONT_URL, font_path)
    font = load_font(font_path)

    S = SS
    k = CAP_H / cap_height(font) * S          # font pixels -> supersampled pixels
    ink = Image.new("L", (IMG_W * S, IMG_H * S), 0)

    # The logo's half width, as an angle at the baseline, plus the gap.
    half = (LOGO_D / 2 + LOGO_GAP) / BASE_R
    left_len = arc_len(font, LEFT, k, S)
    arc_text(ink, font, LEFT, -half - left_len / BASE_R, k, S)
    arc_text(ink, font, RIGHT, half, k, S)

    # Compose: white everywhere, black ink, then the logo on top.
    rgb = Image.new("RGB", ink.size, (255, 255, 255))
    rgb.paste((0, 0, 0), (0, 0), ink)
    alpha = ink.copy()
    logo = logo_disc(os.path.join(HERE, "valigator-logo.png"), LOGO_D * S)
    lx = int((CX - IMG_X) * S - LOGO_D * S / 2)
    ly = int((CY - IMG_Y + LOGO_R) * S - LOGO_D * S / 2)
    rgb.paste(logo.convert("RGB"), (lx, ly), logo.getchannel("A"))
    alpha.paste(logo.getchannel("A"), (lx, ly), logo.getchannel("A"))

    # Down to screen size. The badge has no alpha blending (a pixel is solid or
    # see-through), and everything here sits on the white face, so blend the
    # edges against white and make them solid.
    rgb = rgb.resize((IMG_W, IMG_H), Image.BOX)
    alpha = alpha.resize((IMG_W, IMG_H), Image.BOX)
    alpha = alpha.point(lambda a: 255 if a >= 24 else 0)
    out = rgb.convert("RGBA")
    out.putalpha(alpha)

    # A small palette keeps the PNG (and the badge's decode memory) small.
    pal = out.quantize(colors=16, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    pal.save(args.out, optimize=True)
    print(f"{args.out}: {IMG_W}x{IMG_H} at ({IMG_X}, {IMG_Y}), {os.path.getsize(args.out)} bytes")


if __name__ == "__main__":
    main()
