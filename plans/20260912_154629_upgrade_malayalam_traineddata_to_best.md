# Plan — Upgrade Malayalam OCR model to the `tessdata_best` build

**Status:** Superseded by `plans/20260912_160456_ocr_confidence_filter_and_best_model.md`,
which carries out this swap together with the confidence filter.

## Why

The app currently ships the `tessdata_fast` build of both language files. This
is the smallest and quickest of the three Tesseract publishes, and also the
least accurate. Its neural network weights are stored as rounded whole numbers.
The `tessdata_best` build stores the same weights as full decimals, with no
rounding.

Malayalam is the language most hurt by that rounding. It has many stacked vowel
signs and joined letter shapes, and those are the first thing lost when weights
lose precision. This is a likely cause of the wrong characters seen in the
scanned masthead.

## Measured sizes

| File | fast (current) | standard | best |
|---|---|---|---|
| `mal.traineddata` | 5.28 MB | 5.95 MB | 12.52 MB |
| `eng.traineddata` | 4.11 MB | 23.47 MB | 15.40 MB |

## What to change

Replace **only** `assets/tessdata/mal.traineddata` with the `tessdata_best`
build. Cost: **+7.25 MB**, applied to every per-ABI APK split.

Leave `eng.traineddata` on `fast`. English recognition is already reliable and
the same swap would cost +11.3 MB for little gain.

Do not use the `standard` build. Its extra size is the old pre-neural engine
from Tesseract 3, which this app never switches on.

## Files to change

| File | Change |
|---|---|
| `assets/tessdata/mal.traineddata` | Replaced with the `tessdata_best` build |
| `docs/dependencies.md` | Record which build each language file comes from, and why they differ |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | Possibly retune `CONFIDENT_SCORE` — see the speed risk below |

No code change is needed to load the new file. `ensureTessData` copies whatever
is in the assets folder, and `TessBaseAPI.init` reads whichever build it finds.

## The speed risk, and how to handle it

Full-precision weights run roughly two to three times slower per pass. That now
matters more than it used to, because the scored multi-pass change from
`plans/20260912_152340_fix_ocr_missed_headline_and_pass_scoring.md` can run up
to six passes on a dark image.

Worst case is therefore a noticeably slow scan. Plan:

1. Swap the file and measure a real scan on a device, both a normal page and a
   dark-banded one.
2. If it feels slow, lower `CONFIDENT_SCORE` so a good first pass stops the loop
   sooner, rather than removing passes. The inverted passes are the ones that
   recover light-on-dark text and should be kept.

## Note on the existing `ensureTessData`

`ensureTessData` copies a language file out of assets only when the target is
missing or zero length. After this swap, an existing install already has an old
`mal.traineddata` of non-zero length in `filesDir`, so **the new model would
never be copied over it**. This must be fixed as part of this change, or the
upgrade silently does nothing for every current user.

Fix: compare the asset's length against the copied file's length and re-copy
when they differ. That is enough here — the two builds differ greatly in size —
and it avoids hashing a 12 MB file on every launch.

## Checks after implementing

- `flutter analyze` clean
- `flutter test`
- `./gradlew :app:compileProdDebugKotlin`
- Manual on a device: scan the same masthead photo and compare the Malayalam
  text against the current result; confirm the file is actually replaced on an
  upgrade over an existing install, not only on a fresh install
- Note the new APK size in the change log
