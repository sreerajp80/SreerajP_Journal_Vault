# Change log — OCR photo edit: enlarge, sharpen, screen filter, sharper zoom

**Plan:** `plans/20260918_215329_ocr-edit-enlarge-sharpen-screen-filter.md`
**Date:** 2026-09-18

## Summary

Photos of a computer screen with small text (a cheat sheet of short keys
and their meanings) read badly. The edit screen before OCR now has four new
tools: a **Screen** filter, **Enlarge** (1×/2×/3×), a **Sharpen** slider, and
a sharper **pinch-zoom** with double-tap. With every new control at its
default, the image sent for reading is made exactly as before.

## What changed

### Service layer — `lib/features/entries/services/ocr_enhancer.dart`

- `OcrEnhanceFilter.screen` → new `flattenScreenPhoto`: grayscale, invert if
  the median is dark, divide by a background estimated from a heavily
  blurred 256 px copy (removes glare and dark corners), a light blur for the
  screen's pixel grid, then `normalizeOcrLevels`.
- `OcrEnhanceParams.enlargeFactor` (1–3) → new `enlargeForOcr`, cubic
  scaling capped at a long edge of `kOcrEnlargedMaxLongEdge` (4500 px). At 1×
  the old size rule is kept unchanged (moved into `_fitDefaultOcrSize`,
  3000 px cap now named `kOcrMaxOutputLongEdge`).
- `OcrEnhanceParams.sharpen` (0–100) → new `sharpenForOcr`, an unsharp mask
  applied after resizing. 0 leaves pixels untouched.
- Preview size raised from 1200 to `kOcrPreviewMaxDimension` (2400 px).

### Presentation layer

| File | Change |
|---|---|
| `lib/features/entries/presentation/ocr_enhance_screen.dart` | `_enlargeFactor`, `_sharpen`, zoom controller and double-tap position; zoom constants |
| `lib/features/entries/presentation/ocr_enhance_tools.dart` | values passed to the enhancer; Reset clears them; preview zoom up to 8×, double-tap 2.5× and back; `Semantics` label on the preview |
| `lib/features/entries/presentation/ocr_enhance_tools_2.dart` | Screen filter chip; Sharpen slider and Enlarge chips in Adjust; Reset enabled by any changed value |
| `lib/features/help/presentation/attachments_ocr_help_screen.dart` | one help bullet on the new tools |

### Localization

New keys in `app_en.arb`, `app_ml.arb`, `app_sa.arb`:
`labelOcrEnhanceFilterScreen`, `labelOcrEnhanceEnlarge`, `labelOcrEnhanceScale`,
`labelOcrEnhanceSharpen`, `descOcrEnhancePreviewZoom`, `helpOcrEditTools`.
`labelOcrEnhanceScale` (`{factor}×`) is the same in every language and was
added to the parity test's allow-list.

Differences from the plan: the help key is `helpOcrEditTools` (not
`bodyHelpOcrEditTools`), to match the other `helpOcr…` bullets on that
screen. `descOcrEnhancePreviewZoom` is extra: the project rules need a
`Semantics` label on the new double-tap preview.

**Needs native-reader review:**

| Key | Malayalam | Sanskrit |
|---|---|---|
| `labelOcrEnhanceFilterScreen` | സ്ക്രീൻ | पटलम् |
| `labelOcrEnhanceEnlarge` | വലുതാക്കുക | विस्तारः |
| `labelOcrEnhanceSharpen` | മൂർച്ച | तीक्ष्णता |
| `descOcrEnhancePreviewZoom` | full sentence | full sentence |
| `helpOcrEditTools` | full paragraph | full paragraph |

### Tests and docs

- `test/features/entries/services/ocr_enhancer_test.dart`: enlarge sizes and
  cap, 1× keeps the 3000 px limit, sharpen 0 is a no-op and 100 widens an
  edge, screen filter turns light-on-dark into dark-on-light and flattens a
  glare gradient.
- `test/features/entries/presentation/ocr_enhance_screen_test.dart`: new
  values reach the enhancer and Reset clears them; double-tap zooms in and
  out; the new tools render in Malayalam and Sanskrit.
- `test/l10n/translation_parity_test.dart`: allow-list entry above.
- `docs/architecture.md` section 14: the edit tools and size caps.

No native, dependency, permission, database or network change.

## Desktop check

The same phone photo of the cheat sheet, with the app's capture cap, crop,
new filter and enlarge, preprocessing, and Tesseract with the app's own
models. "Keys" = keys read correctly on the row of their meaning, out of 20.

| Input | Original 1× | Screen 1× | Screen 2× | Screen 3× |
|---|---|---|---|---|
| Wide crop (browser bar included) | 1 | 18 | 19 | 19 |
| Same, text at 45% size | 0 | 16 | 16 | 17 |

The Screen filter does most of the work; Enlarge adds a little.

## Checks run

- `flutter gen-l10n`, `dart format lib test integration_test`
- `flutter analyze` — no issues
- `flutter test` — all 948 tests passed
- `sh tool/check_sanskrit_markers.sh` — passed
- `sh tool/check_absolute_paths.sh --all` — passed

## Not tested here — needs a real device

- The new tools on the phone, and reading time at 2× and 3×.
- The bottom tool bar of the edit screen in Malayalam and Sanskrit at phone
  width. In widget tests the test font is much wider than a real one and
  the bar overflowed at 800 px. The bar itself was not changed by this work,
  but its labels are long, so it should be looked at on the phone.
