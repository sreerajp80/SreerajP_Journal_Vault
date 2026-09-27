# Change log — Fix OCR noise regression, and the Document filter

**Plan:** `plans/20260918_074147_ocr-noise-regression-fix.md`
**Follows:** `change_log/20260918_074500_ocr-accuracy-image-cleanup.md`
**Date:** 2026-09-18

## Summary

The clean-up change earlier today made a photo of a computer screen read as
hundreds of junk words. The screen's moiré texture was turned into fake
letters, and the score rewarded the extra "words". Desktop testing also found
an older cause: the "Document" filter stretched background texture into fake
ink whenever text covered less than 5% of the photo.

## What changed

### Native (`MainActivity.kt`, platform layer)

1. **Two candidates, old path first.** The untouched photo is read first with
   Tesseract's default Otsu thresholding, which is the pre-2026-09-18 reading.
   Only if that is not already confident is a cleaned copy read with Sauvola.
   The better score wins, so the clean-up can add a better reading but can no
   longer replace a good one. This logic lives in the new `readBestCandidate`.
   The English-only re-read uses it too, and the cleaned images are made once
   and shared.
2. **A score that punishes junk.** `scoreWords`: each kept word adds
   `confidence − 45` (`WORD_SCORE_OFFSET`). `collectConfidentText` now returns
   the text together with this score. The old "mean × words" score is kept only
   for the early stop (`earlyStopScore`).
3. **Junk lines dropped.** A line is dropped when its average confidence is
   under 35 (`JUNK_LINE_MEAN_CONFIDENCE`) and no word reaches 60
   (`JUNK_LINE_MAX_CONFIDENCE`). Single words on English pages are still never
   dropped.
4. **Gentler clean-up.** The unsharp mask is removed. Background normalisation
   is skipped for a dark photo, for both the photo and its inverted copy. This
   is how it was tested; the plan only mentioned the not-inverted copy. The
   separate "untouched photo if nothing found" fallback is gone, because the
   untouched photo is now always read first.
5. Constants: `OTSU_THRESHOLDING`, `WORD_SCORE_OFFSET`,
   `JUNK_LINE_MEAN_CONFIDENCE`, `JUNK_LINE_MAX_CONFIDENCE`. Removed:
   `UNSHARP_HALF_WIDTH`, `UNSHARP_FRACTION`. `ENGLISH_READING_MIN_SCORE_RATIO`
   is now a Float; a zero or negative bilingual score is matched instead of
   scaled (`englishWinningScore`).

### Dart (`ocr_enhancer.dart`, service layer)

`kOcrLevelClipFraction` changed from 0.05 to 0.005. The Document filter's level
stretch now takes its black and white points from the darkest and lightest
0.5% of pixels, so it finds the real ink instead of the paper grain or screen
texture.

### Other files

| File | Change |
|---|---|
| `test/features/entries/services/ocr_enhancer_test.dart` | New test: grainy paper with ink over 2% of the page stays light. Checked to fail with 0.05 |
| `docs/architecture.md` | Section 14: OCR pipeline rewritten |

No l10n, dependency, permission or schema change.

## Desktop test results

Setup: Tesseract 5.5.3 and Leptonica 1.87 from conda-forge, in a temporary
folder outside the repository. The app's own `assets/tessdata` models. A
Python copy of the Document filter and the final Kotlin logic, calling the
real Tesseract and Leptonica functions. The images are synthetic. Character
error rate, English:

| Image, filter | Before 2026-09-18 | After first change (regression) | Now |
|---|---|---|---|
| Screen with moiré, Original | 0.8% | 81.3% | 0.8% |
| Screen with moiré, Document | 93.9% | 93.9% | 0.3% |
| Shadowed, tilted paper, Original | 8.6% | 1.5% | 3.1% |
| Shadowed, tilted paper, Document | 3.3% | 14.4% | 2.5% |
| Clean shadowed paper, Original | 0.0% | 0.0% | 0.0% |

The Malayalam test images could not be drawn with correct letter joining on
the PC. They only showed that the new logic is no worse than the old one.

## Checks run

- `flutter analyze` — no issues.
- `flutter test` — all 935 tests passed.
- `dart format lib test integration_test` — clean.
- `sh tool/check_absolute_paths.sh --all` — passed.
- Kotlin compiles (`:app:compileDevDebugKotlin`).
- The generated `GeneratedPluginRegistrant.java` was deleted after the debug
  compile, so the next release build regenerates it without dev-only plugins.

## Not tested here — needs a real device

- The same screen photo from the bug report, with Original and Document.
- Real Malayalam and mixed pages with "English + മലയാളം".
- A shadowed paper page.
- Reading time. A confident first reading stops early; otherwise the cleaned
  candidate adds one more set of passes.
