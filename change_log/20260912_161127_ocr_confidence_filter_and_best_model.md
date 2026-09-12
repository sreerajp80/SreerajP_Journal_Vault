# Change log — Confidence-filtered OCR output and the best Malayalam model

**Plan:** `plans/20260912_160456_ocr_confidence_filter_and_best_model.md`
**Date:** 2026-09-12

Follows `change_log/20260912_152340_fix_ocr_missed_headline_and_pass_scoring.md`,
which fixed the missed title. This change removes the junk words that were left
and raises Malayalam accuracy.

## What was wrong

After the previous fix a scanned masthead read its title correctly, but the
output still contained `BBE` where a printed ornament sits between the date and
the volume number. There is no text at that spot.

Running `eng+mal` means that when Tesseract meets a shape that is not a letter —
an ornament, a rule, a logo mark — it still tries to name it, and a Latin letter
is the easiest fit. It reports these with very low confidence. The app called
`tess.utF8Text`, which returns every word regardless of confidence, so the junk
was kept.

Separately, both language files were the `tessdata_fast` build, the least
accurate of the three Tesseract publishes.

## What changed

### `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`

- New `collectConfidentText`. It walks `tess.resultIterator` word by word and
  keeps only words scoring at or above `WORD_CONFIDENCE_FLOOR` (55 out of 100),
  rebuilding line breaks from `isAtFinalElement(RIL_TEXTLINE, RIL_WORD)`. The
  iterator is always released in a `finally` block. Returns `null` when there is
  no iterator to walk.
- The pass loop now scores the filtered reading. **Guard:** when the floor strips
  everything but the recognizer did find words, the unfiltered text is kept — a
  tuning value must never turn a working scan blank.
- Because scoring runs on filtered text, a pass that produced mostly junk now
  loses to a cleaner pass. That is a second gain beyond removing the junk.
- `ensureTessData` rewritten around a version marker. It previously copied a
  model out of assets only when the target was missing or zero length, so an app
  update carrying a new model would have kept using the old copy for every
  existing install. It now writes `tessdata/.model_version` holding
  `TESSDATA_VERSION` and re-copies every model when the stored value differs. The
  marker is written only after all models are confirmed on disk, so a copy that
  failed part way is retried next launch rather than being marked done.
- New constants `TESSDATA_VERSION`, `TESSDATA_VERSION_FILE` and
  `WORD_CONFIDENCE_FLOOR`.

### `assets/tessdata/mal.traineddata`

Replaced with the `tessdata_best` build: 5,275,996 bytes to 12,524,967 bytes,
**+7.25 MB**. Downloaded from `github.com/tesseract-ocr/tessdata_best`, size
verified against the published file and the header checked as a real model file.

`eng.traineddata` is unchanged on `tessdata_fast`. English is already reliable at
that build and the same swap would have added 11.3 MB for little gain.

### `docs/dependencies.md`

New "OCR language models" section recording which build each language file uses
and why they differ, that the `tessdata` standard build is deliberately not used,
and the rule that `TESSDATA_VERSION` must be bumped whenever a model file
changes.

### `plans/20260912_154629_upgrade_malayalam_traineddata_to_best.md`

Marked superseded — its model swap is carried out here.

## Checks run

- `flutter analyze` — no issues found
- `flutter test` — 826 tests, all passed
- `dart format lib test integration_test` — clean, nothing to change
- `./gradlew :app:compileProdDebugKotlin` — BUILD SUCCESSFUL
- Release APK built and measured against the previous build:

| Split | Before | After | Change |
|---|---|---|---|
| arm64-v8a | 75.65 MB | 80.31 MB | **+4.45 MB** |
| armeabi-v7a | 63.18 MB | 67.36 MB | +3.98 MB |
| x86_64 | 80.32 MB | 84.99 MB | +4.45 MB |

The model file itself grew 7.25 MB, but the APK compresses it, so the real cost
on disk is about 4.45 MB — less than the estimate the plan was approved on.

## Still to confirm on a device

These need a real scan and could not be checked from the build alone:

1. That `BBE` is gone and no real Malayalam word was dropped with it. If genuine
   words start disappearing, lower `WORD_CONFIDENCE_FLOOR`.
2. Scan speed. Full-precision weights run roughly two to three times slower per
   pass, and the scored loop can run up to six passes on a dark image. If scans
   drag, lower `CONFIDENT_SCORE` so a good first pass ends the loop sooner. Do
   not remove the inverted passes — those are what read light-on-dark titles.
3. That the new model actually replaces the old one when installing **over** an
   existing build, not only on a fresh install. This is what the version marker
   is for and it is the one change that cannot be verified without an upgrade.
