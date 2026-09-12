# Plan — Drop low-confidence junk words and upgrade the Malayalam model

**Status:** Awaiting approval

Supersedes `plans/20260912_154629_upgrade_malayalam_traineddata_to_best.md`,
which covered only the model swap. That plan should be marked superseded.

## Where things stand

The scored multi-pass and invert change
(`change_log/20260912_152340_fix_ocr_missed_headline_and_pass_scoring.md`) is
working. A scanned masthead that previously lost its title now reads it, and the
stray single letters between numbers are gone.

One defect is left. The output contains `BBE` sitting exactly where a
decorative ornament is printed between the date and the volume number. There is
no text there. Tesseract is running in `eng+mal` mode, so when it meets a shape
that is not a letter it still tries to name it, and Latin letters are the
easiest fit. It reports these with very low confidence, but the app throws that
confidence away and keeps the word.

## Two changes

### 1. Filter words by confidence (no size or speed cost)

Today the app takes `tess.utF8Text`, which is every word the recognizer
produced regardless of how unsure it was.

Instead, build the text from `tess.getResultIterator()`, which gives each word
**and** its confidence. Drop any word below a confidence floor.

API confirmed against Tesseract4Android 4.9.0, which this app already uses:

- `TessBaseAPI.getResultIterator()` returns a `ResultIterator`
- `ResultIterator.getUTF8Text(level)` and `ResultIterator.confidence(level)`
- `PageIterator.next(level)` and `isAtFinalElement(level, level)`
- `TessBaseAPI.PageIteratorLevel.RIL_WORD` and `RIL_TEXTLINE`

New private method `collectConfidentText(tess)`:

- `begin()`, then walk word by word with `next(RIL_WORD)`
- keep a word when `confidence(RIL_WORD) >= WORD_CONFIDENCE_FLOOR`
- start a new line when `isAtFinalElement(RIL_TEXTLINE, RIL_WORD)` is true
- always call `delete()` on the iterator in a `finally` block
- return null when `getResultIterator()` returns null

`WORD_CONFIDENCE_FLOOR` starts at **55**, as a named constant so it can be
tuned. Junk read off an ornament typically scores under 40; real text on a
decent scan scores 70 or above.

**Safety guard:** if filtering removes every word but the unfiltered text was
not empty, keep the unfiltered text. A threshold set too high must never turn a
working scan into a blank result.

This runs inside the existing pass loop, so each pass is scored on its filtered
text. A pass that produced mostly junk now scores lower and loses, which is a
second benefit beyond removing the junk itself.

### 2. Swap `mal.traineddata` to the `tessdata_best` build

| File | fast (current) | best |
|---|---|---|
| `mal.traineddata` | 5.28 MB | 12.52 MB |

Cost: **+7.25 MB** on every per-ABI APK split. English stays on the current
build — it is already reliable and the same swap would cost +11.3 MB.

The current build stores the recogniser's weights as rounded whole numbers. The
`best` build stores them as full decimals. Malayalam loses the most to that
rounding because of its stacked vowel signs and joined letter shapes.

#### The upgrade bug that must be fixed with it

`ensureTessData` copies a language file out of assets only when the target is
missing or zero length:

```kotlin
if (!targetFile.exists() || targetFile.length() == 0L) {
```

Every existing install already has an old `mal.traineddata` of non-zero length
in `filesDir`. Without a fix, the new model would reach fresh installs only, and
would silently do nothing for every current user.

Fix with a version marker: write a `tessdata/.model_version` file holding a
constant string, and re-copy all language files when the stored value does not
match `TESSDATA_VERSION` in the code. Bump that constant whenever a model
changes. This is deterministic, unlike comparing asset lengths, which is
unreliable for compressed assets.

#### Speed

Full-precision weights run roughly two to three times slower per pass, and the
scored loop can run up to six passes on a dark image. After the swap, measure a
real scan. If it drags, lower `CONFIDENT_SCORE` so a good first pass ends the
loop sooner. Do not remove the inverted passes — those are what read
light-on-dark titles.

## Files to change

| File | Change |
|---|---|
| `android/.../MainActivity.kt` | `collectConfidentText`; `WORD_CONFIDENCE_FLOOR`; `TESSDATA_VERSION`; version-marker logic in `ensureTessData`; retune `CONFIDENT_SCORE` if measurement calls for it |
| `assets/tessdata/mal.traineddata` | Replaced with the `tessdata_best` build |
| `docs/dependencies.md` | Record which build each language file comes from and why they differ |

No Dart change. No new package. No new permission. Nothing leaves the device —
the model file ships inside the app and is copied to internal storage.

## Checks after implementing

- `flutter analyze` clean
- `flutter test`
- `./gradlew :app:compileProdDebugKotlin`
- On a device: rescan the same masthead and confirm `BBE` is gone and the
  Malayalam words are unchanged or better
- On a device: confirm the new model replaces the old one when installing **over**
  an existing build, not only on a fresh install
- Record the new APK size and a rough scan time in the change log
