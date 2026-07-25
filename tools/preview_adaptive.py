"""Preview the Android adaptive icon as the launcher will composite it.

Mirrors mipmap-anydpi-v26/ic_launcher.xml: indigo background + foreground PNG
inset 16% on each side, then masked to circle and rounded-square shapes.
"""
import os
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, "..", "assets", "icon")
OUT = os.path.join(HERE, "..", "assets", "icon", "preview_adaptive.png")

CANVAS = 432  # 108dp @ 4x
INSET_PCT = 0.16
BG = (30, 27, 75, 255)


def composite(mask_kind):
    bg = Image.new("RGBA", (CANVAS, CANVAS), BG)
    fg = Image.open(os.path.join(ASSETS, "icon_foreground.png")).convert("RGBA")
    inset = int(CANVAS * INSET_PCT)
    inner = CANVAS - 2 * inset
    fg = fg.resize((inner, inner), Image.LANCZOS)
    bg.alpha_composite(fg, (inset, inset))

    out = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    mask = Image.new("L", (CANVAS, CANVAS), 0)
    md = ImageDraw.Draw(mask)
    if mask_kind == "circle":
        md.ellipse((0, 0, CANVAS - 1, CANVAS - 1), fill=255)
    elif mask_kind == "squircle":
        md.rounded_rectangle((0, 0, CANVAS - 1, CANVAS - 1), radius=int(CANVAS * 0.22), fill=255)
    elif mask_kind == "square":
        md.rectangle((0, 0, CANVAS - 1, CANVAS - 1), fill=255)
    out.paste(bg, (0, 0), mask)
    return out


def main():
    pad = 24
    sheet = Image.new("RGBA", (CANVAS * 3 + pad * 4, CANVAS + pad * 2), (245, 245, 250, 255))
    for i, kind in enumerate(["circle", "squircle", "square"]):
        sheet.alpha_composite(composite(kind), (pad + i * (CANVAS + pad), pad))
    sheet.save(OUT, optimize=True)
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
