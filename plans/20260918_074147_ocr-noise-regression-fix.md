# Plan — Fix OCR noise regression from the image clean-up

**Status:** completed
**Change log:** `change_log/20260918_194500_ocr-noise-regression-fix.md`
**Date:** 2026-09-18
**Follows:** `plans/20260918_070527_ocr-accuracy-image-cleanup.md`

## The issue

After the clean-up change, a photo of a computer screen gave far worse text:
523 "words", mostly junk lines such as `WEE Jarman ing on the navigation co CE eS`,
with the real lines broken up among them. The language was English only, so
the English re-read was not involved.

The photo has a strong moiré pattern. Moiré is the wavy texture you get when a
camera photographs a screen. The junk comes from three things the last change
did together:

1. **Sauvola thresholding reads texture as ink.** It picks a threshold for each
   small area. Where an area holds only background texture, it still splits it
   into black and white, and the black specks look like letters. Otsu (the old,
   single threshold) put the whole textured background on the "paper" side.
2. **Background normalisation and unsharp mask strengthen the texture.** They
   stretch local contrast and sharpen edges, and moiré has lots of both.
3. **The scoring rewards junk.** A reading scores *mean confidence × word
   count*. Hundreds of noise "words" beat the 80 real ones, so the noisy pass
   won. On English pages every word is kept, so nothing removed the noise
   afterwards.

The safety fallback only ran when the cleaned image gave *no* text. Here it
gave a lot of bad text, so the fallback never ran. The plan promised "no scan
worse than today", and the code did not keep that promise.

## The fix

### 1. The old path comes back first. The clean-up only competes with it

- The first reading uses the **untouched photo with Tesseract's default Otsu
  thresholding**. That is exactly what ran before the last change.
- The cleaned image with Sauvola is read as a **second candidate**. It is
  skipped when the first reading is already confident (the existing early
  stop: score and mean confidence both high).
- The better reading wins under the new score in step 2. This way the clean-up
  can only help: on a shadowed paper page it wins, and on a textured screen
  photo it loses.

### 2. A score that punishes junk

Each word adds `confidence − 45` to the score. A real word (confidence 70–95)
adds a lot. A noise word (confidence 10–40) *subtracts*. More junk now means a
lower score, not a higher one. The per-word confidences come from the result
iterator that `collectConfidentText` already walks.

### 3. Drop junk lines, not words

After the best reading is chosen, a line is dropped when its **average** word
confidence is under 35 **and** it has no word above 60. A real line from a
phone photo nearly always has some confident words. A noise line has none.
Single words are never dropped on English pages, so the earlier problem
("real words thrown away") does not come back.

### 4. Gentler clean-up

- Remove the unsharp mask. It helps least and strengthens texture most.
- Keep background normalisation and deskew. Apply background normalisation
  only to an image with dark text on light paper, never to the dark
  (not-inverted) copy of a light-on-dark photo, where it would wipe the text
  out.

### 5. Fix the "Document" filter (Dart) — found by desktop testing

The desktop test showed a second, older cause. The "Document" filter stretches
levels so the darkest 5% of pixels become black and the lightest 5% white.
Text often covers **less than 5%** of the pixels. The black point then lands
in the paper grain or the screen texture, not in the ink, and the stretch
blows that texture up to full black-and-white. After that, no OCR setting can
recover the text.

Change `kOcrLevelClipFraction` in `lib/features/entries/services/ocr_enhancer.dart`
from `0.05` to `0.005` (0.5%). The stretch still ignores a few specks of dust
or glare, but it now finds the real ink and paper.

### Unchanged

The English re-read (slice 2) and the blur warning (slice 4) stay as they are.
The re-read uses the new score too.

## Files to change

| File | Layer | Change |
|---|---|---|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | Platform (native) | Two-candidate flow (untouched + Otsu first, cleaned + Sauvola second); new score from word confidences; junk-line filter; unsharp mask removed; background normalisation only on light images; constants `WORD_SCORE_OFFSET` (45), `JUNK_LINE_MEAN_CONFIDENCE` (35), `JUNK_LINE_MAX_CONFIDENCE` (60) |
| `lib/features/entries/services/ocr_enhancer.dart` | Service | `kOcrLevelClipFraction` 0.05 → 0.005, doc comment updated |
| `test/features/entries/services/ocr_enhancer_test.dart` | Test | A page where ink covers under 5% keeps a white background after the Document filter (fails with 0.05) |
| `docs/architecture.md` | Docs | Section 14 OCR pipeline updated |

No l10n, dependency, permission or schema change.

## Desktop test results (2026-09-18)

Tested on the PC with Tesseract 5.5.3 and Leptonica 1.87 (from conda-forge,
installed in a temporary folder outside the repository), the app's own
`assets/tessdata` models, and a Python copy of the Dart filter and the Kotlin
pipeline that calls the real Tesseract and Leptonica functions. The test
images are synthetic: a screen photo with moiré, a shadowed and tilted paper
page, and Malayalam and mixed pages. Numbers are the character error rate
(lower is better), language `eng` unless noted.

| Image, filter | Before 2026-09-18 | Current (regression) | Proposed (with Document fix) |
|---|---|---|---|
| Screen with moiré, Original | 0.8% | **81.3%** (861 junk words) | 0.0% |
| Screen with moiré, Document | 93.9% | 93.9% | 0.0% |
| Shadowed, tilted paper, Original | 8.6% | 1.5% | 3.1% |
| Shadowed, tilted paper, Document | 3.3% | 14.4% | 1.7% |
| Malayalam page, `eng+mal`, Original | 20.0% | 9.3% | 8.6% |
| Mixed page, `eng+mal`, Original | 49.7% | 43.6% | 49.7% |

The Malayalam and mixed images were drawn without proper Malayalam letter
joining (the desktop drawing library lacks it), so only the relative order of
those rows means anything. Real Malayalam photos are still needed.

## Acceptance criteria

1. The screen photo from the bug report gives clean text again, at least as
   good as before the clean-up change.
2. A shadowed or tilted paper page still gains from the clean-up.
3. Malayalam and mixed pages are no worse than before.
4. `flutter analyze`, `flutter test` and the Kotlin compile pass.

## Testing on a device

The owner re-checks the same screen photo, plus one paper page, one Malayalam
page and one shadowed page. It would help to keep these photos as a small
fixed test set, so every later OCR change is compared on the same images.
