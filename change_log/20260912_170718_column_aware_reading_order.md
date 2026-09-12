# Change log — Put two-column text back in reading order

**Plan:** `plans/20260912_165526_column_aware_reading_order.md`
**Date:** 2026-09-12

## What was wrong

A scanned two-column newspaper article recognised every word, but the tail came
out interleaved: the end of column two, then the last line of column one, then
the page footer, then the last line of column two.

An earlier idea — bias the pass scoring toward `PSM_AUTO`, which does column
detection — was investigated and rejected. `CONFIDENT_SCORE` is 1600 and the
scan produced about 73 words at roughly 75 confidence, so `PSM_AUTO`, which runs
first, already cleared the threshold and won. The wrong order came from
Tesseract's own layout analysis, most likely confused by the full-width footer
and the rule cutting across both columns.

## What changed

### New: `android/app/src/main/kotlin/.../OcrReadingOrder.kt`

`orderLinesForReading` reorders lines from where they sit on the page:

1. Cut the page into **bands** at every full-width line (`FULL_WIDTH_RATIO`,
   0.65 of page width). A headline, footer or rule becomes a band of its own and
   is never sorted into a column beside the text it sits above or below.
2. Group each band's lines into **columns** by horizontal overlap
   (`MIN_COLUMN_OVERLAP`, 0.5 of the narrower line).
3. Read bands top to bottom, columns left to right, lines top to bottom.

`TextLineBox` holds plain integers rather than `android.graphics.Rect`, so the
whole algorithm is arithmetic that plain JUnit can exercise with no device,
emulator or Android shadow library.

**The guard matters more than the algorithm.** Reordering happens only when a
band genuinely looks like columns — two or more, each with at least
`MIN_LINES_PER_COLUMN` (3) lines. Everything else, including every single-column
page, is returned exactly as the recognizer gave it. This can improve a real
multi-column page; it cannot make an ordinary one worse.

### `android/app/src/main/kotlin/.../MainActivity.kt`

`collectConfidentText` now records each word's line rectangle from
`getBoundingBox(RIL_TEXTLINE)`, groups surviving words into `TextLineBox` values,
and passes them through `orderLinesForReading` before joining with newlines.

The two-tier confidence floor, the page-script vote and the empty-result
fallback are all unchanged.

### `android/app/build.gradle.kts`

Added `testImplementation("junit:junit:4.13.2")` — test scope only, never in the
APK. This project had no Kotlin unit tests before.

### New: `android/app/src/test/kotlin/.../OcrReadingOrderTest.kt`

Eight tests: the exact failing two-column-plus-footer layout, a full-width
headline above two columns, three columns ordered left to right, a wide single
column, a narrow single column, a column too short to be believed, an empty
list, and a single line. The last five all assert the input is returned
untouched.

## A wrong turn worth recording

While setting the tests up I added a `sourceSets` block naming
`src/test/kotlin`, believing the test source set did not pick it up, because no
compiled test class or result file appeared under `android/app/build/`.

That was a misreading. This project redirects the Gradle build directory to the
repository root, so the output was at `build/app/test-results/` all along. The
`sourceSets` block was removed after confirming the tests still run without it.
`build.gradle.kts` gains only the JUnit dependency.

Worth knowing for future Android work here: **Gradle output for this project
lands in `build/app/`, not `android/app/build/`.**

## Checks run

- `./gradlew :app:testProdDebugUnitTest` — 8 tests, 0 failures, 0 errors,
  0 skipped, confirmed from the JUnit XML report rather than from the task
  reporting success
- `./gradlew :app:compileProdDebugKotlin` — BUILD SUCCESSFUL
- `flutter analyze` — no issues found
- `flutter test` — 826 tests, all passed
- `tool/check_absolute_paths.sh --all` — clean

## Honest limits

- This fixes **order**, not recognition. A word Tesseract never found stays lost.
- The thresholds (0.65, 0.5, 3) are judgement calls measured against one
  photograph. They are named constants for that reason. If a page orders badly,
  adjust a constant rather than rewriting the algorithm.
- A page whose columns genuinely overlap horizontally — a wrapped pull quote,
  text flowing around an image — may still order oddly. The guard keeps it no
  worse than before, not perfect.

## Still to confirm on a device

- Rescan the same article and check the tail now reads column one complete, then
  column two, then the footer.
- Scan a plain single-column page and confirm nothing about it changed.
