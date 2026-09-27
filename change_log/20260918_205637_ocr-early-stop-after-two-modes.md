# Change log — OCR early stop waits for two page modes

**Plan:** `plans/20260918_201309_ocr-keep-short-key-column.md` (revised version)
**Follows:** `change_log/20260918_194500_ocr-noise-regression-fix.md`
**Date:** 2026-09-18

## Summary

A scan of a two-column cheat sheet (short keys such as `q`, `/pat`, `-N` on the
left, their meanings on the right) returned every meaning but no keys.

Cause: the first page mode tried, Tesseract's full-page mode (PSM 3), throws
away the column of short, lone keys during its layout step, before
recognition. It still reads the rest at mean confidence 92, which passes the
early-stop test, so the single-block mode (PSM 6) never ran. That mode reads
every key on the line of its meaning, and scores higher.

Fix: the early stop may now fire only after the first two page modes (full
page and single block) have run. The best score still wins.

## What changed

### Native (platform layer)

| File | Change |
|---|---|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OcrPassRules.kt` | New. `canStopEarly(modeIndex, text, meanConfidence)` and `MIN_PASSES_BEFORE_EARLY_STOP = 2`. `earlyStopScore`, `CONFIDENT_SCORE` and `CONFIDENT_MEAN` moved here from `MainActivity.kt`, values unchanged |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | `runPasses` tracks the mode index and calls `canStopEarly`. Comment on `PAGE_SEG_MODES` says the first two modes must stay first |

### Tests and docs

| File | Change |
|---|---|
| `android/app/src/test/kotlin/in/sreerajp/sreerajp_journal_vault/OcrPassRulesTest.kt` | New: no stop after the first mode, stop after the second when confident, no stop on low mean or little text, score arithmetic |
| `docs/architecture.md` | Section 14: page mode order and the two-mode early stop |

### Built, then removed

The approved first version of the plan blamed the junk-line filter. It was
built (a key-line exemption in a new `OcrLineFilter.kt`, and a key/meaning row
merge in `OcrReadingOrder.kt`, with tests). The desktop test then showed the
keys never reach that filter, so all of it was removed again, with the user's
approval. `OcrReadingOrder.kt`, its test, and the line filter in
`MainActivity.kt` are exactly as they were before this change.

No Dart, l10n, dependency, permission or schema change.

## Desktop test results

Setup: Tesseract 5.5 from conda-forge in a temporary folder outside the
repository, the app's own `assets/tessdata` models, and a Python copy of the
Kotlin pipeline (white border, inverted copy for a dark image, the three page
modes, both candidates, the English re-read). Input: a screenshot of the cheat
sheet.

| Pass | Keys returned | Mean confidence | Score |
|---|---|---|---|
| Full page (PSM 3) | none | 92 | 2975 |
| Single block (PSM 6) | all, on their meaning's line | 88 | 3608 |
| Sparse text (PSM 11) | a few | 90 | 3307 |

Before: the full-page reading, with no keys. After: every key on its line —
`q Quit`, `Space Page down`, `/pat Search forward`, `-N Line numbers`,
`+/text Start at matching text`. Remaining misreads are ordinary recognition
errors: `j`→`3`, `?pat`→`2pat`, `-S`→`-s`, `-i`→`=`, `+G`→`+6`.

## Checks run

- `:app:testDevDebugUnitTest` — 13 Kotlin tests passed (5 new, 8 reading order).
- `:app:compileDevDebugKotlin` — compiles.
- `flutter analyze` — no issues.
- `flutter test` — all 935 tests passed.
- `sh tool/check_absolute_paths.sh --all` — passed.

## Not tested here — needs a real device

- The original phone photo of the cheat sheet, and the screenshot, in the app.
- Reading time: a clean page now runs two page modes instead of one.
- This morning's moiré screen photo and a normal paper page, to confirm no
  change.
