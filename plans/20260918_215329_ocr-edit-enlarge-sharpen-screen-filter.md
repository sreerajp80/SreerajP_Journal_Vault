# Plan — OCR photo edit: enlarge, sharpen, screen filter, sharper zoom

**Status:** completed
**Change log:** `change_log/20260918_221157_ocr-edit-enlarge-sharpen-screen-filter.md`
**Date:** 2026-09-18
**Follows:** `plans/20260918_201309_ocr-keep-short-key-column.md`

## The issue

A photo of a computer screen showing a cheat sheet (small bold monospace
text, light on dark, with glare) reads badly:

- When the text is small in the photo, Tesseract splits each key from its
  meaning or drops it, and misreads single characters (`-S`→`-5`, `+G`→`+6`,
  `-i`→`4`).
- A tighter crop gave all 19 keys on their rows, but single characters were
  still misread.

A desktop test with the app's own Tesseract models on the same photo showed
that text size decides the result, but not in a straight line:

| Image short edge | Keys correct on their row |
|---|---|
| 1382 px | 0 of 20 |
| 2000 px | 6 of 20 |
| 2600 px | 1 of 20 |
| 3200 px | 17 of 20 |

So a fixed automatic enlargement is a gamble. The user asked for tools to
adjust the photo themselves and check the result before inserting it.

What the edit screen (`OcrEnhanceScreen`) already has: crop, rotate, invert,
filters (Original, Document, Grayscale, High Contrast), brightness and
contrast sliders, a text preview, and pinch-zoom on the preview. But:

- the pinch-zoom shows a preview capped at 1200 px, so zooming in only shows
  blur — you cannot judge whether the letters are sharp;
- the enhancer always shrinks its output to a long edge of 3000 px
  (`processOcrImageIsolate`, step 7), so there is no way to give small text
  more pixels.

## The fix

All image work stays in `OcrEnhancer` (service layer, background isolate).
The screen only holds the chosen values and passes them in `OcrEnhanceParams`.

### 1. Enlarge text — 1× / 2× / 3×

- New `OcrEnhanceParams.enlargeFactor` (1, 2 or 3; default 1).
- At 1× the output is exactly as today (long-edge cap 3000).
- At 2× or 3× the image is scaled up by that factor with cubic
  interpolation, capped at a long edge of **4500 px**
  (`kOcrEnlargedMaxLongEdge`). The cap protects memory: at 4500 px a
  greyscale page is about 15 MP, which the phone can hold.
- The existing OCR preprocessor (`ocr_image_preprocessor.dart`) only ever
  enlarges, never shrinks, so it will not undo this.
- Shown in the **Adjust** drawer as three chips: `1×`, `2×`, `3×`.

### 2. Sharpen — slider 0 to 100

- New `OcrEnhanceParams.sharpen` (0–100; default 0 = off).
- Unsharp mask: `result = image + amount × (image − blurred image)`, with a
  small blur radius. It runs **after** enlarging, because enlarging softens
  edges.
- Shown in the **Adjust** drawer below Contrast.

### 3. Screen-photo filter

New `OcrEnhanceFilter.screen`, shown as a fifth chip in the **Filter**
drawer. Made for photos of a monitor or phone screen:

1. grayscale;
2. **remove uneven light** (glare, dark corners): estimate the background with
   a heavy blur on a small copy, scale it back up, and divide the image by it;
3. **light-on-dark becomes dark-on-light**: if the page's median is dark,
   invert, so the preview shows what the recognizer prefers;
4. a very light blur to soften the screen's pixel grid (moiré);
5. stretch the levels (the existing `normalizeOcrLevels`).

### 4. Sharper pinch-zoom

- The preview is made at up to **2400 px** instead of 1200, so zooming shows
  real detail.
- `maxScale` goes from 4 to 8.
- Double-tap zooms to 2.5× at the tapped point; a second double-tap resets.

### 5. Reset

The existing Reset button also sets Enlarge back to 1× and Sharpen to 0.

## Files to change

| File | Layer | Change |
|---|---|---|
| `lib/features/entries/services/ocr_enhancer.dart` | service | `enlargeFactor`, `sharpen`, `OcrEnhanceFilter.screen`; new pure functions `enlargeForOcr`, `sharpenForOcr`, `flattenScreenPhoto`; preview max 2400 |
| `lib/features/entries/presentation/ocr_enhance_screen.dart` | presentation | new state fields, pass them to the enhancer |
| `lib/features/entries/presentation/ocr_enhance_tools.dart` | presentation | Reset clears the new values; double-tap zoom, `maxScale` 8 |
| `lib/features/entries/presentation/ocr_enhance_tools_2.dart` | presentation | Screen chip, Enlarge chips, Sharpen slider |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | l10n | new keys (below), then `flutter gen-l10n` |
| `lib/features/help/presentation/attachments_ocr_help_screen.dart` | presentation | one help paragraph on the new tools |
| `docs/architecture.md` | docs | section 14: the new edit tools and the 4500 px cap |
| `test/features/entries/services/ocr_enhancer_test.dart` | test | see Tests |
| `test/features/entries/presentation/ocr_enhance_screen_test.dart` | test | see Tests |

No native, dependency, permission, database or network change.

### New ARB keys (all three languages; Malayalam and Sanskrit need native-reader review)

| Key | English | Malayalam | Sanskrit |
|---|---|---|---|
| `labelOcrEnhanceFilterScreen` | Screen | സ്ക്രീൻ | पटलम् |
| `labelOcrEnhanceEnlarge` | Enlarge | വലുതാക്കുക | विस्तारः |
| `labelOcrEnhanceScale` | `{factor}×` | `{factor}×` | `{factor}×` |
| `labelOcrEnhanceSharpen` | Sharpen | മൂർച്ച | तीक्ष्णता |
| `bodyHelpOcrEditTools` | one short paragraph on Screen, Enlarge, Sharpen and zoom | translated | translated |

`labelOcrEnhanceScale` holds only a number and a sign, so the parity test
may flag it as "same as English". If so, it gets the same allow-list entry
the parity test already uses for such keys.

## Tests

Enhancer (pure functions, no UI):

- 2× on a 1000×800 image gives 2000×1600; 3× on a 2000×1600 image is capped
  at a long edge of 4500;
- 1× gives exactly today's output size (3000 cap still applies);
- sharpen 0 leaves pixels unchanged; sharpen 100 raises the contrast across
  an edge;
- screen filter: light text on a dark ground comes out dark on light;
- screen filter: a left-to-right brightness gradient with text on it comes
  out with an even background.

Screen (widget tests):

- the Screen chip appears and selecting it passes `OcrEnhanceFilter.screen`;
- the Enlarge chips and the Sharpen slider appear in Adjust and pass their
  values;
- Reset returns Enlarge to 1× and Sharpen to 0;
- all of this renders in English, Malayalam and Sanskrit.

Then: `flutter gen-l10n`, `dart format lib test integration_test`,
`flutter analyze`, `flutter test`, `sh tool/check_sanskrit_markers.sh`,
`sh tool/check_absolute_paths.sh --all`. Desktop check: the cheat-sheet
photo with Screen + 2× should read all keys on their rows.

## Acceptance criteria

- With Enlarge 2× or 3×, the wide cheat-sheet crop reads the keys on their
  rows (desktop check, then on the phone).
- Pinch-zoom shows sharp letters, not blur, at high zoom.
- The Screen filter turns the dark screen photo into dark text on an even,
  light background in the preview.
- With every new control at its default, the output is the same as today.

## Risks

- **Slower reading.** A 3× image takes longer to read — on the desktop about
  12 s at 3200 px; the phone will be slower. It only happens when the user
  picks 2× or 3×.
- **Memory.** Capped at 4500 px long edge. The enhancer already runs in a
  background isolate.
- **Enlarge is not always better** (see the table above). That is why it is a
  choice the user can try and undo, not an automatic step.
