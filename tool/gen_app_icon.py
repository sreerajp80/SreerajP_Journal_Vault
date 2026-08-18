"""Generate launcher icons for SreerajP Journal Vault.

Design: a closed leather-bound journal with a gold keyhole escutcheon at center,
on a deep-indigo background with a soft glow. Outputs:

  assets/icon/icon.png             1024x1024 full-bleed (legacy Android, iOS)
  assets/icon/icon_foreground.png  1024x1024 transparent foreground (adaptive Android)

Run from the project root:
  python tool/gen_app_icon.py
"""
from __future__ import annotations

import math
import os
from PIL import Image, ImageDraw, ImageFilter
import numpy as np

SIZE = 1024

# Palette
INDIGO_TOP   = (42, 38, 102)
INDIGO_BG    = (30, 27, 75)
INDIGO_DEEP  = (12, 10, 38)
COVER_LIGHT  = (66, 60, 155)
COVER_BASE   = (40, 36, 110)
COVER_DEEP   = (22, 19, 65)
GOLD_HI      = (250, 222, 138)
GOLD         = (212, 175, 55)
GOLD_LO      = (155, 118, 28)
GOLD_DARK    = (95, 70, 14)
CREAM_HI     = (250, 238, 210)
CREAM        = (232, 215, 175)
CREAM_LO     = (180, 160, 115)


def _gradient(size, c1, c2, angle_deg):
    w, h = size
    rad = math.radians(angle_deg)
    dx, dy = math.cos(rad), math.sin(rad)
    ys, xs = np.mgrid[0:h, 0:w].astype(np.float32)
    proj = xs * dx + ys * dy
    proj = (proj - proj.min()) / max(1e-9, proj.max() - proj.min())
    a = np.array(c1, dtype=np.float32)
    b = np.array(c2, dtype=np.float32)
    rgb = a + (b - a) * proj[..., None]
    rgba = np.concatenate([rgb, 255 * np.ones_like(rgb[..., :1])], axis=-1)
    return Image.fromarray(rgba.astype(np.uint8), "RGBA")


def render_background():
    bg = _gradient((SIZE, SIZE), INDIGO_TOP, INDIGO_DEEP, angle_deg=90)
    ys, xs = np.mgrid[0:SIZE, 0:SIZE].astype(np.float32)
    cx, cy = SIZE / 2.0, SIZE * 0.40
    r = np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2) / (SIZE * 0.55)
    glow = np.clip(1.0 - r, 0.0, 1.0) ** 2
    glow_color = np.array([72, 64, 175], dtype=np.float32)
    arr = np.array(bg, dtype=np.float32)
    arr[..., :3] = arr[..., :3] + (glow_color - arr[..., :3]) * glow[..., None] * 0.32
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")


def _round_mask(size, radius):
    w, h = size
    m = Image.new("L", (w, h), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, w - 1, h - 1), radius=radius, fill=255)
    return m


def make_book_cover(w, h):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    radius = int(min(w, h) * 0.07)

    cover = _gradient((w, h), COVER_LIGHT, COVER_DEEP, angle_deg=130)
    img.paste(cover, (0, 0), _round_mask((w, h), radius))

    # Spine (left): darker vertical band
    spine_w = max(8, int(w * 0.045))
    spine = _gradient((spine_w, h), INDIGO_DEEP, COVER_DEEP, angle_deg=0)
    img.paste(spine, (0, 0), _round_mask((w, h), radius).crop((0, 0, spine_w, h)))

    # Pages (right): cream sliver with horizontal striations
    page_w = max(8, int(w * 0.038))
    page = _gradient((page_w, h), CREAM, CREAM_LO, angle_deg=0)
    img.paste(page, (w - page_w, 0), _round_mask((w, h), radius).crop((w - page_w, 0, w, h)))
    pdraw = ImageDraw.Draw(img, "RGBA")
    for y in range(int(h * 0.06), int(h * 0.94), max(4, int(h * 0.012))):
        pdraw.line([(w - page_w + 2, y), (w - 4, y)], fill=(155, 130, 80, 90), width=1)

    draw = ImageDraw.Draw(img, "RGBA")

    # Decorative gold border (single, prominent)
    bx, by = int(w * 0.085), int(h * 0.06)
    draw.rounded_rectangle(
        (bx, by, w - bx, h - by),
        radius=int(radius * 0.7),
        outline=(*GOLD, 235),
        width=max(3, int(min(w, h) * 0.008)),
    )

    # Top + bottom horizontal rules
    rule_w = max(2, int(min(w, h) * 0.005))
    draw.line(
        [(int(w * 0.24), int(h * 0.18)), (int(w * 0.76), int(h * 0.18))],
        fill=(*GOLD, 210),
        width=rule_w,
    )
    draw.line(
        [(int(w * 0.24), int(h * 0.82)), (int(w * 0.76), int(h * 0.82))],
        fill=(*GOLD, 210),
        width=rule_w,
    )

    # Corner diamonds (gold flourishes)
    d_size = int(min(w, h) * 0.022)
    for cx, cy in [
        (bx + d_size + 4, by + d_size + 4),
        (w - bx - d_size - 4, by + d_size + 4),
        (bx + d_size + 4, h - by - d_size - 4),
        (w - bx - d_size - 4, h - by - d_size - 4),
    ]:
        draw.polygon(
            [(cx, cy - d_size), (cx + d_size, cy), (cx, cy + d_size), (cx - d_size, cy)],
            fill=(*GOLD, 230),
        )

    # Keyhole escutcheon: gold pill plate at center
    cx, cy = w // 2, h // 2
    plate_w = int(w * 0.34)
    plate_h = int(h * 0.42)
    plate = _gradient((plate_w, plate_h), GOLD_HI, GOLD_LO, angle_deg=125)
    plate_mask = Image.new("L", (plate_w, plate_h), 0)
    ImageDraw.Draw(plate_mask).rounded_rectangle(
        (0, 0, plate_w - 1, plate_h - 1), radius=plate_w // 2, fill=255
    )
    img.paste(plate, (cx - plate_w // 2, cy - plate_h // 2), plate_mask)

    # Plate inner rim (thin darker line for depth)
    rim_pad = max(3, int(plate_w * 0.04))
    ImageDraw.Draw(img, "RGBA").rounded_rectangle(
        (
            cx - plate_w // 2 + rim_pad,
            cy - plate_h // 2 + rim_pad,
            cx + plate_w // 2 - rim_pad,
            cy + plate_h // 2 - rim_pad,
        ),
        radius=(plate_w - 2 * rim_pad) // 2,
        outline=(*GOLD_DARK, 160),
        width=max(1, int(plate_w * 0.012)),
    )

    # Recessed dark inset behind the keyhole shape
    inset_w = int(plate_w * 0.78)
    inset_h = int(plate_h * 0.84)
    inset = _gradient((inset_w, inset_h), INDIGO_DEEP, COVER_DEEP, angle_deg=125)
    inset_mask = Image.new("L", (inset_w, inset_h), 0)
    ImageDraw.Draw(inset_mask).rounded_rectangle(
        (0, 0, inset_w - 1, inset_h - 1), radius=inset_w // 2, fill=255
    )
    img.paste(inset, (cx - inset_w // 2, cy - inset_h // 2), inset_mask)

    # Keyhole: circle barrel + tapered slot
    draw = ImageDraw.Draw(img, "RGBA")
    barrel_r = int(w * 0.062)
    barrel_cy = cy - int(h * 0.045)
    draw.ellipse(
        (cx - barrel_r, barrel_cy - barrel_r, cx + barrel_r, barrel_cy + barrel_r),
        fill=(*GOLD_HI, 255),
    )

    slot_top_w = barrel_r * 0.58
    slot_bot_w = barrel_r * 1.15
    slot_top_y = barrel_cy + int(barrel_r * 0.78)
    slot_bot_y = slot_top_y + int(h * 0.13)
    draw.polygon(
        [
            (cx - slot_top_w, slot_top_y),
            (cx + slot_top_w, slot_top_y),
            (cx + slot_bot_w, slot_bot_y),
            (cx - slot_bot_w, slot_bot_y),
        ],
        fill=(*GOLD_HI, 255),
    )
    draw.ellipse(
        (cx - slot_bot_w, slot_bot_y - 3, cx + slot_bot_w, slot_bot_y + int(barrel_r * 0.45)),
        fill=(*GOLD_HI, 255),
    )

    # Soft highlight on the barrel for depth
    hi_r = int(barrel_r * 0.45)
    hi_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(hi_layer).ellipse(
        (
            cx - barrel_r * 0.35 - hi_r,
            barrel_cy - barrel_r * 0.45 - hi_r,
            cx - barrel_r * 0.35 + hi_r,
            barrel_cy - barrel_r * 0.45 + hi_r,
        ),
        fill=(255, 245, 210, 180),
    )
    hi_layer = hi_layer.filter(ImageFilter.GaussianBlur(radius=4))
    img.alpha_composite(hi_layer)

    return img


def _book_shadow(canvas_size, bw, bh, offset=(14, 22), blur=24, opacity=130):
    layer = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    sx0 = (canvas_size - bw) // 2 + offset[0]
    sy0 = (canvas_size - bh) // 2 + offset[1]
    ImageDraw.Draw(layer).rounded_rectangle(
        (sx0, sy0, sx0 + bw, sy0 + bh),
        radius=int(min(bw, bh) * 0.07),
        fill=(0, 0, 0, opacity),
    )
    return layer.filter(ImageFilter.GaussianBlur(radius=blur))


def make_legacy_icon():
    """Full-bleed icon: indigo background + book."""
    bg = render_background()
    bw, bh = int(SIZE * 0.58), int(SIZE * 0.76)
    bg.alpha_composite(_book_shadow(SIZE, bw, bh))
    bg.alpha_composite(make_book_cover(bw, bh), ((SIZE - bw) // 2, (SIZE - bh) // 2))
    return bg


def make_foreground_icon():
    """Transparent-bg icon for Android adaptive foreground.

    flutter_launcher_icons wraps this layer in a 16% inset on the 108dp canvas,
    so the content is sized close to full-bleed; after the inset it lands at
    ~48% width / ~63% height of the launcher canvas, comfortably inside the
    central 66dp safe zone for circular masks while filling rounded-square
    masks well.
    """
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    bw, bh = int(SIZE * 0.70), int(SIZE * 0.92)
    img.alpha_composite(_book_shadow(SIZE, bw, bh, offset=(12, 18), blur=20, opacity=110))
    img.alpha_composite(make_book_cover(bw, bh), ((SIZE - bw) // 2, (SIZE - bh) // 2))
    return img


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.normpath(os.path.join(here, "..", "assets", "icon"))
    os.makedirs(out_dir, exist_ok=True)

    legacy_path = os.path.join(out_dir, "icon.png")
    fg_path = os.path.join(out_dir, "icon_foreground.png")

    make_legacy_icon().save(legacy_path, optimize=True)
    print(f"wrote {legacy_path}")

    make_foreground_icon().save(fg_path, optimize=True)
    print(f"wrote {fg_path}")


if __name__ == "__main__":
    main()
